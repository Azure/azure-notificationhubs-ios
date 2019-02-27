# Push podspec to CocoaPods
resp="$(pod trunk push ./WindowsAzureMessaging.podspec --allow-warnings)"
echo $resp

# Check error from the response
error="$(echo $resp | grep -i 'error\|fatal')"
if [ "$error" ]; then
    echo "Cannot publish to CocoaPods"
    exit 1
fi

echo "Podspec published to CocoaPods successfully"
