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
#TEMP_PATH=/tmp/app
OUTPUT_APK_PATH=android/app/build/outputs/apk/release/
OUTPUT_BUNDLE_PATH=android/app/build/outputs/bundle/release/
LANE=${1:-build}

echo "[NOTO]: Starting Build"
cd $APP_PATH
#mkdir -p $TEMP_PATH
#echo "[NOTO]: Making Copy"
#cp -r `ls -A | grep -v "node_modules"` $TEMP_PATH

#cd $TEMP_PATH
#echo "[NOTO]: Installing JS Dependencies"
#yarn

echo "[NOTO]: Syncing configurations"
yarn sync:config
echo "[NOTO]: Generating icons"
yarn generate:icons

export $(cat .env | xargs)

#cd $TEMP_PATH/android
cd $APP_PATH/android
rm Gemfile.lock
bundle install
echo "[NOTO]: Running Fastlane Lane $LANE"
bundle exec fastlane $LANE

if [ -d "$APP_RELEASE_PATH" ]; then
  rm -rf $APP_RELEASE_PATH
fi
mkdir -p $APP_RELEASE_PATH

#DIR="$TEMP_PATH/$OUTPUT_APK_PATH"
DIR="$APP_PATH/$OUTPUT_APK_PATH"
if [ -d "$DIR" ]; then
  cd $DIR
  echo "[NOTO]: Copying Release APK to $APP_RELEASE_PATH"
  cp -r `ls -A` $APP_RELEASE_PATH
fi

#DIR="$TEMP_PATH/$OUTPUT_BUNDLE_PATH"
DIR="$APP_PATH/$OUTPUT_BUNDLE_PATH"
if [ -d "$DIR" ]; then
  cd $DIR
  echo "[NOTO]: Copying Release AAB"
  cp -r `ls -A` $APP_RELEASE_PATH
fi


echo "[NOTO]: Build Successful!"

cd $APP_PATH
