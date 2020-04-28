ABSPATH=$(cd "$(dirname "$0")"; pwd)
cd "$ABSPATH"

buildFolderPath=$ABSPATH/Build
testLogPath=$buildFolderPath/CITLog.txt

echo "******* Build and run CIT *******" 2>&1 | tee -a "$testLogPath"
cd "$ABSPATH/WindowsAzureMessaging"

xcodebuild -scheme WindowsAzureMessagingStatic -destination 'platform=iOS Simulator,name=iPhone 8' test 2>&1 | tee -a "$testLogPath"

grep " TEST SUCCEEDED " "$testLogPath" &> /dev/null
if [ "$?" != "0" ]; then
    echo "******* CIT failed *******" 2>&1 | tee -a "$testLogPath"
    exit 1
fi
echo "******* CIT succeeded *******" 2>&1 | tee -a "$testLogPath"
