## 概述
在用户接入物联网开发中心服务后，有时会有手表设备与App通话需求，本文档帮助iOS客户端用户在已经接入 物联网开发中心 服务后，更好的对实时音视频（Tencent RTC）服务进行接入，通过当前SDK无需关心实时音视频部分代码实现逻辑即可接入服务。

## iOS 接入流程

1. 首先通过Cocopods方式集成SDK，具体版本号可参考 [explorer-link-trtc](https://cloud.tencent.com/document/product/1081/50893)  [explorer-link-ios](https://cloud.tencent.com/document/product/1081/47787)

	```
	pod 'TIoTLinkKit/TRTC'
	```
  
2. 通过以下两种方式接入

    **基于 App 开源版**

    * 将 呼叫页面 与 被呼叫页面的 UI部分放入自己的工程中。[UI界面参考](https://github.com/tencentyun/iot-link-ios/tree/master/Source/LinkSDK/TRTC/ui) 和 [TRTC管理代码参考](https://github.com/tencentyun/iot-link-ios/blob/master/Source/LinkApp/Classes/Universal/WebSocket/TIoTTRTCUIManage.m)
    * 在 [TRTC管理代码参考](https://github.com/tencentyun/iot-link-ios/blob/master/Source/LinkApp/Classes/Universal/WebSocket/TIoTTRTCUIManage.m) 中提供了三个接口

        ```
        //主动呼叫设备，区分 audio 和 video 类型 。（设备控制面板中触发）
        - (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo;
		
        //App被呼叫。在收到websocket消息时候，判断是TRTC设备需要调此方法。参考App调用方式（在TIoTWebSocketManage.m文件中）
        - (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;
		
        //遍历TRTC设备状态，查看TRTC设备是否有呼叫App。参考App调用方式，从后台进入前台触发，首次拉取到首页设备列表触发
        - (void)repeatDeviceData:(NSArray *)devices;
		
		 //在被呼叫状态中，UI同意呼叫后触发。参考此方法
        - (void)didAcceptJoinRoom;
        ```
    * 需实现的协议有，远端用户进入房间的协议，以及退出房间的处理

        ```
		
        //远端用户进入房间的协议，需更改UI展示状态，包含主动呼叫和被呼叫
        - (void)showRemoteUser:(NSString *)remoteUserID;
		
        //退出房间，释放UI资源
        - (void)exitRoom:(NSString *)remoteUserID;
		
        ```       

    **基于App SDK**

    * 将 呼叫页面 与 被呼叫页面的 UI部分放入自己的工程中。[UI界面参考](https://github.com/tencentyun/iot-link-ios/tree/master/Source/LinkSDK/TRTC/ui) 
    * 参考在 SDKDemo中 [实现的协议 与 主动呼叫被呼叫](https://github.com/tencentyun/iot-link-ios/blob/master/Source/LinkSDKDemo/Home/Controllers/Device/ControlDeviceVC.m)

        ```
        //主动呼叫设备，区分 audio 和 video 类型 。（设备控制面板中触发）
        - (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo;
		
        //App被呼叫。
        - (BOOL)isActiveCalling:(NSString *)deviceUserID ;
		
		
		 //在被呼叫状态中，UI同意呼叫后触发。参考此方法
        - (void)didAcceptJoinRoom;


		 //需要实现的协议		
        //远端用户进入房间的协议，需更改UI展示状态，包含主动呼叫和被呼叫
        - (void)showRemoteUser:(NSString *)remoteUserID;
		
        //退出房间，释放UI资源
        - (void)exitRoom:(NSString *)remoteUserID;
		
        ```
    * 需自行实现遍历TRTC设备状态、信鸽推送通知的逻辑，当有推送通知到达后，触发遍历TRTC设备状态。
