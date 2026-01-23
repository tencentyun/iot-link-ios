# iOS SDK 接入文档

## 1. 准备工作

### 1.1 获取SDK
从腾讯云物联网平台获取最新的 `TIoTLinkVideo` SDK 框架,最新版本 [在此获取](https://github.com/tencentyun/iot-link-ios/releases)
```
pod 'TIoTLinkVideo'
pod 'TIoTLinkKit_XP2P'
pod 'TIoTLinkKit_GVoiceSE'
pod 'TIoTLinkKit_IJKPlayer'
```

### 1.2 添加依赖
在项目中添加以下依赖：
- AVFoundation.framework
- CoreMedia.framework
- VideoToolbox.framework
- AudioToolbox.framework

## 2. 初始化配置

### 2.1 导入头文件
```objective-c
#import "TIoTCoreXP2PBridge.h"
#import "TIoTCoreAudioConfig.h"
#import "TIoTCoreVideoConfig.h"
```

### 2.2 配置P2P参数
```objective-c
TIoTP2PAPPConfig *config = [[TIoTP2PAPPConfig alloc] init];
config.appkey = @"您的appkey";  // 从腾讯云物联网平台获取,(https://console.cloud.tencent.com/iotexplorer/v2/instance/app/detai) explorer控制台- 应用开发 - 选对应的应用下的 appkey/appsecret
config.appsecret = @"您的appsecret"; // 从腾讯云物联网平台获取,(https://console.cloud.tencent.com/iotexplorer/v2/instance/app/detai) explorer控制台- 应用开发 - 选对应的应用下的 appkey/appsecret
config.xp2pinfo = @"设备的p2p_info"; // 设备端获取的p2p信息
config.autoConfigFromDevice = YES;   //配置是否跟随设备，如果存在同时连接多个设备时候，多个设备配置的双中转配置不同，就关闭此开关
```

## 3. 核心功能使用

### 3.1 启动服务
```objective-c
TIoTCoreXP2PBridge *bridge = [TIoTCoreXP2PBridge sharedInstance];
XP2PErrCode code = [bridge startAppWith:@"产品ID" dev_name:@"设备名称" appconfig:config];
if (code == XP2P_OK) {
    NSLog(@"启动成功");
}
```

### 3.2 视频直播
```objective-c
// 获取HTTP-FLV播放地址
NSString *httpflv = [bridge getUrlForHttpFlv:@"产品ID/设备名称"];

//1.获取httpflv的url,ipc拼接参数说明 直播拼接ipc.flv?action=live；本地回看拼接ipc.flv?action=playback，标清quality=standard，高清quality=high，超清quality=super
 NSString *videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=live&quality=high",httpflv];

// 使用播放器播放URL
```

### 3.3 语音对讲
```objective-c
AVAudioSession *avsession = [AVAudioSession sharedInstance];
[avsession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
[avsession setPreferredSampleRate:16000 error:nil];
[avsession setPreferredInputNumberOfChannels:audio_config.channels error:nil];
NSTimeInterval duration = 0.02;
[avsession setPreferredIOBufferDuration:duration error:nil];
[avsession setActive:YES error:nil];

// 配置音频参数
TIoTCoreAudioConfig *audioConfig = [[TIoTCoreAudioConfig alloc] init];
audioConfig.channels = 1; // 单声道
audioConfig.sampleRate = TIoTAVCaptionFLVAudio_16; // 16kHz采样率
audioConfig.isEchoCancel = YES; // 开启回音消除

// 配置视频参数
TIoTCoreVideoConfig *videoConfig = [[TIoTCoreVideoConfig alloc] init];
videoConfig.localView = self.previewView; // 本地预览视图，如果只有音频的话，此处传nil，就不会启动视频
videoConfig.videoPosition = AVCaptureDevicePositionFront; // 前置摄像头

// 开始对讲
[bridge sendVoiceToServer:@"产品ID/设备名称" channel:@"0" audioConfig:audioConfig videoConfig:videoConfig];

// 停止对讲
[bridge stopVoiceToServer];
```

### 3.4 设备信令交互,具体信令参数 [参考此处](https://cloud.tencent.com/document/product/1131/61744)
```objective-c
[bridge getCommandRequestWithAsync:@"产品ID/设备名称" cmd:@"action=inner_define&channel=0&cmd=get_device_st" timeout:2*1000*1000 completion:^(NSString *jsonList) {
    NSLog(@"收到设备回复: %@", jsonList);
}];
```

### 3.5 裸流数据接收
实现 `TIoTCoreXP2PBridgeDelegate` 协议：
```objective-c
- (void)getVideoPacketWithID:(NSString *)dev_name data:(uint8_t *)data len:(size_t)len {
    // 处理裸流数据 **谨慎！！！ 此接口切勿执行耗时操作，耗时操作请切换线程，切勿卡住当前线程**
}

// 开始接收裸流
bridge.delegate = self;
[bridge startAvRecvService:@"产品ID/设备名称" cmd:@"action=live"];

// 停止接收裸流
[bridge stopAvRecvService:@"产品ID/设备名称"];
```

## 4. 高级功能

### 4.1 自定义采集编码
```objective-c
// 音频配置
TIoTCoreAudioConfig *audioConfig = [[TIoTCoreAudioConfig alloc] init];
audioConfig.isExternal = YES; // 开启外部采集

// 视频配置
TIoTCoreVideoConfig *videoConfig = [[TIoTCoreVideoConfig alloc] init];
videoConfig.isExternal = YES; // 开启外部采集

// 启动服务后发送自定义数据
NSData *audioData = ...; // 自定义采集的AAC数据
[bridge SendExternalAudioPacket:audioData];

NSData *videoData = ...; // 自定义采集的H264数据
[bridge SendExternalVideoPacket:videoData];
```

### 4.2 直播秒开以及减小延时模式
```objective-c
IJKFFOptions *options = [IJKFFOptions optionsByDefault];        
self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrl] withOptions:options];
[self.player setOptionIntValue:25 * 1024 forKey:@"probesize" ofCategory:kIJKFFOptionCategoryFormat];
[self.player setOptionIntValue:0 forKey:@"packet-buffering" ofCategory:kIJKFFOptionCategoryPlayer];
[self.player setOptionIntValue:1 forKey:@"start-on-prepared" ofCategory:kIJKFFOptionCategoryPlayer];
[self.player setOptionIntValue:1 forKey:@"threads" ofCategory:kIJKFFOptionCategoryCodec];
[self.player setOptionIntValue:0 forKey:@"sync-av-start" ofCategory:kIJKFFOptionCategoryPlayer];
[self.player setOptionIntValue:1 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
[self.player prepareToPlay];
[self.player play];
```

## 5. 注意事项

1. 所有操作必须在 `TIoTCoreXP2PBridgeNotificationReady` 通知之后进行
2. 语音对讲和视频通话需要麦克风和摄像头权限
3. 建议在后台停止视频流传输以节省电量
4. 自适应码率逻辑可参考SDK中的实现

## 6. 错误处理

监听以下通知处理异常情况：
```objective-c
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleXP2PNotification:) name:TIoTCoreXP2PBridgeNotificationReady object:nil];
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleXP2PNotification:) name:TIoTCoreXP2PBridgeNotificationDisconnect object:nil];
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleXP2PNotification:) name:TIoTCoreXP2PBridgeNotificationDetectError object:nil];
```

## 7. 版本信息

```objective-c
NSString *version = [TIoTCoreXP2PBridge getSDKVersion];
NSLog(@"当前SDK版本: %@", version);
```	
	
	
## 8. 事例Demo
[示例代码](https://github.com/tencentyun/iot-link-ios/blob/video-v2.4.x/Source/LinkSDKDemo/Video/P2P/Controller/TIoTDemoPreviewDeviceVC.m)
