ABSPATH=$(cd "$(dirname "$0")"; pwd)
cd "$ABSPATH"

buildFolderPath=$ABSPATH/Build
testLogPath=$buildFolderPath/BVTLog.txt

#prepare test framework
cd BVT
unzip -o GHUnitIOS.framework.zip
rm -rf RunTests.sh
unzip -o RunTests.sh.zip
cd IosSdkTests
unzip -o png.zip
cd ..
rm -rf "WindowsAzureMessaging.framework"
cp -R -L "$ABSPATH/WindowsAzureMessaging/Build/Release-iphonesimulator/WindowsAzureMessaging.framework" "WindowsAzureMessaging.framework" 2>&1 | tee -a "$testLogPath"

echo "******* Build and run BVT *******" 2>&1 | tee -a "$testLogPath"
GHUNIT_CLI=1 xcodebuild -scheme IosSdkTests -destination 'platform=iOS Simulator,name=iPhone SE,OS=11.4' -configuration Debug -sdk iphonesimulator13.4 clean build 2>&1 | tee -a "$testLogPath"
grep "with 0 failures" "$testLogPath" &> /dev/null
if [ "$?" != "0" ]; then
    echo "******* IOS SDK BVT Failed *******" 2>&1 | tee -a "$testLogPath"
    exit 1
fi

echo "******* BVT succeeded *******" 2>&1 | tee -a "$testLogPath"
