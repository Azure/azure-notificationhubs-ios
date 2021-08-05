#!/bin/sh

# Copyright (c) Microsoft Corporation. All rights reserved.

# Run lint to validate podspec
PROJECT_DIR="$(dirname "$0")/.."
PODSPEC_FILE="$PROJECT_DIR/AzureNotificationHubs-iOS.podspec"

pod spec lint $PODSPEC_FILE --verbose
retval=$?

if [ $retval -eq 0 ]; then
    echo $'\360\237\215\272 Podspec validated successfully'
else
    echo '\xf0\x9f\x91\xbf Cannot publish to CocoaPods due to spec validation failure'
    exit 1
fi