#!/bin/sh

# Copyright (c) Microsoft Corporation. All rights reserved.

# Push podspec to CocoaPods
PROJECT_DIR="$(dirname "$0")/.."
PODSPEC_FILE="$PROJECT_DIR/AzureNotificationHubs-iOS.podspec"

pod trunk push $PODSPEC_FILE
retval=$?

if [ $retval -eq 0 ]; then
    echo $'\360\237\215\272 Podspec published to CocoaPods successfully"'
else
    echo -e '\xf0\x9f\x91\xbf Cannot publish to CocoaPods'
    exit 1
fi