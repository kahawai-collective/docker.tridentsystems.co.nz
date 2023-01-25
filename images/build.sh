#!/bin/bash

set -e

cp /input/mpi-latex-templates-local/mpi-latex-templates_1.55_all.deb ubuntu/gorbachev-base-jammy/.

make deploy

exit $?
