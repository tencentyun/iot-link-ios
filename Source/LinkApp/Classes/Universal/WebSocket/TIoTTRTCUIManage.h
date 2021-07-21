//
//  TIoTWebSocketManage+TRTC.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>
#import "TIoTTRTCSessionManager.h"

@protocol TIoTTRTCUIManageDelegate <NSObject>

/**
 主动呼叫、进入房间、轮询需要实现
 */
/// @param userID 设备上报userID
- (void)presentAudioVCWithUserID:(NSString *_Nullable)userID;
- (void)presentVideoVCWithUserID:(NSString *_Nullable)userID;
///正在主动呼叫中，或呼叫UI已启动
- (void)callDeviceFromVC:(UIViewController *_Nonnull)viewController;
///正在主动呼叫中，或呼叫UI已启动,直接进房间;
///否则判断：
///如果是被动呼叫的话，不能自动进入房间;                             如果当前是被叫空闲或是正在通话，这时需要判断：设备A、B同时呼叫同一个用户1，用户1已经被一台比方说是设备A呼叫，后接到其他设备B的呼叫请求，用户1则调用AppControldeviceData 发送callstatus为0拒绝其他设备B的请求。
- (BOOL)isActiveCallingDeviceID:(NSString *_Nullable)deviceID topVC:(UIViewController *_Nullable)topVC;

/**
 离开房间需要实现
 */
- (void)leaveRoomWithPayload:(TIOTtrtcPayloadParamModel *_Nullable)deviceParam;

/**
 必须实现
 */
- (void)remoteDismissAndDistoryVC;
- (void)audioNoAnswered;
- (void)videoNoAnswered;
/// /呼起被叫页面，如果当前正在主叫页面，则外界UI不处理 （正在主动呼叫中，或呼叫UI已启动）
- (void)enterUserRemoteUserID:(NSString *_Nullable)userID targetVC:(UIViewController *_Nullable)topVC;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TIoTTRTCUIManage: NSObject <TIoTTRTCSessionUIDelegate>
+ (instancetype)sharedManager ;

@property (nonatomic, assign) BOOL isActiveStatus; //YES主动  NO 被动
@property (nonatomic, assign) BOOL isEnterError; //yes 正常进入房间，no  15s内没进入

@property (nonatomic, readonly) NSString *deviceID;

@property (nonatomic, weak) id<TIoTTRTCUIManageDelegate>delegate;
@property (nonatomic, readonly) TIOTtrtcPayloadParamModel *deviceParam; //socket payload
//@property (nonatomic, strong) TRTCCallingAuidoViewController *callAudioVC;
//@property (nonatomic, strong) TRTCCallingVideoViewController *callVideoVC;
@property (nonatomic, assign) TIoTTRTCSessionCallType preCallingType;
@property (nonatomic, strong) TIOTtrtcPayloadParamModel *__nullable tempModel;
@property (nonatomic, strong) NSString *deviceIDTempStr;

//面板中主动呼叫设备 0 audio； 1video
- (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo withDevideId:(NSString *)deviceIdString;

- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;

- (void)preLeaveRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;

//轮训设备状态，查看trtc设备是否要呼叫我
- (void)repeatDeviceData:(NSArray *)devices;

- (void)cancelTimer;
- (void)exitRoom:(NSString *)remoteUserID;
- (void)refuseOtherCallWithDeviceReport:(NSDictionary *)reportDic deviceID:(NSString *)deviceID;
@end

NS_ASSUME_NONNULL_END
