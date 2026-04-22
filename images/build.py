import os
import re
import subprocess
import sys

DEP = {}
REGISTRY = "docker.kahawai.net.nz"

def log(s):
    sys.stderr.write(s + "\n")
    sys.stderr.flush()

def load_dependencies():
    newest_mtime = 0
    last_modified = None
    for line in subprocess.check_output('find . -name Dockerfile | xargs grep "^FROM "', shell=True).decode("utf-8").splitlines():
        child_df, rest = line.split(":", maxsplit=1)
        child_df = child_df[len("./"):]
        child_folder = child_df.rsplit("/", maxsplit=1)[0]
        mtime = os.stat(child_df).st_mtime
        if mtime > newest_mtime:
            newest_mtime = mtime
            last_modified = child_folder
        dependency = rest[len("FROM "):]
        if dependency.startswith(f"{REGISTRY}/") and not ":" in dependency:
            folder = dependency[len(f"{REGISTRY}/"):]
            assert(os.path.exists(f"{folder}/Dockerfile"))
            DEP[child_folder] = dict(build=folder)
        else:
            DEP[child_folder] = dict(pull=dependency)
    return last_modified

def build_commands(image, hash, date):
    commands = []
    if "pull" in DEP[image]:
        commands += [("docker", "pull", DEP[image]["pull"])]
    commands += [
        ("docker", "build", "-t", f"{REGISTRY}/{image}", image),
        ("docker", "tag", f"{REGISTRY}/{image}", f"{REGISTRY}/{image}:{hash}"),
        ("docker", "tag", f"{REGISTRY}/{image}", f"{REGISTRY}/{image}:{date}"),
    ]
    if "build" in DEP[image]:
        commands = build_commands(DEP[image]["build"], hash, date) + commands
    return commands

def push_commands(image, hash, date):
    return [
        ("docker", "push", f"{REGISTRY}/{image}:latest"),
        ("docker", "push", f"{REGISTRY}/{image}:{hash}"),
        ("docker", "push", f"{REGISTRY}/{image}:{date}"),
    ]

if __name__ == "__main__":
    default_image = load_dependencies()
    if len(sys.argv) == 2:
        image = sys.argv[1]
    elif "IMAGE" in os.environ:
        image = os.environ.get("IMAGE")
    else:
        log("No image found on command line or in environment; attempting to build image for most recently modified Dockerfile")
        image = default_image

    date = os.environ.get("DATE", subprocess.check_output(["date", "+%Y-%m-%d"]).decode("utf-8").strip())
    hash = os.environ.get("HASH", subprocess.check_output(["git", "rev-parse", "--short=8", "HEAD"]).decode("utf-8").strip())

    assert re.match(r"^[a-zA-Z][-a-zA-Z0-9\._:\/]+$", image), "Bad image format"
    assert re.match(r"^\d{4}-\d{2}-\d{2}$", date), "Bad date format"
    assert re.match(r"^[0-9a-f]{8}$", hash), "Bad hash format"

    log(f"Image:{image} Date:{date} Commit:{hash}")

    if not image in DEP:
        log(f"Dockerfile not found for {image}")
        sys.exit(1)

    cmds = build_commands(image, hash, date)
    push = os.environ.get("PUSH", "no")
    if push in ("yes", "1", "true"):
        cmds += push_commands(image, hash, date)

    for cmd in cmds:
        log(" ".join(cmd))

    log("----")
    for cmd in cmds:
        log("* " + " ".join(cmd))
        subprocess.run(cmd, check=True)
