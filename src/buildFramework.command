ABSPATH=$(cd "$(dirname "$0")"; pwd)
cd "$ABSPATH"

buildFolderPath=$ABSPATH/Build
rm -rf "$buildFolderPath"
mkdir -p "$buildFolderPath"
buildLogPath=$buildFolderPath/buildLog.txt

echo "******* Building framework *******" 2>&1 | tee -a "$buildLogPath"
cd "$ABSPATH/WindowsAzureMessaging"
xcodebuild clean &> /dev/null
xcodebuild -scheme Framework -target Framework -configuration Release BUILD_DIR=./Build | sed '/setenv/d' 2>&1 | tee -a "$buildLogPath"

if [ ! -e Build/Release-iphoneos/WindowsAzureMessaging.framework ] ; then
    echo "******* Framework build for iPhone OS failed *******" 2>&1 | tee -a "$buildLogPath"
    exit 1
fi

if [ ! -e Build/Release-iphonesimulator/WindowsAzureMessaging.framework ] ; then
    echo "******* Framework build for iPhone simulator failed *******" 2>&1 | tee -a "$buildLogPath"
    exit 1
fi

cd "./Build/Release-iphoneos"
lipo -info "WindowsAzureMessaging.framework/WindowsAzureMessaging" 2>&1 | tee -a "$buildLogPath"
cp -R -L "WindowsAzureMessaging.framework" "$buildFolderPath/WindowsAzureMessaging.framework" 2>&1 | tee -a "$buildLogPath"
zip -r "$buildFolderPath/WindowsAzureMessaging.framework.zip" "WindowsAzureMessaging.framework" 2>&1 | tee -a "$buildLogPath"

echo "******* Framework build successful *******" 2>&1 | tee -a "$buildLogPath"
