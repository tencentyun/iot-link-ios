#
# Be sure to run `pod lib lint QIotLinkKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TIoTLinkKit'
  s.version          = ENV['LIB_VERSION'] || '0.1.3'
  s.summary          = '腾讯连连APP SDK是腾讯云物联网平台提供，应用开发厂商可通过SDK将设备接入腾讯云物联网平台，来进行设备管理'
  
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/tencentyun/iot-link-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iot-ios-sdk' => 'dev@goodow.com' }
  s.source           = { :git => 'https://github.com/tencentyun/iot-link-ios.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '8.0'

  s.source_files  = 'Source/LinkSDK/**/*.{h,m,c}'
  s.dependency 'MBProgressHUD', '1.1.0'
end
