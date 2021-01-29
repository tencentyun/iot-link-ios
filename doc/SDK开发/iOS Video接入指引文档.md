## iOS Video接口使用说明

### 版本信息
* 版本:v1.0
* 修改内容:
    * 初始版本
* 修改时间:2021.01.15
---------------------------

### 接口说明
[[TIoTCoreXP2PBridge sharedInstance] startAppWith:@"" sec_key:@"" pro_id:@"" dev_name:@""];

* 函数说明:初始化app上的p2p通道
* 参数说明:
    * sec_id: 获取云API secretid信息
    * sec_key: 获取云API seretkey信息
    * sec_id: 产品id
    * sec_id: 设备名称
* 返回值:无返回值

[[TIoTCoreXP2PBridge sharedInstance] stopService]; 

* 函数说明:退出xp2p并释放对应的资源
* 参数说明:⽆参数
* 返回值:⽆返回值

[[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv];

* 函数说明:获取p2p通道建立后提供的本地url
* 参数说明:无参数
* 返回值:
    * 成功:返回构建的url
    * 失败:返回空字符串
* 返回值说明:
    * 返回的url是标准url,使用前需拼接成具体请求的url
    * 如需请求直播数据,则在返回的url后拼接`ipc.flv?action=live`
    * 如需请求本地录像数据,则在返回的url后拼接`ipc.flv?action=playback`

[[TIoTCoreXP2PBridge sharedInstance] sendVoiceToServer];

* 函数说明:通过建立的p2p通道发送对讲数据
* 参数说明:无参数
* 返回值:无返回值


[[TIoTCoreXP2PBridge sharedInstance] stopVoiceToServer];

* 函数说明:停止向peer发送对讲数据
* 参数说明:无参数
* 返回值:无返回值

[[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync];
* 参数说明:
    * cmd:命令参数,格式:`action=user_define&cmd=xxx`
    * timeout:超时时间,单位us
* 通过block返回值:
    * 设备端响应请求返回的数据

protocol  TIoTCoreXP2PBridgeDelegate
* 接口说明:通过该接口获取实时音视频流数据



### 附带说明
* 函数接口调用顺序:
    * startAppWith
    * getUrlForHttpFlv
    * sendVoiceToServer:如果没有发送需求可不调用该接口
    * stopService