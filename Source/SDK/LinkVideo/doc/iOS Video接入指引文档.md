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
	
   //2.配置IOT_P2P SDK,demoapp作为演示需要配置第二步，客户正式发布的app不建议配置第二步，需通过自建业务服务获取xp2pInfo传入第三步的参数中
   setQcloudApiCred(sec_id, sec_key);   //正式版app发布时候需要去掉，避免泄露secretid和secretkey，此处仅为演示

	//3.启动p2p通道,此处id参数传入了dev_name，用户也可以维护一套自己区分不同设备的id;最后的参数在正式发布版本中需传xp2p_info，所有接口的参数含义可以参考本文档最底下链接
   startServiceWithXp2pInfo(dev_name, pro_id, dev_name, "");
	
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/SDK/LinkVideo/TIoTCoreXP2PBridge.mm)

	**注意事项：**
	
	* 此处的产品ID和腾讯云官网的secretID和secretKey需在物联网智能视频服务（消费版）控制台中查看访问密钥
	
	* demo app为了获取设备列表，需要客户填写腾讯云api的密钥，获取的设备信息是客户该产品所有的设备，不区分C端用户，真实使用场景是希望获取设备列表的操作在客户自建后台进行的，云api的secretID、secretKey不保存在app上，避免泄露风险



* P2P通道传输音视频流

	```
	//1.开始接受裸流数据,参数说明:cmd直播传action=live，回放action=playback
	
	const char *cmd = "action=live"; false表示音视频数据不加密
	startAvRecvService(dev_name, cmd, false);
	
	//2.通过初始化p2p回调返回
	void XP2PDataMsgHandle(const char *idd, uint8_t* recv_buf, size_t recv_len) {
	   ...处理接收到的裸流数据，此处idd为传入的dev_name,用于区分传入的不同设备
	}
	
	//3.结束裸流数据
	stopAvRecvService(dev_name, nullptr);
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/SDK/LinkVideo/TIoTCoreXP2PBridge.mm)

* 接收FLV音视频流，使用ijkplayer播放

	```
	//1.获取httpflv的url,ipc拼接参数说明 直播拼接ipc.flv?action=live；本地回看拼接ipc.flv?action=playback，参数为区分设备id，当前使用dev_name区分不同设备，其他接口需保持统一的区分规则
	const char *httpflv = delegateHttpFlv(dev_name);
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
	//1.准备开始发送对讲voice数据, false表示音视频数据不加密传输，true加密传输；中间的参数为预留参数传空
	runSendService(dev_name, "", false);
	
	//2.开始发送app采集到的音频数据,此处demo发送的音频格式为flv,传输的id会区分传输到某个对应的设备
	dataSend("dev_name", pcm, pcm_size);
	```


* P2P通道传输自定义数据
	
	```
	NSString *cmd = @"action=user_define&cmd=custom_cmd"；
	uint64_t timeout = 2*1000*1000； //2秒超时
	
	char *buf = nullptr; //返回值
	size_t len = 0;
	getCommandRequestWithSync(dev_name, cmd.UTF8String, &buf, &len, timeout);
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/SDK/LinkVideo/TIoTCoreXP2PBridge.mm)


* 主动关闭P2P通道

	```
	stopService(dev_name);
	```

* P2P通道关闭回调
	
	```
	//type参数请参考头文件里XP2PType的类型表示，此处idd参数为区分不同设备回调
	char* XP2PMsgHandle(const char *idd, XP2PType type, const char* msg) {
	  if(type == XP2PTypeDisconnect){
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
	[[TIoTCoreXP2PBridge sharedInstance] startAvRecvService:dev_name, cmd:@"action=live"];
	
	//通过TIoTCoreXP2PBridgeDelegate返回裸流数据
	[TIoTCoreXP2PBridge sharedInstance].delegate = self
	- (void)getVideoPacket:(uint8_t *)data len:(size_t)len{
	   ...处理接收到的裸流数据
	}
	
	//结束裸流传输
	[[TIoTCoreXP2PBridge sharedInstance] stopAvRecvService:dev_name];
	```

* 接收FLV音视频流，使用ijkplayer播放
	
	```
	//1.获取httpflv的url,ipc拼接参数说明 直播拼接ipc.flv?action=live；本地回看拼接ipc.flv?action=playback
	NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:dev_name]?:@"";
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
	[[TIoTCoreXP2PBridge sharedInstance] sendVoiceToServer:dev_name];
	
	//结束对讲
	[[TIoTCoreXP2PBridge sharedInstance] stopVoiceToServer];
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/LinkSDKDemo/Home/Controllers/Device/TIoTPlayMovieVC.m)

* P2P通道传输自定义数据
	
	```
	// 发送自定义数据
	[[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:dev_name cmd:@"action=user_define&cmd=custom_cmd" timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
	 ...处理返回的数据
	}];
	```

* 主动关闭P2P通道,参数为区分停止某个设备的通道

	```
	[[TIoTCoreXP2PBridge sharedInstance] stopService:dev_name];
	```

* P2P通道关闭回调

	```
	//type=XP2PTypeDisconnect 表示p2p通道断开
	char* XP2PMsgHandle(const char *idd, XP2PType type, const char* msg) {
	  if(type == XP2PTypeDisconnect){
	    //断开p2p通道
	  }
	}
	```
	[示例代码](https://github.com/tencentyun/iot-link-ios/blob/master/Source/SDK/LinkVideo/TIoTCoreXP2PBridge.mm)


### Video SDK 多路视频观看接口说明

*  多路视频可通过各接口的id区分不同设备。当前的 iOS 层接口采用设备名称（dev_name）区分不同的设备通道。
*  用户也可通过接入 c++ 版本 sdk后， 采用自己的 ID 区分不同设备，自定义 ID 列表需自己维护管理


### Video SDK接口参数说明

*  [各接口参数说明指引](https://github.com/tonychanchen/TIoTThridSDK/blob/master/TIoTThridSDK/XP2P-iOS/Classes/AppWrapper.h)