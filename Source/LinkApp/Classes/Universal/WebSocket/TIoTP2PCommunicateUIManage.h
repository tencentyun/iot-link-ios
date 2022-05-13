//
//  TIoTP2PCommunicateUIManage.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>
#import "TIoTTRTCSessionManager.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTP2PCommunicateUIManage : NSObject<TIoTTRTCSessionUIDelegate>
+ (instancetype)sharedManager ;

//@property (nonatomic, readonly) BOOL isActiveStatus; //YES主动  NO 被动
//@property (nonatomic, readonly) BOOL isEnterError; //yes 正常进入房间，no  15s内没进入

//@property (nonatomic, readonly) NSString *deviceID;

@property (nonatomic, assign) BOOL isP2PVideoCommun; //p2pVideo 双向通话标识

//必须要调用
- (void)setStatusManager;

//面板中主动呼叫设备 0 audio； 1video
//- (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo withDevideId:(NSString *)deviceIdString;
///MARK:外部主动拉起页面
// reportDic 面板主动呼叫时传入
- (void)p2pCommunicateCallDeviceFromPanel:(TIoTTRTCSessionCallType)audioORvideo withDevideId:(NSString *)deviceIdString reportDeviceDic:(NSMutableDictionary *)reportDic;


//- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;
- (void)p2pCommunicatePreEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure;

//- (void)preLeaveRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;
- (void)p2pCommunicatePreLeaveRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;

///轮训设备状态，查看trtc设备是否要呼叫我, 必须要实现发送socket通知，触发socket心跳:

//- (void)repeatDeviceData:(NSArray *)devices;
- (void)p2pCommunicateRepeatDeviceData:(NSArray *)devices;

/// 监听到的设备上报信息处理
//- (void)receiveDeviceData:(NSDictionary *)deviceInfo;
- (void)p2pCommunicateReceiveDeviceData:(NSDictionary *)deviceInfo;

/// 关闭断网时候 60超时计时器
//- (void)callingHungupAction;
- (void)p2pCommunicateCallingHungupAction;

/// 设备断网后保存DeviceID和offline 状态用于退出页面区分提示判断 @{@"DeviceId:":@"";@"Offline":@(YES)}
//- (void)setDeviceDisConnectDic:(NSDictionary *)deviceDic;
- (void)p2pCommunicateSetDeviceDisConnectDic:(NSDictionary *)deviceDic;

///p2pVideo APP主叫(被叫)进入通话
//- (void)acceptAppCallingOrCalledEnterRoom;
- (void)p2pCommunicateAcceptAppCallingOrCalledEnterRoom;
///p2pVideo 退出页面
//- (void)refuseAppCallingOrCalledEnterRoom;
- (void)p2pCommunicateRefuseAppCallingOrCalledEnterRoom;
///p2pVieo APP被叫 推出音、视频请求页面
//- (void)showAppCalledVideoVC;
- (void)p2pCommunicateShowAppCalledVideoVC;

///p2pVieo 设置分辨率和采样率
- (void)p2pCommunicateResolutionRatio:(AVCaptureSessionPreset )resolutionRatio;
- (void)p2pCommunicateSamplingRate:(NSInteger)samplingRate;

///p2pVideo 获取设置分辨率和采样率
- (AVCaptureSessionPreset)getP2pCommunicateResolutionRatio;
- (NSInteger)getP2pCommunicateSamplingRate;

///刷新播放器
- (void)refreshP2PVideoPlayer;

/// 判断当前top是不是p2p2VideoplayervaptureVC
- (BOOL)isTopP2PVideoPlayerVC;

///p2pVideo 通话中 APP主动挂断上报/60s超时页面退出后上报
- (void)p2pCommunicateHungupRequestControlDevice;
@end

NS_ASSUME_NONNULL_END
