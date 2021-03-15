## iOS Video接入手册

### 快速开始

#####  使用 C++ 版本 .a 库方法

* 库git地址：
  
   https://github.com/tonychanchen/TIoTThridSDK/tree/master/TIoTThridSDK/XP2P-iOS

* 工程如何引用： 
 
   将所有.a与AppWrapper.h 加入工程中，加入libc++, libsqlite3, libz系统库

##### 使用iOS库方法

* 库git地址：

  https://github.com/tencentyun/iot-link-ios

* 工程如何引用：

  pod 'TIoTLinkKit/LinkVideo


### P2P通道传输数据

##### C++ 版本的 .a 库调用方法

*  P2P通道初始化

	```
	//1.注册回调
	setUserCallbackToXp2p(XP2PDataMsgHandle, XP2PMsgHandle);
	
	//2.配置IOT_P2P SDK
	setQcloudApiCred([sec_id UTF8String], [sec_key UTF8String]);
	setDeviceInfo([pro_id UTF8String], [dev_name UTF8String]);
	setXp2pInfoAttributes("_sys_xp2p_info");
	
	//3.启动p2p通道，demoapp作为演示需要配置第二步，客户正式发布的app不建议配置第二步，需通过自建业务服务获取xp2pInfo传入第三步的参数中
	startServiceWithXp2pInfo("");
	
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/SDK/LinkVideo/TIoTCoreXP2PBridge.mm)

	**注意事项：**
	
	* 此处的产品ID和腾讯云官网的secretID和secretKey需在物联网智能视频服务（消费版）控制台中查看访问密钥
	
	* demo app为了获取设备列表，需要客户填写腾讯云api的密钥，获取的设备信息是客户该产品所有的设备，不区分C端用户，真实使用场景是希望获取设备列表的操作在客户自建后台进行的，云api的secretID、secretKey不保存在app上，避免泄露风险



* P2P通道传输音视频流

	```
	//1.开始接受裸流数据,参数说明:cmd直播传action=live，回放action=playback
	
	const char *cmd = "action=live"
	startAvRecvService(cmd);
	
	//2.通过初始化p2p回调返回
	voidXP2PDataMsgHandle(uint8_t* recv_buf, size_t recv_len) {
	   ...处理接收到的裸流数据
	}
	
	//3.结束裸流数据
	stopAvRecvService(nullptr);
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/SDK/LinkVideo/TIoTCoreXP2PBridge.mm)

* 接收FLV音视频流，使用ijkplayer播放

	```
	//1.获取httpflv的url,ipc拼接参数说明 直播拼接ipc.flv?action=live；本地回看拼接ipc.flv?action=playback
	const char *httpflv = delegateHttpFlv();
	NSString *videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=live",httpflv];
	
	//2.使用ijkplayer播放器播放
	[IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
	IJKFFOptions *options = [IJKFFOptions optionsByDefault];
	self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURLURLWithString:videoUrl] withOptions:options];
	self.player.view.frame = self.view.bounds;
	self.player.shouldAutoplay = YES;
	[self.view addSubview:self.player.view];
	[self.player prepareToPlay];
	[self.player play];
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/SDK/LinkVideo/TIoTCoreXP2PBridge.mm)

* 发送语音对讲数据
	
	```
	//1.准备开始发送对讲voice数据
	runSendService();
	
	//2.开始发送app采集到的音频数据,此处demo发送的音频格式为flv
	dataSend(pcm, pcm_size);
	```


* P2P通道传输自定义数据
	
	```
	NSString *cmd = @"action=user_define&cmd=custom_cmd"；
	uint64_t timeout = 2*1000*1000； //2秒超时
	
	char *buf = nullptr; //返回值
	size_t len = 0;
	getCommandRequestWithSync(cmd.UTF8String,&buf,&len,timeout);
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/SDK/LinkVideo/TIoTCoreXP2PBridge.mm)


* 主动关闭P2P通道

	```
	stopService();
	```

* P2P通道关闭回调
	
	```
	//type=0:close通知； type=1:日志； type=2:json; type=3:文件开关; type=4:文件路径;type=5:p2p通道断开
	char* XP2PMsgHandle(int type, constchar* msg) {
	  if(type == 5){
	    //断开p2p通道
	  }
	}
	```

##### iOS库调用方法
* P2P通道初始化
	
	```
	[[TIoTCoreXP2PBridge sharedInstance] startAppWith:@"" sec_key:@"" pro_id:@"" dev_name:@""];
	```
	**注意事项：**

	* demo app为了获取设备列表，需要客户填写腾讯云api的密钥，获取的设备信息是客户该产品所有的设备，不区分C端用户，真实使用场景是希望获取设备列表的操作在客户自建后台进行的，云api的secretID、secretKey不保存在app上，避免泄露风险

* P2P通道传输音视频流
	
	```
	//1.开始接受裸流数据,参数说明:cmd直播传action=live，回放action=playback
	[[TIoTCoreXP2PBridge sharedInstance] startAvRecvService:@"action=live"];
	
	//通过TIoTCoreXP2PBridgeDelegate返回裸流数据
	[TIoTCoreXP2PBridge sharedInstance].delegate = self
	- (void)getVideoPacket:(uint8_t *)data len:(size_t)len{
	   ...处理接收到的裸流数据
	}
	
	//结束裸流传输
	[[TIoTCoreXP2PBridge sharedInstance] stopAvRecvService];
	```

* 接收FLV音视频流，使用ijkplayer播放
	
	```
	//1.获取httpflv的url,ipc拼接参数说明 直播拼接ipc.flv?action=live；本地回看拼接ipc.flv?action=playback
	NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv]?:@"";
	NSString *videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=playback",urlString];
	
	//2.使用ijkplayer播放器播放
	self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videoUrl] withOptions:options];
	self.player.shouldAutoplay = YES;
	[self.player prepareToPlay];
	[self.player play];
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/LinkSDKDemo/Home/Controllers/Device/TIoTPlayMovieVC.m)

* 发送语音对讲数据
	
	```
	//开始对讲
	[[TIoTCoreXP2PBridge sharedInstance] sendVoiceToServer];
	
	//结束对讲
	[[TIoTCoreXP2PBridge sharedInstance] stopVoiceToServer];
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/LinkSDKDemo/Home/Controllers/Device/TIoTPlayMovieVC.m)

* P2P通道传输自定义数据
	
	```
	// 发送自定义数据
	[[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:@"action=user_define&cmd=custom_cmd" timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
	 ...处理返回的数据
	}];
	```

* 主动关闭P2P通道

	```
	[[TIoTCoreXP2PBridge sharedInstance] stopService];
	```

* P2P通道关闭回调

	```
	//type=0:close通知； type=1:日志； type=2:json; type=3:文件开关; type=4:文件路径;type=5:p2p通道断开
	char* XP2PMsgHandle(int type, constchar* msg) {
	  if(type == 5){
	    //断开p2p通道
	  }
	}
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/SDK/LinkVideo/TIoTCoreXP2PBridge.mm)



