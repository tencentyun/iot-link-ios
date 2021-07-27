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

@property (nonatomic, readonly) BOOL isActiveStatus; //YES主动  NO 被动
@property (nonatomic, readonly) BOOL isEnterError; //yes 正常进入房间，no  15s内没进入

@property (nonatomic, readonly) NSString *deviceID;


//面板中主动呼叫设备 0 audio； 1video
- (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo withDevideId:(NSString *)deviceIdString;

- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;

- (void)preLeaveRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;

///轮训设备状态，查看trtc设备是否要呼叫我, 必须要实现发送socket通知，触发socket心跳:

- (void)repeatDeviceData:(NSArray *)devices;

/// 监听到的设备上报信息处理
- (void)receiveDeviceData:(NSDictionary *)deviceInfo;

/// 关闭断网时候 60超时计时器
- (void)callingHungupAction;
@end

NS_ASSUME_NONNULL_END
