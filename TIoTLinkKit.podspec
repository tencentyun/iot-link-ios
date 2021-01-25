
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

  s.ios.deployment_target = '10.0'
  s.static_framework = true

  s.default_subspec = 'LinkSDK'
  
  s.subspec 'LinkSDK' do |ss|
    ss.source_files  = 'Source/SDK/LinkSDK/**/*.{h,m,c}'
    ss.dependency 'MBProgressHUD', '1.1.0'
  end
  
  #实时音视频，引入则开启
  s.subspec 'LinkRTC' do |ss|
    ss.source_files  = 'Source/SDK/LinkRTC/**/*.{h,m,c}'
    ss.dependency 'TXLiteAVSDK_TRTC', '8.0.9644'
    ss.dependency 'YYModel'
    ss.dependency 'TIoTLinkKit/LinkSDK'
    ss.pod_target_xcconfig = {
      'VALID_ARCHS'  => 'x86_64 armv7 arm64',
    }
  end

  #智能视频服务，引入则开启 TODO
  s.subspec 'LinkVideo' do |ss|
    ss.source_files  = 'Source/SDK/LinkVideo/**/*.{h,m,c,mm}'
    ss.dependency 'TIoTLinkKit/LinkSDK'
    ss.dependency 'TIoTThridSDK/FFmpeg-iOS'
    ss.dependency 'TIoTThridSDK/XP2P-iOS'
    ss.pod_target_xcconfig = {
      'VALID_ARCHS'  => 'arm64'
    }
  end

end
