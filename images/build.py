import argparse
import os
import re
import subprocess
import sys

DEP = {}
REGISTRY = "docker.kahawai.net.nz"
PUSH_HOST = "push.docker.kahawai.net.nz"

def log(s, f=sys.stderr):
    f.write(s + "\n")
    f.flush()

def load_dependencies():
    newest_mtime = 0
    last_modified = None
    subprocess.run(["git", "fetch", "--depth", "30"], check=True)
    for line in subprocess.check_output('find . -name Dockerfile | xargs grep "^FROM "', shell=True).decode("utf-8").splitlines():
        child_df, rest = line.split(":", maxsplit=1)
        child_df = child_df[len("./"):]
        child_folder = child_df.rsplit("/", maxsplit=1)[0]
        try:
            mtime = int(subprocess.check_output(["git", "log", "-1", "--format=%ct", child_df], text=True).strip())
        except:
            mtime = 0
        if mtime > newest_mtime:
            newest_mtime = mtime
            last_modified = child_folder
        dependency = rest[len("FROM "):]
        if dependency.startswith(f"{REGISTRY}/") and not ":" in dependency:
            folder = dependency[len(f"{REGISTRY}/"):]
            assert os.path.exists(f"{folder}/Dockerfile"), f"{child_folder}: could not find depencency {folder}/Dockerfile"
            DEP[child_folder] = dict(build=folder)
        else:
            DEP[child_folder] = dict(pull=dependency)
    return last_modified

def build_commands(image, tag, push_required=True):
    commands = []
    if "pull" in DEP[image]:
        commands += [("docker", "pull", DEP[image]["pull"])]
    registry = PUSH_HOST if push_required else REGISTRY
    commands += [("docker", "build", "-t", f"{registry}/{image}", image)]
    if push_required:
        commands += [
            ("docker", "tag", f"{registry}/{image}", f"{registry}/{image}:{tag}"),
        ]
    if "build" in DEP[image]:
        commands = build_commands(DEP[image]["build"], tag, push_required=False) + commands
    return commands

def image_exists(image):
    p = subprocess.run(
        ["docker", "manifest", "inspect", image],
        stderr=subprocess.PIPE, stdout=subprocess.DEVNULL,
    )
    if p.returncode == 0:
        return True
    msg = p.stderr.decode("utf-8")
    if "no such manifest:" in msg:
        return False
    log("Unable to check registry")
    log(msg)
    sys.exit(1)

def push_tag(image, tag):
    # Refuse to push altogether if a image already exists with this name & tag
    tagged_image = f"{REGISTRY}/{image}:{tag}"
    if image_exists(tagged_image):
        log(f"Image {tagged_image} already exists, overwriting not allowed")
        sys.exit(1)
    return ("docker", "push", f"{PUSH_HOST}/{image}:{tag}")

def push_latest(image):
    # Always overwrite the latest tag
    return ("docker", "push", f"{PUSH_HOST}/{image}:latest")

def push_commands(image, tag):
    return [push_tag(image, tag), push_latest(image)]

def docker_login():
    if "PUSH_USERNAME" not in os.environ or "PUSH_PASSWORD" not in os.environ:
        log("Missing registry credentials")
        sys.exit(1)
    login_cmd = [
        "docker", "login", "--password-stdin",
        "--username", os.environ["PUSH_USERNAME"],
        PUSH_HOST,
    ]
    p = subprocess.run(login_cmd, input=os.environ["PUSH_PASSWORD"], text=True)
    if p.returncode != 0:
        log("Registry login failed")
        sys.exit(1)

def run_cmd(cmd):
    if cmd:
        log("* " + " ".join(cmd))
        subprocess.run(cmd, check=True)

if __name__ == "__main__":
    latest_image = load_dependencies()
    if "IMAGE" in os.environ:
        default_image = os.environ.get("IMAGE")
    else:
        default_image = latest_image
    parser = argparse.ArgumentParser(description="Build kahawai images from Dockerfiles")
    parser.add_argument("--command-file", help="Print docker commands to this file")
    parser.add_argument("--image-file", help="Print name of target image to this file")
    parser.add_argument("--push", action="store_true", help=f"Push image to {REGISTRY}")
    parser.add_argument("--tag", help=f"Image tag, defaults to the commit hash of this git checkout")
    parser.add_argument("image", nargs="?", default=default_image, help="Folder containing the Dockerfile for the target image")
    args = parser.parse_args()
    image = args.image
    command_file = open(args.command_file, "wt") if args.command_file else None

    if args.tag:
        tag = args.tag
    else:
        tag = subprocess.check_output(["git", "rev-parse", "--short=8", "HEAD"]).decode("utf-8").strip()

    assert re.match(r"^[a-zA-Z][-a-zA-Z0-9\._:\/]+$", image), "Bad image format"
    assert re.match(r"^[a-zA-Z0-9_][a-zA-Z0-9._-]{0,127}$", tag), "Bad tag format"

    log(f"Image:{image} Tag:{tag}")

    if not image in DEP:
        log(f"Dockerfile not found for {image}")
        sys.exit(1)

    build_cmds = build_commands(image, tag, push_required=args.push)
    plan = build_cmds.copy()

    if args.push:
        docker_login()
        plan += push_commands(image, tag)

    for cmd in plan:
        log(" ".join(cmd))
        if command_file:
            log(" ".join(cmd), command_file)

    log("----")
    for cmd in build_cmds:
        run_cmd(cmd)

    if args.push:
        run_cmd(push_tag(image, tag))
        run_cmd(push_latest(image))

    if args.image_file:
        log(f"{image}:{tag}", open(args.image_file, "wt"))

    if args.push:
        msg = f"Image pushed to {REGISTRY}/{image}:{tag}"
        divider = "-" * len(msg)
        log("\n".join([divider, msg, divider]))
