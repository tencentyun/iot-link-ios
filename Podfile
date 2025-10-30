platform :ios, '9.0'
#inhibit_all_warnings!
use_frameworks!
source 'https://cdn.cocoapods.org/'
# source 'https://github.com/tencentyun/iot-thirdparty-ios.git'
#source 'https://github.com/CocoaPods/Specs.git'

def common_all_pods
  pod 'Masonry', '1.1.0'
  pod 'MBProgressHUD', '1.1.0'
  pod 'SDWebImage', '4.4.2'
  pod 'YYModel', '1.0.4'
  pod 'QCloudCOSXML/Transfer', '5.5.2'
  pod 'CocoaLumberjack', '3.7.2'
  pod 'WechatOpenSDK-XCFramework', '2.0.4'
end


target 'LinkSDKDemo' do
  common_all_pods
  
  pod 'IoTVideoCloud', :podspec => 'https://raw.githubusercontent.com/tencentyun/iot-thirdparty-ios/master/IoTVideoCloud.podspec'
#  pod 'IoTVideoCloud', :path => './IoTVideoCloud.podspec'
  
end

#older OS versions does not contain 'libarclite', at least iOS 11
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "12.0"
    end
  end
end
