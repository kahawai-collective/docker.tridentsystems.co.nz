#!/bin/bash

set -euo pipefail

PUSH=yes python3 build.py ${IMAGE:-}
