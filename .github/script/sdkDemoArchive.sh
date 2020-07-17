#!/bin/sh
 
xcodebuild clean -workspace LinkApp.xcworkspace -scheme LinkApp -configuration Debug
 
xcodebuild archive -workspace LinkApp.xcworkspace -scheme LinkSDKDemo -configuration Debug -archivePath LinkSDKDemo.xcarchive -UseModernBuildSystem=NO
 
xcodebuild -exportArchive -archivePath LinkSDKDemo.xcarchive -exportOptionsPlist .github/script/ExportOptionsSDKDemoDevelop.plist  -exportPath ./


 
