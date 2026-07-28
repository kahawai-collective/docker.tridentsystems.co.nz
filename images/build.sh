#!/bin/bash

set -euo pipefail

PUSH=yes python3 build.py --command-file ${OUTPUTDIR}/commands.txt --image-file ${OUTPUTDIR}/image.txt ${IMAGE:-}
