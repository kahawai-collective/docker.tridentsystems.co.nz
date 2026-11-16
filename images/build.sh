#!/bin/bash

set -euo pipefail

export PUSH=yes
export PUSH_USERNAME
export PUSH_PASSWORD

python3 build.py --command-file ${OUTPUTDIR}/commands.txt --image-file ${OUTPUTDIR}/image.txt ${IMAGE:-}
