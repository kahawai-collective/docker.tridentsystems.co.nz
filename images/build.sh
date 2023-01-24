#!/bin/bash

set -e

ls

cp /input/mpi-latex-templates-local/mpi-latex-templates_1.54_all.deb .

make deploy

exit $?
