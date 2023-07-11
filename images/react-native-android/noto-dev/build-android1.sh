#!/bin/bash

if [ -z "$2" ]; then
  APP_PATH=/code
else
  APP_PATH=$2
fi

if [ -n "$KAHAWAI_CI" ]; then
  export TRAVIS=kahawai-ci-build
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

APP_RELEASE_PATH=$APP_PATH/release/android
TEMP_PATH=/tmp/app
OUTPUT_APK_PATH=android/app/build/outputs/apk/release/
OUTPUT_BUNDLE_PATH=android/app/build/outputs/bundle/release/
LANE=${1:-build}

echo "[NOTO]: Starting Build"
cd $APP_PATH
mkdir -p $TEMP_PATH
echo "[NOTO]: Making Copy"
cp -r `ls -A | grep -v "node_modules"` $TEMP_PATH

cd $TEMP_PATH
echo "[NOTO]: Installing JS Dependencies"
yarn
