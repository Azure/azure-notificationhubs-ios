## 1. Run lint to validate podspec.
resp="$(pod spec lint ./AzureNotificationHubs-iOS.podspec --allow-warnings)"
echo $resp

# Check error from the response
error="$(echo $resp | grep -i 'error\|fatal')"
if [ "$error" ]; then
    echo "Cannot publish to CocoaPods due to spec validation failure"
    exit 1
fi
