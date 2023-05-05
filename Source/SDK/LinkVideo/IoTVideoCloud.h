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
#import <TXLiteAVSDK_TRTC/TRTCCloud.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const TIoTCoreXP2PBridgeNotificationDisconnect;
extern NSNotificationName const TIoTCoreXP2PBridgeNotificationReady;
extern NSNotificationName const TIoTCoreXP2PBridgeNotificationDeviceMsg;
extern NSNotificationName const TIoTCoreXP2PBridgeNotificationStreamEnd;

@protocol IoTVideoCloudDelegate <NSObject>
@optional
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
 */
- (void)reviceEventMsgWithID:(NSString *)dev_name eventType:(XP2PType)eventType;

/*
 * 第一帧过来时候触发
 */
- (void)onFirstVideoFrame;
@end





@interface IoTVideoParams : NSObject
//设置p2p模式 必传参数xp2pinfo、productid、devicename
@property (nonatomic, strong)NSString *xp2pinfo;
@property (nonatomic, strong)NSString *productid;
@property (nonatomic, strong)NSString *devicename;

//设置rtc模式 必传参数TRTCParams
@property (nonatomic, strong)TRTCParams *rtcparams;

@property (nonatomic, strong)TIoTCoreAudioConfig *audioConfig;
@property (nonatomic, strong)TIoTCoreVideoConfig *videoConfig;
@end





@interface IoTVideoCloud : NSObject
@property (nonatomic, weak)id<IoTVideoCloudDelegate> delegate;

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

// 不建议使用下面两个start接口，避免泄漏您的secretid和secretkey，会造成您的账户泄漏，demo仅用此接口做演示使用
- (XP2PErrCode)startAppWith:(IoTVideoParams *)params;

/*
 * 退出 SDK 服务
 */
- (void)stopAppService:(NSString *)dev_name;

/*
 * 开始推流接口
 *
 */
- (void)startLocalStream:(NSString *)dev_name;

/*
 *停止本地流
 */
- (void)stopLocalStream;

/*
 * 开始拉流接口
 * ⚠️ 当使用p2p模式时候，使用播放器播放时，需先等待 SDK 初始化完成，ready事件之后，即可获取到 http-url 开始拉流
 * ⚠️ 当使用rtc模式时候，使用内部播放只需传入remoteView、LocalView展示UI
 */
- (NSString *)startRemoteStream:(NSString *)dev_name;

/*
 * 与设备信令交互接口
 * 1.设备端回复 app 的消息没有限制
 * 2.app 发送给设备的信令，要求不带&符号，信令长度不超过3000个字节
 *
 * 事例 cmd 参数（action=inner_define&cmd=get_nvr_list）
 */
- (void)sendCustomCmdMsg:(NSString *)dev_name cmd:(NSString *)cmd timeout:(uint64_t)timeout completion:(void (^ __nullable)(NSString * jsonList))completion;


/*
 * 打开本地预览，可提前看到本端画面
 */
- (void)openCamera:(AVCaptureDevicePosition)videoPosition view:(UIView *)previewView;

//刷新本地预览视图
- (void)refreshLocalView:(UIView *)localView;
//切换前后摄像头
- (void)changeCameraPositon;
//设置听筒还是扬声器模式，yes=扬声器，no=听筒
- (void)setAudioRoute:(BOOL)isHandsFree ;
//静音或回复音频
- (void)muteLocalAudio:(BOOL)mute;
//静音或回复音频
- (void)muteLocalVideo:(BOOL)mute;



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
 *刷新p2pinfo信息
 */
- (XP2PErrCode)setXp2pInfo:(NSString *)dev_name xp2pinfo:(NSString *)xp2pinfo;

/*
 * p2p模式下，开始停止裸流传输接口，通过代理 getVideoPacket 返回裸流数据
 */
- (void)startAvRecvService:(NSString *)dev_name cmd:(NSString *)cmd;
- (XP2PErrCode)stopAvRecvService:(NSString *)dev_name;

/*
 * p2p模式下，局域网相关接口
 */
- (XP2PErrCode)startLanAppWith:(NSString *)pro_id dev_name:(NSString *)dev_name remote_host:(NSString *)remote_host remote_port:(NSString *)remote_port;
- (NSString *)getLanUrlForHttpFlv:(NSString *)dev_name;
- (int)getLanProxyPort:(NSString *)dev_name;
@end

NS_ASSUME_NONNULL_END
