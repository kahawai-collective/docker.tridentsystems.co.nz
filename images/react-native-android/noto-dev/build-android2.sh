#!/bin/bash

echo "[NOTO]: Syncing configurations"
yarn sync:config
echo "[NOTO]: Generating icons"
yarn generate:icons

export $(cat .env | xargs)

cd $TEMP_PATH/android
rm Gemfile.lock
bundle install
echo "[NOTO]: Running Fastlane Lane $LANE"
bundle exec fastlane $LANE

if [ -d "$APP_RELEASE_PATH" ]; then
  rm -rf $APP_RELEASE_PATH
fi
mkdir -p $APP_RELEASE_PATH

DIR="$TEMP_PATH/$OUTPUT_APK_PATH"
if [ -d "$DIR" ]; then
  cd $DIR
  echo "[NOTO]: Copying Release APK to $APP_RELEASE_PATH"
  cp -r `ls -A` $APP_RELEASE_PATH
fi

DIR="$TEMP_PATH/$OUTPUT_BUNDLE_PATH"
if [ -d "$DIR" ]; then
  cd $DIR
  echo "[NOTO]: Copying Release AAB"
  cp -r `ls -A` $APP_RELEASE_PATH
fi


echo "[NOTO]: Build Successful!"

cd $APP_PATH
