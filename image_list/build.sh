#!/bin/bash

set -euo pipefail

python3 current_images.py ${GITHUB_USERNAME} ${GITHUB_ACCESS_TOKEN} reports.tab
cp images.csv reports.csv /output/
