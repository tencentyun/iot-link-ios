#!/bin/sh
 
#rm -rf Podfile.lock
#/usr/local/bin/pod install --verbose --no-repo-update
#/usr/local/bin/pod install

rb=$GIT_BRANCH_IMAGE_VERSION
rc=$(git rev-parse --short HEAD)
sed -i "" "s/LinkSDKDemo_VERSION.*/LinkSDKDemo_VERSION = $rb+git.$rc/g" Source/LinkApp/Supporting\ Files/LinkAppCommon.xcconfig
    
xcodebuild clean -workspace TIoTLinkKit.xcworkspace -scheme LinkSDKDemo -configuration Release

xcodebuild archive -workspace TIoTLinkKit.xcworkspace -scheme LinkSDKDemo -configuration Release -archivePath LinkSDKDemo.xcarchive -UseModernBuildSystem=NO

xcodebuild -exportArchive -archivePath LinkSDKDemo.xcarchive -exportOptionsPlist .github/script/ExportOptionsSDKDemoDevelop.plist  -exportPath ./

#mv TIoTLinkKitDemo.ipa LinkSDKDemo.ipa
