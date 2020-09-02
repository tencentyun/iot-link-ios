#
# Be sure to run `pod lib lint QIotLinkKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TIoTLinkKit'
  s.version          = ENV['LIB_VERSION'] || '1.0.0'
  s.summary          = '腾讯连连APP SDK是腾讯云物联网平台提供，应用开发厂商可通过SDK将设备接入腾讯云物联网平台，来进行设备管理'
  
  s.description      = <<-DESC
在腾讯云物联网开发平台中，APP通过接入APP SDK来实现与智能设备的配网，和通过物联网平台对智能设备进行管理。目前APP SDK中与设备配网方式提供了SmartConfig配网和Soft AP配网模式。
                       DESC

  s.homepage         = 'https://github.com/tencentyun/iot-link-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iot-ios-sdk' => 'dev@goodow.com' }
  s.source           = { :git => 'https://github.com/tencentyun/iot-link-ios.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '8.0'

  s.source_files  = 'Source/LinkSDK/**/*.{h,m,c}'
  s.dependency 'MBProgressHUD', '1.1.0'
end
