### 概述
IoTVideoCloud SDK 主要提供了 APP 端与设备通话、信令发送接收等基本能力。


## IoTVideoCloud 客户SDK（iOS）开发指南

1、在 App 的 Podfile 文件中添加如下依赖项

```
pod 'IoTVideoCloud'
```
具体版本号可参考 [LinkVideo](https://github.com/tencentyun/iot-link-ios/releases)


2、运行SDKDemo 

* [获取源码分支 video-v2.6.x](https://github.com/tencentyun/iot-link-ios/tree/video-v2.6.x)
* 打开Xcode，选择 Target --> LinkSDKDemo
* 运行demo需要在 [AppDelegate.m](../../LinkSDKDemo/Supporting%20Files/AppDelegate.m#L38~L44) 中，配置 SecretId、SecretKey、ProductId；
* <u>***SecretId、SecretKey、ProductId 用于访问 物联网智能视频服务，此处的使用方式仅为演示，请勿将 SecretId、SecretKey 保存在客户端，避免泄露***</u>


3、2.6.x版本集成接口说明

* 1、RTC模式下 拨打呼叫流程，需先通过 [云API](https://github.com/tencentyun/iot-link-ios/blob/88c756ce41f72090f5a892cd130da49cabf4a3a7/Source/LinkSDKDemo/Video/P2P/Controller/TIoTDemoPreviewDeviceVC.m#L1603-L1636) 获取到TRTCParams参数后，`startAppWith`接口开始呼叫对应设备 [事例代码](https://github.com/tencentyun/iot-link-ios/blob/96810ec2629cfe9d7e5a63235eba8f4507a7e7e1/Source/LinkSDKDemo/Video/P2P/Controller/TIoTDemoPreviewDeviceVC.m#L152-L171)

	```
	//开始拨打设备，请求云API后，start SDK后，设备即可收到呼叫信息
	[IoTVideoCloud sharedInstance].delegate = self;
	
	IoTVideoParams *videoparams = [IoTVideoParams new];
	videoparams.productid = self.productId;
	videoparams.devicename = self.deviceName;
	videoparams.rtcparams = TRTCParams;

	//audio参数配置
	videoparams.audioConfig = audio_config;

	//video参数配置
	TIoTCoreVideoConfig *video_config = [TIoTCoreVideoConfig new];
	video_config.localView = self.imageView;
	video_config.remoteView = self.remoteView;
	videoparams.videoConfig = video_config;
	
	[[IoTVideoCloud sharedInstance] startAppWith:videoparams];
	```
	P2P模式下初始化，需先通过 [云API](https://github.com/tencentyun/iot-link-ios/blob/96810ec2629cfe9d7e5a63235eba8f4507a7e7e1/Source/LinkSDKDemo/Video/P2P/Mjpeg/TIoTDemoPreviewP2PVC.m#L192-L210) 获取到XP2PInfo 参数后，`startAppWith` 接口开始启动连接服务，待拉流时候触发连接设备 ，其他接口均和 RTC模式一致
		```
	//开始拨打设备，请求云API后，start SDK后，设备即可收到呼叫信息
	[IoTVideoCloud sharedInstance].delegate = self;
	
	IoTVideoParams *videoparams = [IoTVideoParams new];
	videoparams.productid = self.productId;
	videoparams.devicename = self.deviceName;
	videoparams.xp2pinfo = xp2pInfo;

	//audio参数配置
	videoparams.audioConfig = audio_config;

	//video参数配置
	TIoTCoreVideoConfig *video_config = [TIoTCoreVideoConfig new];
	video_config.localView = self.imageView;
	video_config.remoteView = self.remoteView;
	videoparams.videoConfig = video_config;
	
	[[IoTVideoCloud sharedInstance] startAppWith:videoparams];
	```
* <u>***SecretId、SecretKey、ProductId 用于访问 物联网智能视频服务，此处的使用方式仅为演示，请勿将 SecretId、SecretKey 保存在客户端，避免泄露，建议通过自建服务获取 params 传递给 SDK***</u>
* 2、设备接听后流程，APP通过信令通道接受接听或拒绝消息（可自定义信令含义，demo演示为接收到消息表示接听）

	```
	#pragma mark - IoTVideoCloudDelegate
	- (NSString *)reviceDeviceMsgWithID:(NSString *)dev_name data:(NSData *)data {
	   dispatch_async(dispatch_get_main_queue(), ^{
	   	   //接收到设备接听的消息，开始推流
		});
	}

	//开始拉流（RTC模式会自动拉流无需调用
	//P2P模式需通过此接口获取url后，塞给ijkplayer拉流）
	NSString *urlString = [[IoTVideoCloud sharedInstance] startRemoteStream:self.deviceName];

	//开始推流
	[[IoTVideoCloud sharedInstance] startLocalStream:weakSelf.deviceName];
	```
* 3、SDK 其他功能接口

	```
	/*
	 * 发送信令接口,需startAppWith后再发送
	 * 参数cmd发送具体信令内容
	 * 每秒最多能发送30条消息。每个包最大为 1KB，超过则很有可能会被中间路由器或者服务器丢弃。每个客户端每秒最多能发送总计 8KB 数据。
	 */
	- (void)sendCustomCmdMsg:(NSString *)dev_name cmd:(NSString *)cmd ...;
	
	//刷新本地预览UI接口
	- (void)refreshLocalView:(UIView *)localView;
	//设置听筒还是扬声器模式，yes=扬声器，no=听筒
	- (void)setAudioRoute:(BOOL)isHandsFree ;
	//切换前后摄像头
	- (void)changeCameraPositon;
	//静音或恢复音频   
	- (void)muteLocalAudio:(BOOL)mute;
	```

* 4、结束通话：

	主动结束： [stopAppService](https://github.com/tencentyun/iot-link-ios/blob/96810ec2629cfe9d7e5a63235eba8f4507a7e7e1/Source/SDK/LinkVideo/IoTVideoCloud.h#L104-L107)  
	对方结束（两种方式任选一个）： 
		1、[断开的通知 TIoTCoreXP2PBridgeNotificationDisconnect](https://github.com/tencentyun/iot-link-ios/blob/96810ec2629cfe9d7e5a63235eba8f4507a7e7e1/Source/SDK/LinkVideo/IoTVideoCloud.h#L16)
		2、[事件代理回调 RTCTypeDisconnect](https://github.com/tencentyun/iot-link-ios/blob/96810ec2629cfe9d7e5a63235eba8f4507a7e7e1/Source/SDK/LinkVideo/IoTVideoCloud.h#L50-L53)



