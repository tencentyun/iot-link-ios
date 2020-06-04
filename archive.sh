#!/bin/sh

#bin/bsah - l
 
xcodebuild clean -workspace TenextCloud.xcworkspace -scheme TenextCloud -configuration Debug
 
xcodebuild archive -workspace TenextCloud.xcworkspace -scheme TenextCloud -configuration Debug -archivePath TenextCloud.xcarchive -UseModernBuildSystem=NO
 
 
xcodebuild -exportArchive -archivePath TenextCloud.xcarchive -exportOptionsPlist './ExportOptionsDevelop.plist'  -exportPath ./
 
