
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

  s.default_subspec = 'CoreBase'
  
  s.subspec 'CoreBase' do |ss|
    ss.source_files  = 'Source/LinkSDK/QCAPISets/**/*.{h,m,c}', 'Source/LinkSDK/QCDeviceCenter/**/*.{h,m,c}', 'Source/LinkSDK/QCFoundation/**/*.{h,m,c}'
    ss.dependency 'MBProgressHUD', '1.1.0'
  end
  
  #实时音视频，引入则开启
  s.subspec 'TRTC' do |ss|
    ss.source_files  = 'Source/LinkSDK/TRTC/**/*.{h,m,c}'
    ss.dependency 'TXLiteAVSDK_TRTC'#, '7.9.9565'
    ss.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
  end

end
