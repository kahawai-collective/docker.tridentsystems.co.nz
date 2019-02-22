#!/bin/bash

set -euo pipefail

cd .. && make deploy

exit $?
