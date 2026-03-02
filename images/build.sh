#!/bin/bash

set -euo pipefail

IMAGE=${IMAGE:-}
if [ -n "${IMAGE}" ]; then
    export DOCKERS=$IMAGE
fi
make deploy
