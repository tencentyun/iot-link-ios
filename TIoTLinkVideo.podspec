
Pod::Spec.new do |s|
  s.name             = 'TIoTLinkVideo'
  s.version          = ENV['LIB_VERSION'] || '1.0.0'
  s.summary          = '腾讯连连Video SDK是腾讯云物联网平台提供，应用开发厂商可通过该 SDK 快速搭建起 OEM 版本 APP，进行物联网音视频业务开发'
  
  s.description      = <<-DESC
在腾讯云物联网开发平台中，APP通过接入Video SDK来实现与智能IPC设备的连接，和通过物联网平台对智能IPC设备进行管理。
                       DESC

  s.homepage         = 'https://github.com/tencentyun/iot-link-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iot-ios-sdk' => 'dev@goodow.com' }
  s.source           = { :git => 'https://github.com/tencentyun/iot-link-ios.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '9.0'
  s.static_framework = true

  s.source_files  = 'Source/SDK/LinkVideo/**/*.{h,m,c,mm}'

  s.dependency 'TIoTLinkKit_XP2P', '2.4.23' #~> 2.4.21-beta.202202101145  
  s.dependency 'TIoTLinkKit_FLV', '2.2.3'
  s.dependency 'CocoaAsyncSocket', '7.6.5'
  
  s.pod_target_xcconfig = {
    'VALID_ARCHS'  => 'arm64'
  }

end
