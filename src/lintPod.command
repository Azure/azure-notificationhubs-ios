# Run lint to validate podspec
pod spec lint ./AzureNotificationHubs-iOS.podspec --verbose
retval=$?

if [ $retval -eq 0 ]; then
    echo $'\360\237\215\272 Podspec validated successfully'
else
    echo '\xf0\x9f\x91\xbf Cannot publish to CocoaPods due to spec validation failure'
    exit 1
fi