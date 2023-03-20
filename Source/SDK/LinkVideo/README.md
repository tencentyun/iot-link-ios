### 概述
Video SDK 主要提供了 APP 端 P2P 接入、实时监控、语音对讲、本地回放等基本能力。


## iOS 接入流程

1、在 App 的 Podfile 文件中添加如下依赖项

```
pod 'TIoTLinkVideo'
```
具体版本号可参考 [LinkVideo](TODO: sdk发布页url)


2、运行SDKDemo 

* 打开Xcode，选择 Target --> LinkSDKDemo
* 需要在 [AppDelegate.m](../../LinkSDKDemo/Supporting%20Files/AppDelegate.m#L38~L40) 中，配置 SecretId、SecretKey、ProductId；
* <u>***SecretId、SecretKey、ProductId 用于访问 物联网智能视频服务，此处的使用方式仅为演示，请勿将 SecretId、SecretKey 保存在客户端，避免泄露***</u>


3、2.6.x版本集成接口说明

* [事例代码](https://github.com/tencentyun/iot-link-ios/blob/88c756ce41f72090f5a892cd130da49cabf4a3a7/Source/LinkSDKDemo/Video/P2P/Controller/TIoTDemoPreviewDeviceVC.m#L149-L153)，运行demo需要在 [AppDelegate.m](../../LinkSDKDemo/Supporting%20Files/AppDelegate.m#L38~L40) 中，配置 SecretId、SecretKey、ProductId；
* 1、SDK 接入后，需先通过[云API](https://github.com/tencentyun/iot-link-ios/blob/88c756ce41f72090f5a892cd130da49cabf4a3a7/Source/LinkSDKDemo/Video/P2P/Controller/TIoTDemoPreviewDeviceVC.m#L1603-L1636)获取到TRTCParams参数后，

	```
	//开始拨打设备，请求云API后，start SDK后，设备即可收到呼叫信息
	[TIoTCoreXP2PBridge sharedInstance].params = XXX;
	[[TIoTCoreXP2PBridge sharedInstance] startAppWith:env.cloudProductId dev_name:self.deviceName?:@""];
	```
* <u>***SecretId、SecretKey、ProductId 用于访问 物联网智能视频服务，此处的使用方式仅为演示，请勿将 SecretId、SecretKey 保存在客户端，避免泄露，建议通过自建服务获取 params 传递给 SDK***</u>
* 2、设备接听后，APP通过信令通道接受接听或拒绝消息（可自定义信令含义，demo演示为接收到消息表示接听）

	```
	#pragma mark - TIoTCoreXP2PBridgeDelegate
	- (NSString *)reviceDeviceMsgWithID:(NSString *)dev_name data:(NSData *)data {
		   dispatch_async(dispatch_get_main_queue(), ^{
		   	   //接收到设备接听的消息，开始推流
		   });
	}

	//开始推流
	TIoTCoreVideoConfig *video_config = [TIoTCoreVideoConfig new];
	video_config.localView = weakSelf.imageView;
	video_config.remoteView = weakSelf.remoteView;
	video_config.videoPosition = AVCaptureDevicePositionFront;
                
	[[TIoTCoreXP2PBridge sharedInstance]sendVoiceToServer:weakSelf.deviceName?:@"" channel:channel audioConfig:audio_config videoConfig:video_config];
	```
* 3、SDK 其他功能接口

	```
	//刷新本地预览UI接口
	- (void)refreshLocalView:(UIView *)localView;
	//设置听筒还是扬声器模式，yes=扬声器，no=听筒
	- (void)setAudioRoute:(BOOL)isHandsFree ;
	//静音或恢复音频   
	- (void)muteLocalAudio:(BOOL)mute;
	```

* 4、结束通话：

	主动结束： [stopService](https://github.com/tencentyun/iot-link-ios/blob/4e322172a949725f7d6ea4a1daa17a288cbc00e6/Source/SDK/LinkVideo/TIoTCoreXP2PBridge.h#L147-L150)  
	对方结束： [disConnect通知](https://github.com/tencentyun/iot-link-ios/blob/4e322172a949725f7d6ea4a1daa17a288cbc00e6/Source/LinkSDKDemo/Video/P2P/Controller/TIoTDemoPreviewDeviceVC.m#L1151-L1155)



### SDK相关文档
* [iOS SDK说明](doc/iOS%20Video接入指引文档.md)
* [PC 观看端直播场景延时优化](doc/win%20观看端直播场景延时优化.md)
* [双向音视频延时测试](doc/双向音视频延时测试.md)
* [双向通话延时参数说明](doc/双向延时参数说明.md)
* [双向码率自适应说明](doc/双向码率自适应.md)
* [双向通话断网流程](doc/双向通话断网流程.md)