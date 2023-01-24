#!/bin/bash

set -e

ls -lRt /input

make deploy

exit $?
