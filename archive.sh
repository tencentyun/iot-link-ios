#!/bin/sh

#bin/bsah - l
rm -rf Podfile.lock
/usr/local/bin/pod install --verbose --no-repo-update
 
xcodebuild clean -workspace TenextCloud.xcworkspace -scheme TenextCloud -configuration Debug
 
xcodebuild archive -workspace TenextCloud.xcworkspace -scheme TenextCloud -configuration Debug -archivePath TenextCloud.xcarchive -UseModernBuildSystem=NO
 
 
xcodebuild -exportArchive -archivePath TenextCloud.xcarchive -exportOptionsPlist './ExportOptionsDevelop.plist'  -exportPath ./
 
