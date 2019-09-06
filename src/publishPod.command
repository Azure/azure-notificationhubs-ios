# Push podspec to CocoaPods
resp="$(pod trunk push ./AzureNotificationHubs-iOS.podspec)"
echo $resp

# Check error from the response
error="$(echo $resp | grep -i 'error\|fatal|The spec did not pass validation')"
if [ "$error" ]; then
    echo "Cannot publish to CocoaPods"
    exit 1
fi

successFlag="$(echo $resp | grep -i 'successfully published')"
if [ -z "$successFlag" ]; then
    echo "Cannot publish to CocoaPods"
    exit 1
fi

echo "Podspec published to CocoaPods successfully"
