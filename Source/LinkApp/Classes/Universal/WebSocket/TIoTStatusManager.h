//
//  TIoTStatusManager.h
//  LinkApp
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol TIoTStatusManagerDelegate <NSObject>

/// 进入语音/视频VC，
/// @param model 使用时需判断model内字段是否为空
/// @param type 语音/视频 类型
/// @param isFromReceived 用于区分来自于用户主动调用，还是接收设备上报。用户主动调用,音视频vc 初始化 userid=nil,devicename可不赋值，否则均要传入
/// @param reportDeviceDic 手动拉起页面需要传,被呼叫则new空字典
- (void)statusManagerPayloadParamModel:(TIOTtrtcPayloadParamModel *)model type:(TIoTTRTCSessionCallType)type isFromReceived:(BOOL)isFromReceived reportDeviceDic:(NSMutableDictionary *)reportDeviceDic deviceID:(NSString *)deviceIDString;

- (void)statusManagerRefuseOtherCallWithDeviceReport:(NSDictionary *)reportDic deviceID:(NSString *)deviceID;
- (void)statusManagerrequestControlDeviceDataWithReport:(NSDictionary *)reportDic deviceID:(NSString *)deviceID;

- (void)audioVCHungup;
- (void)audioVCBeHungup;
- (void)audioVCOtherAnswered;
- (void)audioVCHangupTapped;
- (void)audioVCNoAnswered;

- (void)videoVCHungup;
- (void)videoVCBeHungup;
- (void)videoVCOtherAnswered;
- (void)videoVCHangupTapped;
- (void)videoVCNoAnswered;

//退出语音/视频VC
- (void)statusManagerDismissVC;
// 拒绝主叫被叫进入房间后，音视频控制器reset
- (void)remoteDismissSetting;

- (void)audioActiveCallSessionNoCallingStatus;
- (void)audioActiveCallSessionCallingStatus;
- (void)videoActiveCallSessionNoCallingStatus;
- (void)videoActiveCallSessionCallingStatus;

- (void)acceptJoinRoom;
- (void)didExitRoom:(NSString *)remoteUserID;

- (void)judgeTopVC;
@end

@interface TIoTStatusManager : NSObject

@property (nonatomic, weak) id<TIoTStatusManagerDelegate>delegate;
@property (nonatomic, strong, readonly) TIOTtrtcPayloadParamModel *deviceParam;
@property (nonatomic, assign, readonly) TIoTTRTCSessionCallType preCallingType;
@property (nonatomic, strong, readonly) TIOTtrtcPayloadParamModel *tempModel;
@property (nonatomic, strong, readonly) NSString *deviceIDTempStr;
@property (nonatomic, strong) TRTCCallingAuidoViewController *callAudioVC;
@property (nonatomic, strong) TRTCCallingVideoViewController *callVideoVC;

//取消计时器
- (void)cancelTimer;
- (void)setEnterErrorProperty:(BOOL)isEnterErrorProperty; //设置isEnterError 
- (void)settingExitRoom:(NSString *)remoteUserID; 



@property (nonatomic, readonly) BOOL isActiveStatus; //YES主动  NO 被动
@property (nonatomic, readonly) BOOL isEnterError; //yes 正常进入房间，no  15s内没进入

@property (nonatomic, readonly) NSString *deviceID;

@property (nonatomic, assign) BOOL isP2PVideoCommun; //p2pVideo 双向通话标识

//面板中主动呼叫设备 0 audio； 1video
//deviceDic 面板中手动拉起页面需要传
- (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo withDevideId:(NSString *)deviceIdString reportDeviceDic:(NSMutableDictionary *)deviceDic;

- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;

- (void)preLeaveRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure ;

///轮训设备状态，查看trtc设备是否要呼叫我, 必须要实现发送socket通知，触发socket心跳:

- (void)repeatDeviceData:(NSArray *)devices;

/// 监听到的设备上报信息处理
- (void)receiveDeviceData:(NSDictionary *)deviceInfo;

/// 关闭断网时候 60超时计时器
- (void)callingHungupAction;

/// 设备断网后保存DeviceID和offline 状态用于退出页面区分提示判断 @{@"DeviceId:":@"";@"Offline":@(YES)}
- (void)setDeviceDisConnectDic:(NSDictionary *)deviceDic;

///p2pVideo APP主叫(被叫)进入通话
- (void)acceptAppCallingOrCalledEnterRoom;
///p2pVideo 退出页面
- (void)refuseAppCallingOrCalledEnterRoom;
///p2pVieo APP被叫 推出音、视频请求页面
- (void)showAppCalledVideoVC;

@end

NS_ASSUME_NONNULL_END
