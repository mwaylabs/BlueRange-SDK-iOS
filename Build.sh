#!/bin/bash

# Update copyright header of all source and test files.
sh Scripts/replace_copyright_header.sh

# Build .framwork for all architectures
sudo gem install cocoapods-packager
pod package BlueRangeSDK.podspec --force

# Copy build phase script for removing i386 architectures.
# Necessary when submitting app to AppStore.
TARGET_PATH=$(find . -type d -name "BlueRangeSDK-*" | tail -1)
cp -p ./Scripts/strip_frameworks.sh $TARGET_PATH/ios/BlueRangeSDK.framework