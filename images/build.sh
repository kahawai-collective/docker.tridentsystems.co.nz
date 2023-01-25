#!/bin/bash

set -e

cp /input/mpi-latex-templates-local/mpi-latex-templates_1.55_all.deb ubuntu/gorbachev-base-jammy/mpi-latex-templates_1.55_all.deb

make deploy

exit $?
