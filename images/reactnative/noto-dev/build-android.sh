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

showLoading() {
  mypid=$!
  loadingText=$1

  echo -ne "$loadingText\r"

  while kill -0 $mypid 2>/dev/null; do
    echo -ne "$loadingText.\r"
    sleep 0.5
    echo -ne "$loadingText..\r"
    sleep 0.5
    echo -ne "$loadingText...\r"
    sleep 0.5
    echo -ne "\r\033[K"
    echo -ne "$loadingText\r"
    sleep 0.5
  done

  echo "$loadingText...FINISHED"
}

echo "[NOTO]: Starting Build"
cd $APP_PATH
mkdir -p $TEMP_PATH
(cp -r `ls -A | grep -v "node_modules"` $TEMP_PATH) & showLoading "[NOTO]: Making Copy"

cd $TEMP_PATH
# yarn & showLoading "[NOTO]: Installing JS Dependencies"

yarn sync:config & showLoading "[NOTO]: Syncing configurations"
yarn generate:icons & showLoading "[NOTO]: Generating icons"

export $(cat .env | xargs)

cd $TEMP_PATH/android
rm Gemfile.lock
bundle install
(bundle exec fastlane $LANE) & showLoading "[NOTO]: Running Fastlane Lane $LANE"

if [ -d "$APP_RELEASE_PATH" ]; then
  rm -rf $APP_RELEASE_PATH
fi
mkdir -p $APP_RELEASE_PATH

DIR="$TEMP_PATH/$OUTPUT_APK_PATH"
if [ -d "$DIR" ]; then
  cd $DIR
  (cp -r `ls -A` $APP_RELEASE_PATH) & showLoading "[NOTO]: Copying Release APK to $APP_RELEASE_PATH"
fi

DIR="$TEMP_PATH/$OUTPUT_BUNDLE_PATH"
if [ -d "$DIR" ]; then
  cd $DIR
  (cp -r `ls -A` $APP_RELEASE_PATH) & showLoading "[NOTO]: Copying Release AAB"
fi


echo "[NOTO]: Build Successful!"

cd $APP_PATH
