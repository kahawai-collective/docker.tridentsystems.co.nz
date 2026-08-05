import base64
import requests
import sys
import yaml

access_token = sys.argv[1]
reports_list = sys.argv[2]
images = set()
reports = dict()

headers = {"Authorization": f"token {access_token}"}

for report in open(reports_list, "rt").read().splitlines():
    code, repo, branch, directory = report.strip().split("|")
    if directory == ".":
        directory = ""
    elif directory.startswith("./"):
        directory = directory[2:]
    path = f"{directory}/kahawai.yaml"
    url = f"https://api.github.com/repos/{repo}/contents/{path}?ref={branch}"
    response = requests.get(url, headers=headers)

    try:
        response.raise_for_status()
        image = yaml.safe_load(base64.b64decode(response.json().get("content")))["docker"]
    except Exception as e:
        sys.stderr.write(f"✗ {code}\n")
        continue

    sys.stderr.write(f"✓ {code}\n")
    images.add(image)
    reports[code] = image

with open("images.csv", "wt") as f:
    for image in sorted(list(images)):
        f.write(image + "\n")

with open("reports.csv", "wt") as f:
    for report in sorted(reports.keys()):
        f.write(f"{report}|{reports[report]}\n")
