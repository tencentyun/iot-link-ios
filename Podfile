platform :ios, '10.0'
#inhibit_all_warnings!
use_frameworks!

def common_all_pods
  pod 'Masonry', '1.1.0'
  pod 'SDWebImage', '4.4.2'
  pod 'YYModel', '1.0.4'
  pod 'QCloudCOSXML/Transfer', '5.5.2'
  pod 'Firebase/Analytics', '6.31.1'
  pod 'Firebase/Crashlytics', '6.31.1'
  pod 'Firebase/Performance', '6.31.1'
end

target 'LinkApp' do
  common_all_pods
  
  pod 'TIoTLinkKit', :path => './'
  pod 'TIoTLinkKit/LinkRTC', :path => './'
  pod 'MJRefresh', '3.2.0'
  pod 'IQKeyboardManager', '6.1.1'
  pod 'FDFullscreenPopGesture', '1.1'
  pod 'SocketRocket', '0.5.1'
  pod 'TZImagePickerController', '3.2.1'
  pod 'MGJRouter', '0.10.0'
  pod 'TrueTime','5.0.3'
  pod 'KeychainAccess', '4.2.0'
  pod 'Tencent-MapSDK', '4.3.9'
  pod 'lottie-ios', '3.1.8'
  pod 'TIoTThridSDK/TPNS-iOS', '1.0.6' #'~> 1.0.5-beta.1'
  pod 'TIoTThridSDK/WechatOpenSDK_NoPay', '1.0.6' #'~> 1.0.5-beta.1'#
end

target 'LinkSDKDemo' do
  common_all_pods
  
  pod 'TIoTLinkKit', :path => './'
  pod 'TIoTLinkKit/LinkRTC', :path => './'
  pod 'TIoTLinkKit/LinkVideo', :path => './'
end
