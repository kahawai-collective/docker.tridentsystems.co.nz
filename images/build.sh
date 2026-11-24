#!/bin/bash

set -euo pipefail

JOBID=${JOBID#JobID }
export PUSH_USERNAME
export PUSH_PASSWORD

python3 build.py --push --command-file ${OUTPUTDIR}/commands.txt --image-file ${OUTPUTDIR}/image.txt \
        --tag $JOBID ${IMAGE:-}
