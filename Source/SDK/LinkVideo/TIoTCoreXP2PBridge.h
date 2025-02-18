//
//  TIoTCoreXP2PBridge.h
//  TIoTLinkKitDemo
//
//

#import <Foundation/Foundation.h>
#import "TIoTCoreAudioConfig.h"
#import "TIoTCoreVideoConfig.h"
#import "TIoTAVCaptionFLV.h"
#include "AppWrapper.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const TIoTCoreXP2PBridgeNotificationDisconnect;
extern NSNotificationName const TIoTCoreXP2PBridgeNotificationReady;
extern NSNotificationName const TIoTCoreXP2PBridgeNotificationDetectError;
extern NSNotificationName const TIoTCoreXP2PBridgeNotificationDeviceMsg;
extern NSNotificationName const TIoTCoreXP2PBridgeNotificationStreamEnd;

@interface TIoTP2PAPPConfig : NSObject
@property (nonatomic, strong)NSString *appkey; //为explorer平台注册的应用信息(https://console.cloud.tencent.com/iotexplorer/v2/instance/app/detai) explorer控制台- 应用开发 - 选对应的应用下的 appkey/appsecret
@property (nonatomic, strong)NSString *appsecret; //为explorer平台注册的应用信息(https://console.cloud.tencent.com/iotexplorer/v2/instance/app/detai)
@property (nonatomic, strong)NSString *userid; //用户纬度（每个手机区分开）使用用户自有的账号系统userid；若无请配置为[TIoTCoreXP2PBridge sharedInstance].getAppUUID; 查找日志是需提供此userid字段

@property (nonatomic, strong)NSString *xp2pinfo; //被连接设备的p2p_info

@property (nonatomic, assign)BOOL autoConfigFromDevice; //是否跟随对应设备配置,YES 后下面的配置（cross、type等）不生效
@property (nonatomic, assign)BOOL crossStunTurn; //是否打开双中转开关，默认false
@property (nonatomic, assign)XP2PProtocolType type; //通信协议，默认auto
@end

@protocol TIoTCoreXP2PBridgeDelegate <NSObject>

/*
 * ⚠️⚠️⚠️ 谨慎！！！ === 此接口切勿执行耗时操作，耗时操作请切换线程，切勿卡住当前线程
 *
 * 裸流接口使用方式:
 * 通过 startAvRecvService 和 stopAvRecvService 接口，可以启动和停止裸流传输
 * 客户端拉取到的裸流数据对应 data 参数
 */
- (void)getVideoPacketWithID:(NSString *)dev_name data:(uint8_t *)data len:(size_t)len;


/*
 * ⚠️⚠️⚠️ 谨慎！！！ === 此接口切勿执行耗时操作，耗时操作请切换线程，切勿卡住当前线程，返回值需立即返回
 *
 * 接口功能 === 设备主动发消息给app:
 * dev_name 和所有接口的dev_name参数是保持一致，表示给那个哪个设备发的流
 * data是设备主动发过来的内容
 * 需注意使用场景：只能在直播，回看或对讲期间设备才可以主动发
 * char *返回值表示回复给设备的返回信息
 */
- (NSString *)reviceDeviceMsgWithID:(NSString *)dev_name data:(NSData *)data;

/*
 * sdk 事件消息,事件对应类型与意义详见 XP2PType 类型说明
 * msg 事件详情
 */
- (void)reviceEventMsgWithID:(NSString *)dev_name eventType:(XP2PType)eventType msg:(const char*) msg;
@end


@interface TIoTCoreXP2PBridge : NSObject
@property (nonatomic, weak)id<TIoTCoreXP2PBridgeDelegate> delegate;

/*
 * 开关是否将数据帧写入 Document 目录的 video.data 文件 （后缀可导出后改动）
 */
@property (nonatomic, assign)BOOL writeFile;

/*
 * 是否打印 SDK Log，默认关
 */
@property (nonatomic, assign)BOOL logEnable;

/*
 * 获取版本号
 */
+ (NSString *)getSDKVersion;
+ (instancetype)sharedInstance ;

/*
 * 启动 sdk 服务，productid和devicename可以从video控制台创建得倒
 * type: 默认auto模式，udp探测不通自动切换至tcp
 * ready 回调之后，即可开始（拉流、发信令、对讲等）
 */
- (XP2PErrCode)startAppWith:(NSString *)pro_id dev_name:(NSString *)dev_name appconfig:(TIoTP2PAPPConfig *)appconfig;


/*
 * 使用播放器播放时，需先等待 SDK 初始化完成，ready事件(xp2preconnect 通知)之后，即可获取到 http-url
 */
- (NSString *)getUrlForHttpFlv:(NSString *)dev_name;

/*
 * 与设备信令交互接口
 * 1.设备端回复 app 的消息没有限制
 * 2.app 发送给设备的信令，要求不带&符号，信令长度不超过3000个字节
 *
 * 事例 cmd 参数（action=inner_define&cmd=get_nvr_list）
 */
- (void)getCommandRequestWithAsync:(NSString *)dev_name cmd:(NSString *)cmd timeout:(uint64_t)timeout completion:(void (^ __nullable)(NSString * jsonList))completion;

/*
 * 开始停止裸流传输接口，通过代理 getVideoPacket 返回裸流数据
 */
- (void)startAvRecvService:(NSString *)dev_name cmd:(NSString *)cmd;
- (XP2PErrCode)stopAvRecvService:(NSString *)dev_name;

/*
 * 语音对讲开始结束接口
 */
//对讲音频默认采样率
- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number;
//可通过此接口 audio_onfig 参数既可设置对讲音频码率（bitrate）、采样率（sampleRate）、channelCount、sampleSize
- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate;
//音视频采样
- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate withLocalPreviewView:(UIView *)localView;                                                                                       __attribute__((deprecated("Use -sendVoiceToServer: channel: audioConfig: videoConfig:")));
- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate withLocalPreviewView:(UIView *)localView videoPosition:(AVCaptureDevicePosition)videoPosition;                                  __attribute__((deprecated("Use -sendVoiceToServer: channel: audioConfig: videoConfig:")));
- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTAVCaptionFLVAudioType)audio_rate withLocalPreviewView:(UIView *)localView videoPosition:(AVCaptureDevicePosition)videoPosition isEchoCancel:(BOOL)isEchoCancel;  __attribute__((deprecated("Use -sendVoiceToServer: channel: audioConfig: videoConfig:")));
- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number audioConfig:(TIoTCoreAudioConfig *)audio_config videoConfig:(TIoTCoreVideoConfig *)video_config;
//刷新本地预览视图
- (void)refreshLocalView:(UIView *)localView;

- (XP2PErrCode)stopVoiceToServer;
//切换前后摄像头
- (void)changeCameraPositon;

//设置分辨率，需在开启通话前设置
- (void)resolutionRatio:(AVCaptureSessionPreset )resolutionValue;


/*
 * 局域网相关接口
 */
- (XP2PErrCode)startLanAppWith:(NSString *)pro_id dev_name:(NSString *)dev_name remote_host:(NSString *)remote_host remote_port:(NSString *)remote_port;
- (NSString *)getLanUrlForHttpFlv:(NSString *)dev_name;
- (int)getLanProxyPort:(NSString *)dev_name;


/*
 * 退出 SDK 服务
 */
- (void)stopService:(NSString *)dev_name;

/*
 * 调试接口，录制通过播放器拉取的数据流并行保存到 Document 目录的 video.data 文件
 * 需提前打开 writeFile 开关
 */
+ (void)recordstream:(NSString *)dev_name;

/*
 * 获取当前发送链路的连接模式：0 无效；62 直连；63 转发
 */
+ (int)getStreamLinkMode:(NSString *)dev_name;

/*
 * 获取当前发送音视频水位大小，正常水位保持在低位大约（0～1000）
 * 自适应码率可以参考demo 升降码率逻辑 https://github.com/tencentyun/iot-link-ios/blob/video-v2.4.x/Source/SDK/LinkVideo/TIoTCoreXP2PBridge.mm#L374-L406
 * // 降码率
    // 当发现p2p的水线超过一定值时，降低视频码率，这是一个经验值，一般来说要大于 [视频码率/2]
    // 实测设置为 80%视频码率 到 120%视频码率 比较理想
    // 在10组数据中，获取到平均值，并将平均水位与当前码率比对。
 * // 升码率
    // 测试发现升码率的速度慢一些效果更好
    // p2p水线经验值一般小于[视频码率/2]，网络良好的情况会小于 [视频码率/3] 甚至更低
 */
- (int32_t)getSendingBufSize;

/*
 * 获取app_uuid
 */
- (NSString *)getAppUUID;

/*
 * 发布外部视频数据(自定义采集，自定义编码，h264数据),请设置TIoTCoreAudioConfig中 isExternal = YES
 * 需注意该接口在sendVoiceToServer之后再调用发送
 */
- (void)SendExternalVideoPacket:(NSData *)videoPacket;

/*
 * 发布外部视频数据(自定义采集，自定义编码，aac数据),请设置TIoTCoreVideoConfig中 isExternal = YES
 * 需注意该接口在sendVoiceToServer之后再调用发送
 */
- (void)SendExternalAudioPacket:(NSData *)audioPacket;

- (void)setRemoteAudioFrame:(void *)pcmdata len:(int)pcmlen;
@end

NS_ASSUME_NONNULL_END
