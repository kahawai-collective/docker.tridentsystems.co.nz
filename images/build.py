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

def build_commands(image, hash, date, push_required=True):
    commands = []
    if "pull" in DEP[image]:
        commands += [("docker", "pull", DEP[image]["pull"])]
    registry = PUSH_HOST if push_required else REGISTRY
    commands += [("docker", "build", "-t", f"{registry}/{image}", image)]
    if push_required:
        commands += [
            ("docker", "tag", f"{registry}/{image}", f"{registry}/{image}:{hash}"),
            ("docker", "tag", f"{registry}/{image}", f"{registry}/{image}:{date}"),
        ]
    if "build" in DEP[image]:
        commands = build_commands(DEP[image]["build"], hash, date, push_required=False) + commands
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

def push_hash(image, hash):
    # Refuse to push altogether if a hash-tagged image already exists
    hash_image = f"{REGISTRY}/{image}:{hash}"
    if image_exists(hash_image):
        log(f"Image {hash_image} already exists, overwriting not allowed")
        sys.exit(1)
    return ("docker", "push", f"{PUSH_HOST}/{image}:{hash}")

def push_date(image, date):
    # Only push a date-tagged image if it doesn't exist
    date_image = f"{REGISTRY}/{image}:{date}"
    if image_exists(date_image):
        log(f"Image {date_image} already exists, not overwriting")
        return
    return ("docker", "push", f"{PUSH_HOST}/{image}:{date}")

def push_latest(image):
    # Always overwrite the latest tag
    return ("docker", "push", f"{PUSH_HOST}/{image}:latest")

def push_commands(image, hash, date):
    cmds = [push_hash(image, hash)]
    date_cmd = push_date(image, date)
    if date_cmd:
        cmds.append(date_cmd)
    return cmds + [push_latest(image)]

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
    parser.add_argument("image", nargs="?", default=default_image, help="Folder containing the Dockerfile for the target image")
    args = parser.parse_args()
    image = args.image
    command_file = open(args.command_file, "wt") if args.command_file else None

    date = os.environ.get("DATE", subprocess.check_output(["date", "+%Y-%m-%d"]).decode("utf-8").strip())
    hash = os.environ.get("HASH", subprocess.check_output(["git", "rev-parse", "--short=8", "HEAD"]).decode("utf-8").strip())

    assert re.match(r"^[a-zA-Z][-a-zA-Z0-9\._:\/]+$", image), "Bad image format"
    assert re.match(r"^\d{4}-\d{2}-\d{2}$", date), "Bad date format"
    assert re.match(r"^[0-9a-f]{8}$", hash), "Bad hash format"

    log(f"Image:{image} Date:{date} Commit:{hash}")

    if not image in DEP:
        log(f"Dockerfile not found for {image}")
        sys.exit(1)

    build_cmds = build_commands(image, hash, date, push_required=args.push)
    plan = build_cmds.copy()

    if args.push:
        docker_login()
        plan += push_commands(image, hash, date)

    for cmd in plan:
        log(" ".join(cmd))
        if command_file:
            log(" ".join(cmd), command_file)

    log("----")
    for cmd in build_cmds:
        run_cmd(cmd)

    if args.push:
        run_cmd(push_hash(image, hash))
        run_cmd(push_date(image, date))
        run_cmd(push_latest(image))

    if args.image_file:
        log(f"{image}:{hash}", open(args.image_file, "wt"))

    if args.push:
        msg = f"Image pushed to {REGISTRY}/{image}:{hash}"
        divider = "-" * len(msg)
        log("\n".join([divider, msg, divider]))
