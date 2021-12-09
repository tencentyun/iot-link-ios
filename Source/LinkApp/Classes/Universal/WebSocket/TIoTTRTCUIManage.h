//
//  TIoTWebSocketManage+TRTC.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>
#import "TIoTTRTCSessionManager.h"

/**
 TRTC 根据设备状态处理UI
 */

NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTAddSocketNotifitionBlock)(NSArray *devIds);

@interface TIoTTRTCUIManage: NSObject <TIoTTRTCSessionUIDelegate>
+ (instancetype)sharedManager ;

//@property (nonatomic, readonly) BOOL isActiveStatus; //YES主动  NO 被动
//@property (nonatomic, readonly) BOOL isEnterError; //yes 正常进入房间，no  15s内没进入
//
//@property (nonatomic, readonly) NSString *deviceID;

@property (nonatomic, assign) BOOL isP2PVideoCommun; //p2pVideo 双向通话标识

//面板中主动呼叫设备 0 audio； 1video
//- (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo withDevideId:(NSString *)deviceIdString;
///MARK:外部主动拉起页面
// reportDic 面板主动呼叫时传入
- (void)trtcCallDeviceFromPanel:(TIoTTRTCSessionCallType)audioORvideo withDevideId:(NSString *)deviceIdString reportDeviceDic:(NSMutableDictionary *)reportDic;

//- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;
- (void)trtcPreEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure;

//- (void)preLeaveRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;
- (void)trtcPreLeaveRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure;

///轮训设备状态，查看trtc设备是否要呼叫我, 必须要实现发送socket通知，触发socket心跳:

//- (void)repeatDeviceData:(NSArray *)devices;
- (void)trtcRepeatDeviceData:(NSArray *)devices;

/// 监听到的设备上报信息处理
//- (void)receiveDeviceData:(NSDictionary *)deviceInfo;
- (void)trtcReceiveDeviceData:(NSDictionary *)deviceInfo;

/// 关闭断网时候 60超时计时器
//- (void)callingHungupAction;
- (void)trtcCallingHungupAction;

/// 设备断网后保存DeviceID和offline 状态用于退出页面区分提示判断 @{@"DeviceId:":@"";@"Offline":@(YES)}
//- (void)setDeviceDisConnectDic:(NSDictionary *)deviceDic;
- (void)trtcSetDeviceDisConnectDic:(NSDictionary *)deviceDic;

///p2pVideo APP主叫(被叫)进入通话
//- (void)acceptAppCallingOrCalledEnterRoom;
- (void)trtcAcceptAppCallingOrCalledEnterRoom;

///p2pVideo 退出页面
//- (void)refuseAppCallingOrCalledEnterRoom;
- (void)trtcRefuseAppCallingOrCalledEnterRoom;

///p2pVieo APP被叫 推出音、视频请求页面
//- (void)showAppCalledVideoVC;
- (void)trtcShowAppCalledVideoVC;
@end

NS_ASSUME_NONNULL_END
