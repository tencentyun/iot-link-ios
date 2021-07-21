//
//  TIoTWebSocketManage+TRTC.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>
#import "TIoTTRTCSessionManager.h"

@protocol TIoTTRTCUIManageDelegate <NSObject>

- (void)presentAudioVCWithUserID:(NSString *_Nullable)userID;
- (void)presentVideoVCWithUserID:(NSString *_Nullable)userID;

@end

NS_ASSUME_NONNULL_BEGIN

@interface TIoTTRTCUIManage: NSObject <TIoTTRTCSessionUIDelegate>
+ (instancetype)sharedManager ;

@property (nonatomic, readonly) BOOL isActiveStatus; //YES主动  NO 被动
@property (nonatomic, assign) BOOL isEnterError; //yes 正常进入房间，no  15s内没进入

@property (nonatomic, readonly) NSString *deviceID;

@property (nonatomic, weak) id<TIoTTRTCUIManageDelegate>delegate;
@property (nonatomic, strong) TIOTtrtcPayloadParamModel *deviceParam; //socket payload
@property (nonatomic, strong) TRTCCallingAuidoViewController *callAudioVC;
@property (nonatomic, strong) TRTCCallingVideoViewController *callVideoVC;
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
