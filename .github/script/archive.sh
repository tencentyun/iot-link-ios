#!/bin/sh

#bin/bsah - l

git branch
echo "本地branch"
git branch -r
echo "远程branch"

rb=$GIT_BRANCH_IMAGE_VERSION
rc=$(git rev-parse --short HEAD)
rtt=$(git describe --tags `git rev-list --tags --max-count=1`)
rt=${rtt#*v}

echo $rb
echo $rc
echo $rt

if [ $1 == 'Debug' ]; then
#开源版
    sed -i "" "s/LinkAPP_VERSION.*/LinkAPP_VERSION = $rb+git.$rc/g" Source/LinkApp/Supporting\ Files/LinkAppCommon.xcconfig
else
#公版
    sed -i "" "s/LinkAPP_VERSION.*/LinkAPP_VERSION = $rt/g" Source/LinkApp/Supporting\ Files/LinkAppCommon.xcconfig
    sed -i "" "s/CFBundleName.*/CFBundleName = \"腾讯连连\";/g" Source/LinkApp/Supporting\ Files/Resource/zh-Hans.lproj/InfoPlist.strings
    sed -i "" "s/CFBundleName.*/CFBundleName = \"TencentLink\";/g" Source/LinkApp/Supporting\ Files/Resource/en.lproj/InfoPlist.strings
fi

cat Source/LinkApp/Supporting\ Files/LinkAppCommon.xcconfig

#rm -rf Podfile.lock
#/usr/local/bin/pod install --verbose --no-repo-update
/usr/local/bin/pod --version
/usr/local/bin/pod install --verbose
 
BUILD_TYPE=$1

 
xcodebuild clean -workspace LinkApp.xcworkspace -scheme LinkApp -configuration Release
 
xcodebuild archive -workspace LinkApp.xcworkspace -scheme LinkApp -configuration Release -archivePath LinkApp.xcarchive -UseModernBuildSystem=NO
 
if [ $1 == 'Debug' ]; then
    xcodebuild -exportArchive -archivePath LinkApp.xcarchive -exportOptionsPlist .github/script/ExportOptionsDevelop.plist  -exportPath ./
else
    xcodebuild -exportArchive -archivePath LinkApp.xcarchive -exportOptionsPlist .github/script/ExportOptionsRelease.plist  -exportPath ./
fi
