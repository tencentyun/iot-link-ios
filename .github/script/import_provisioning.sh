#!/bin/sh

# Decrypt the files
# --batch to prevent interactive command --yes to assume "yes" for questions
#gpg --quiet --batch --yes --decrypt --passphrase="$PROVISIONING_PASSWORD" --output .github/script/apple_dev.p12 .github/script/opensource_keystore.p12.asc
#gpg --quiet --batch --yes --decrypt --passphrase="$PROVISIONING_PASSWORD" --output .github/script/dev.mobileprovision .github/script/opensource_keystore.mobileprovision.asc

if [ $1 == 'Debug' ]; then
    echo "Debug"
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/opensource.p12.asc > .github/script/apple_dev.p12
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/opensource.mobileprovision.asc > .github/script/dev.mobileprovision
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/link_sdk_demo.mobileprovision.asc > .github/script/devsdkdemo.mobileprovision
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/link_sdk_demo_appdelegate.m.asc > Source/LinkSDKDemo/AppDelegate.m
elif [ $1 == 'ReleaseBeta' ]; then
    echo "ReleaseBeta"
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/apple_dev_beta.p12.asc > .github/script/apple_dev.p12
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/apple_dev_beta.mobileprovision.asc > .github/script/dev.mobileprovision
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/app-config.json.asc > Source/LinkApp/Supporting\ Files/app-config.json
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/LinkAppBeta.xcconfig.asc > Source/LinkApp/Supporting\ Files/LinkApp.xcconfig
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/ExportOptionsReleaseBeta.plist.asc > .github/script/ExportOptionsRelease.plist
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/GoogleService-Info.plist.asc > Source/LinkApp/Supporting\ Files/GoogleService-Info.plist
else
    echo "Release"
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/tencent_official.p12.asc > .github/script/apple_dev.p12
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/tencent_official.mobileprovision.asc > .github/script/dev.mobileprovision
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/app-config.json.asc > Source/LinkApp/Supporting\ Files/app-config.json
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/LinkApp.xcconfig.asc > Source/LinkApp/Supporting\ Files/LinkApp.xcconfig
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/ExportOptionsRelease.plist.asc > .github/script/ExportOptionsRelease.plist
    gpg --quiet -d --passphrase "$PROVISIONING_PASSWORD" --batch .github/script/GoogleService-Info.plist.asc > Source/LinkApp/Supporting\ Files/GoogleService-Info.plist
    
        #当前时间
    curTime=$(date +%s)
    echo "当前时间---$curTime"

    #基准差值
    baseTime=$(date -j -f "%Y-%m-%d %H:%M:%S" "2020-10-27 00:00:00" +%s)
    ((timeStamp=$curTime - $baseTime))
    echo "基准差值---$timeStamp"

    #版本号
    ((buildTime=$timeStamp / 86400))
    echo "版本号---$buildTime"
    
    sed -i "" "s/LinkAPP_BUILD_VERSION.*/LinkAPP_BUILD_VERSION = $buildTime/g" Source/LinkApp/Supporting\ Files/LinkAppCommon.xcconfig
fi



mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

echo "List profiles"
ls ~/Library/MobileDevice/Provisioning\ Profiles/
echo "Move profiles"
cp .github/script/*.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
echo "List profiles"
ls ~/Library/MobileDevice/Provisioning\ Profiles/

#security create-keychain -p "" build.keychain
#security import .github/script/apple_dev.p12 -t agg -k ~/Library/Keychains/build.keychain -P "$P12_EXPORT_CCHARLESREN_PASSWORD" -A
#
#security list-keychains -s ~/Library/Keychains/build.keychain
#security default-keychain -s ~/Library/Keychains/build.keychain
#security unlock-keychain -p "" ~/Library/Keychains/build.keychain
#security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain


# Create temporary keychain https://www.soinside.com/question/2TAiumaLpa7y3jpSY6NViE
KEYCHAIN="MyApp.keychain"
KEYCHAIN_PASSWORD="MyApp"
security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN"

# Append keychain to the search list
security list-keychains -d user -s "$KEYCHAIN" $(security list-keychains -d user | sed s/\"//g)
security list-keychains

# Unlock the keychain
security set-keychain-settings "$KEYCHAIN"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN"

# Import certificate
security import .github/script/apple_dev.p12 -k "$KEYCHAIN" -P "$P12_EXPORT_CCHARLESREN_PASSWORD" -T "/usr/bin/codesign"

# Detect the iOS identity
IOS_IDENTITY=$(security find-identity -v -p codesigning "$KEYCHAIN" | head -1 | grep '"' | sed -e 's/[^"]*"//' -e 's/".*//')
IOS_UUID=$(security find-identity -v -p codesigning "$KEYCHAIN" | head -1 | grep '"' | awk '{print $2}')

# New requirement for MacOS 10.12+
security set-key-partition-list -S apple-tool:,apple: -s -k $KEYCHAIN_PASSWORD $KEYCHAIN
