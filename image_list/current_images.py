import subprocess
import sys
import tempfile
import yaml

username = sys.argv[1]
access_token = sys.argv[2]
reports_list = sys.argv[3]
images = set()
reports = dict()

for report in open(reports_list, "rt").read().splitlines():
    code, repo, branch, directory = report.strip().split("|")
    if directory == ".":
        directory = ""
    elif directory.startswith("./"):
        directory = directory[2:]
    path = f"{directory}/kahawai.yaml"
    url = f"https://raw.githubusercontent.com/{repo}/{branch}/{path}"
    cmd = ["curl", "-sL", "-u", f"{username}:{access_token}", url]
    data = yaml.safe_load(subprocess.check_output(cmd))
    if data and "docker" in data:
        sys.stderr.write(f"✓ {code}\n")
        images.add(data["docker"])
        reports[code] = data["docker"]
    else:
        sys.stderr.write(f"✗ {code}\n")

with open("images.csv", "wt") as f:
    for image in sorted(list(images)):
        f.write(image + "\n")

with open("reports.csv", "wt") as f:
    for report in sorted(reports.keys()):
        f.write(f"{report}|{reports[report]}\n")
