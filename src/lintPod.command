# Run lint to validate podspec
resp="$(pod spec lint ./AzureNotificationHubs-iOS.podspec)"
echo $resp

# Check error from the response
error="$(echo $resp | grep -i 'error\|fatal|The spec did not pass validation')"
if [ "$error" ]; then
    echo "Cannot publish to CocoaPods due to spec validation failure"
    exit 1
fi

echo "Podspec validated successfully"
