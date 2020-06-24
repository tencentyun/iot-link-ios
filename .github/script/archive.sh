#!/bin/sh

#bin/bsah - l

rc=$(git rev-parse --short HEAD)
#echo $rc
sed -i "" '/LinkAPP_VERSION/ s/$/.'$rc'/' LinkApp/Supporting\ Files/LinkApp.xcconfig

rm -rf Podfile.lock
/usr/local/bin/pod install --verbose --no-repo-update
 
xcodebuild clean -workspace LinkApp.xcworkspace -scheme LinkApp -configuration Debug
 
xcodebuild archive -workspace LinkApp.xcworkspace -scheme LinkApp -configuration Debug -archivePath LinkApp.xcarchive -UseModernBuildSystem=NO
 
 
xcodebuild -exportArchive -archivePath LinkApp.xcarchive -exportOptionsPlist .github/script/ExportOptionsDevelop.plist  -exportPath ./
 
