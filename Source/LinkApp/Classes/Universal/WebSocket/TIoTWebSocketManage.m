//
//  WCWebSocketManage.m
//  TenextCloud
//
//

#import "TIoTWebSocketManage.h"
#import "TIoTAppEnvironment.h"
#import "UIViewController+GetController.h"
#import "TIoTNavigationController.h"
#import "TIoTMainVC.h"
#import "TIoTCoreRequestObj.h"
#import "ReachabilityManager.h"
#import "TIoTCoreSocketCover.h"
#import "TIoTCoreDeviceSet.h"
#import "TIOTTRTCModel.h"
#import "TIoTTRTCSessionManager.h"
#import "TIoTTRTCUIManage.h"
#import "TIoTCoreUtil.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define WeakSelf(type)  __weak typeof(type) weak##type = type;

static NSString *registDeviceReqID = @"5001";
static NSString *heartBeatReqID = @"5002";

@interface TIoTWebSocketManage ()<QCSocketManagerDelegate,TIoTTRTCUIManageDelegate,TRTCCallingViewDelegate> {
    TRTCCallingAuidoViewController *_callAudioVC;
    TRTCCallingVideoViewController *_callVideoVC;
}

@property (nonatomic, strong) NSMutableDictionary *reqArray;

@end

@implementation TIoTWebSocketManage

+(instancetype)shared{
    static TIoTWebSocketManage *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self instanceSocketManager];
        [self registerNetworkNotifications];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)instanceSocketManager {
    
//    [TIoTCoreSocketManager shared].socketedRequestURL = [TIoTCoreAppEnvironment shareEnvironment].wsUrl;
    [TIoTCoreSocketManager shared].socketedRequestURL = [NSString stringWithFormat:@"%@?uin=%@",[TIoTCoreAppEnvironment shareEnvironment].wsUrl,TIoTAPPConfig.GlobalDebugUin];
    [TIoTCoreSocketManager shared].delegate = self;
    
    //TRTC UI Delegate
    [TIoTTRTCSessionManager sharedManager].uidelegate = TIoTTRTCUIManage.sharedManager;
    [TIoTTRTCUIManage sharedManager].delegate = self;
}

- (void)registerNetworkNotifications{
    
    [[NetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(NetworkReachabilityStatus status) {
        switch (status) {
            case NetworkReachabilityStatusUnknown:
                NSLog(@"状态不知道");
                break;
            case NetworkReachabilityStatusNotReachable:
                NSLog(@"没网络");
                break;
            case NetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                [self SRWebSocketOpen];
                break;
            case NetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"移动网络");
                [self SRWebSocketOpen];
                break;
            default:
                break;
        }
    }];
    
    [[NetworkReachabilityManager sharedManager] startMonitoring];
    
}

/// 订阅
- (void)registerDevicecActive:(NSNotification *)noti {
    
    NSArray *deviceIds = noti.object;
    
    [[TIoTWebSocketManage shared] sendActiveData:deviceIds withRequestURL:@"ActivePush" complete:^(BOOL sucess, NSDictionary * _Nonnull data) {
        if (sucess) {

        }
    }];
}

-(void)SRWebSocketOpen{
    
    [[TIoTCoreSocketManager shared] socketOpen];
    
}

-(void)SRWebSocketClose{
    
    [[TIoTCoreSocketManager shared] socketClose];
    [self destoryHeartBeat];
}

#pragma mark - QCSocketManagerDelegate delegete
- (void)socketDidOpen:(TIoTCoreSocketManager *)manager {
    
    WCLog(@"************************** socket 连接成功************************** ");
    [HXYNotice addHeartBeatListener:self reaction:@selector(initHeartBeat:)];
    [HXYNotice addActivePushListener:self reaction:@selector(registerDevicecActive:)];
    
    [HXYNotice addSocketConnectSucessPost];
}

- (void)socket:(TIoTCoreSocketManager *)manager didFailWithError:(NSError *)error {
    
}

- (void)socket:(TIoTCoreSocketManager *)manager didReceiveMessage:(id)message {
    [self handleReceivedMessage:message];
}

- (void)socket:(TIoTCoreSocketManager *)manager didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    WCLog(@"************************** socket连接断开************************** ");
    [self SRWebSocketClose];
    
}


- (void)deviceReceivedData:(NSDictionary *)data{
    BOOL sucess = YES;
    if (![NSObject isNullOrNilWithObject:data[@"data"]]) {
        sucess = YES;
    }
    else{
        sucess = NO;
    }
    
    NSString *reqID = [NSString stringWithFormat:@"%@",data[@"reqId"]];
    TIoTCoreRequestObj *reqObj = self.reqArray[reqID];
    
    if (reqObj.sucess) {
        reqObj.sucess(sucess, data[@"data"]);
        [self.reqArray removeObjectForKey:reqID];
    }
}

//监听到的设备上报信息
- (void)deviceInfo:(NSDictionary *)deviceInfo{
    [HXYNotice addReportDevicePost:deviceInfo];
    
    //检测是否TRTC设备，是否在呼叫中
    NSDictionary *payloadDic = [NSString base64Decode:deviceInfo[@"Payload"]];
    NSLog(@"----111---%@",payloadDic);
    NSLog(@"----222---%@",[TIoTCoreUserManage shared].userId);
    TIOTtrtcPayloadModel *model = [TIOTtrtcPayloadModel yy_modelWithJSON:payloadDic];
    model.params.deviceName = deviceInfo[@"DeviceId"];
    if (model.params._sys_userid.length < 1) {
        model.params._sys_userid = deviceInfo[@"DeviceId"];
    }

    
    if ([payloadDic.allKeys containsObject:@"params"]) {
        NSDictionary *paramsDic = payloadDic[@"params"];
        if (paramsDic[@"_sys_audio_call_status"]) {
            [TIoTCoreUserManage shared].sys_call_status = model.params._sys_audio_call_status;
        }else if (paramsDic[@"_sys_video_call_status"]) {
            [TIoTCoreUserManage shared].sys_call_status = model.params._sys_video_call_status;
        }
    }
    
    if ([model.method isEqualToString:@"report"]) {
        
        NSString *extrainfo = model.params._sys_extra_info;
        if (extrainfo) {
            //被拒绝就退出房间
            TIOTtrtcRejectModel *rejectModel = [TIOTtrtcRejectModel yy_modelWithJSON:extrainfo];
            if ([rejectModel.rejectUserId isEqualToString:[TIoTCoreUserManage shared].userId]) {
                [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                    [MBProgressHUD showError:reason];
                }];
            }
            return;
        }

        
        if (!model.params._sys_audio_call_status && !model.params._sys_video_call_status) {
            //防止没上报status时候，走到了status=0的情况，新增if需要加在次前面，后面的status避免新增加判断
            return;
        }
        
        
        if (model.params._sys_audio_call_status.intValue == 1 || model.params._sys_video_call_status.intValue == 1) {
            
            
            if ([TIoTTRTCUIManage sharedManager].isActiveStatus == YES && (![NSString isNullOrNilWithObject:[TIoTTRTCUIManage sharedManager].deviceID] && [[TIoTTRTCUIManage sharedManager].deviceID isEqualToString:model.params.deviceName])) {
                //用户1和用户2（不同账号）同时呼叫设备,deviceA 接听，则会上报对应callstatus属性为1 和 先接收到的比方说是用户1的userid，对应的用户1会调用App::IotRTC::CallDevice加入房间，另一个用户2收到的上报消息查看userid不是自己，则提示对方正忙…，并退出
                if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                    //TRTC设备需要通话，开始通话,防止不是trtc设备的通知
                    [[TIoTTRTCUIManage sharedManager] preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                        
                        [MBProgressHUD showError:reason];
                    }];
                }else {
                    [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                        [MBProgressHUD showError:reason];
                    }];
                }
            }else {
                
                if ([model.params._sys_userid isEqualToString:model.params.deviceName]) {
                    [[TIoTTRTCUIManage sharedManager] preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {

                        [MBProgressHUD showError:reason];
                    }];
                }else {
                    NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
                    for (NSString *userIdString in userIdArray) {
                        model.params._sys_userid = userIdString?:@"";
                        if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                            [[TIoTTRTCUIManage sharedManager] preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {

                                [MBProgressHUD showError:reason];
                            }];
                        }
                        
                    }
                }
                
            }
        }else if (model.params._sys_audio_call_status.intValue == 2 || model.params._sys_video_call_status.intValue == 2) {
            
            NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
            for (NSString *userIdString in userIdArray) {

                model.params._sys_userid = userIdString?:@"";
                [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                    [MBProgressHUD showError:reason];
                }];
            }
            
        }else if (model.params._sys_audio_call_status.intValue == 0 || model.params._sys_video_call_status.intValue == 0) {
            
            NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
            for (NSString *userIdString in userIdArray) {

                model.params._sys_userid = userIdString?:@"";
                if ([TIoTTRTCUIManage sharedManager].isEnterError == NO) {
                    if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                        
                        if ([[TIoTTRTCUIManage sharedManager].deviceID isEqualToString:model.params.deviceName]) {
                            [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                                [MBProgressHUD showError:reason];
                            }];
                        }
                        
                    }else if ([model.params._sys_userid isEqualToString:model.params.deviceName]) {   //返回socket params 里没有userid时候（设备端主动呼叫，未接听，设备主动挂断）
                           //防止case 3 中另一个设备 呼叫正在调起通话页面的APP
                            [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                                [MBProgressHUD showError:reason];
                            }];
                        
                    }
                    
                }

            }
            
            
        }
        
    }
    
    //异常
    if ([deviceInfo[@"SubType"] isEqualToString:@"Offline"]) {
        
        NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
        for (NSString *userIdString in userIdArray) {

            model.params._sys_userid = userIdString?:@"";
            if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                    [MBProgressHUD showError:reason];
                }];
            }

        }
    }

}

- (void)handleReceivedMessage:(id)message{
    NSDictionary *dic = [NSString jsonToObject:message];
    WCLog(@"message:%@",dic);
    NSString *reqId = [NSString stringWithFormat:@"%@",dic[@"reqId"]];
    if ([NSObject isNullOrNilWithObject:dic[@"reqId"]])
    {
        if ([dic[@"action"] isEqualToString:@"DeviceChange"]) {
            [self deviceInfo:dic[@"params"]];
            return;
        }
    }
    
    if ([heartBeatReqID isEqualToString:reqId]) {//心跳回包
        return;
    }
    
    if ([registDeviceReqID isEqualToString:reqId]) {//
        [self deviceReceivedData:dic];
        return;
    }
    
    
    
    BOOL sucess = YES;
    NSDictionary *result = nil;
    
    if (![NSObject isNullOrNilWithObject:dic[@"data"]]) {
        if (dic[@"data"][@"Response"][@"Error"]) {
            [MBProgressHUD showError:dic[@"data"][@"Response"][@"Error"][@"Message"]];
            sucess = NO;
            result = dic[@"data"][@"Response"][@"Error"];
        }
        if ([dic[@"data"][@"result"] isEqualToString:@"hello world"]) {
            return;
        }
    }
    else{
        [MBProgressHUD showError:dic[@"error_message"]];
        sucess = NO;
        result = dic;
    }
    
    
    NSString *reqIDStr = [NSString stringWithFormat:@"%@",reqId];
    TIoTCoreRequestObj *reqObj = self.reqArray[reqIDStr];
    if(reqObj.sucess){
        if (sucess) {
            if ([NSObject isNullOrNilWithObject:dic[@"data"][@"Response"][@"Data"]]) {
                
                reqObj.sucess(sucess,sucess ? dic[@"data"][@"Response"] : [NSDictionary dictionary]);
            }
            else{
                reqObj.sucess(sucess,sucess ? dic[@"data"][@"Response"][@"Data"] : [NSDictionary dictionary]);
            }
        }
        else{
            reqObj.sucess(sucess, result);
        }
        [self.reqArray removeObjectForKey:reqIDStr];
    }
    
}

//初始化心跳
- (void)initHeartBeat:(NSNotification *)noti
{
    NSArray *deviceIds = noti.object;
    
    dispatch_main_async_safe(^{
        [self destoryHeartBeat];
        
        [[TIoTCoreSocketManager shared] startHeartBeatWith:deviceIds];
    })
}


//取消心跳
- (void)destoryHeartBeat
{

    [[TIoTCoreSocketManager shared] stopHeartBeat];
}

//ping
- (void)ping:(NSTimer *)timer {
    NSArray *deviceIds = timer.userInfo;

    if ([TIoTCoreSocketManager shared].socketReadyState == WC_OPEN) {
        
        NSData *data= [NSJSONSerialization dataWithJSONObject:[self heartData:deviceIds] options:NSJSONWritingPrettyPrinted error:nil];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        [[TIoTCoreSocketManager shared] sendData:dataDic];
    }
    
}


//心跳数据
- (NSDictionary *)heartData:(NSArray *)deviceIds {
    return @{
        @"action":[TIoTCoreAppEnvironment shareEnvironment].action,
        @"reqId":[[NSUUID UUID] UUIDString],
        @"params":@{
            @"Action": @"AppDeviceTraceHeartBeat",
            @"AccessToken":[TIoTCoreUserManage shared].accessToken,
            @"RequestId":@"weichuan-client",
            @"ActionParams": @{
                @"DeviceIds": deviceIds
            }
        }
    };
}

//判断是否重新登录
- (BOOL)needLogin{
    if ([[TIoTCoreUserManage shared].expireAt integerValue] <= [[NSString getNowTimeString] integerValue] && [TIoTCoreUserManage shared].accessToken.length > 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"warm_prompt", @"温馨提示") message:NSLocalizedString(@"login_timeout", @"登录已过期") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"relogin", @"重新登录") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
            [[TIoTAppEnvironment shareEnvironment] loginOut];
            TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTMainVC alloc] init]];
            [UIViewController getCurrentViewController].view.window.rootViewController = nav;
        }];
        [alert addAction:alertA];
        [[UIViewController getCurrentViewController] presentViewController:alert animated:YES completion:nil];
        return YES;
    }
    return NO;
}

//设备监听
- (void)sendActiveData:(NSArray *)deviceIds withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess{
    //每次请求需要判断登录是否失效
    if ([self needLogin]) {
        return;
    }
    
    NSDictionary *dataDic = [[TIoTCoreSocketCover shared] registerDeviceParamterActive:deviceIds withAction:requestURL complete:sucess];
    
    [[TIoTCoreSocketManager shared] sendData:dataDic];
    
}

- (void)sendData:(NSDictionary *)paramDic withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess{
    //每次请求需要判断登录是否失效
    if ([self needLogin]) {
        return;
    }
    
    NSDictionary *dic = @{@"Platform":[TIoTCoreAppEnvironment shareEnvironment].platform,
                          @"Agent":[TIoTCoreAppEnvironment shareEnvironment].platform,
                          @"RequestId":[[NSUUID UUID] UUIDString],
                          @"action":[TIoTCoreAppEnvironment shareEnvironment].action,
                          @"AppKey":[TIoTCoreAppEnvironment shareEnvironment].appKey,
    };
    
    NSDictionary *dataDic = [[TIoTCoreSocketCover shared] sendDataDictionaryWithParamDic:paramDic withArgumentDic:dic withRequestURL:requestURL complete:sucess];
    [[TIoTCoreSocketManager shared] sendData:dataDic];
}

-(WCReadyState)socketReadyState{

    return [TIoTCoreSocketManager shared].socketReadyState;
}

#pragma mark - TIoTTRTCUIManageDelegate 代理方法
- (void)presentAudioVCWithUserID:(NSString *)userID {
    _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:userID];
    _callAudioVC.actionDelegate = self;
    _callAudioVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [[TIoTCoreUtil topViewController] presentViewController:_callAudioVC animated:NO completion:^{}];
}

- (void)presentVideoVCWithUserID:(NSString *)userID {
    _callVideoVC = [[TRTCCallingVideoViewController alloc] initWithOcUserID:userID];
    _callVideoVC.actionDelegate = self;
    _callVideoVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [[TIoTCoreUtil topViewController] presentViewController:_callVideoVC animated:NO completion:^{}];
}

#pragma mark- TRTCCallingViewDelegate ui决定是否进入房间
- (void)didAcceptJoinRoom {
    //2.根据UI决定是否进入房间
    
    //开始准备进房间，通话中状态
    NSDictionary *param = @{@"DeviceId":[TIoTTRTCUIManage sharedManager].deviceParam.deviceName};
    
    [[TIoTRequestObject shared] post:AppIotRTCCallDevice Param:param success:^(id responseObject) {
        
        NSDictionary *tempDic = responseObject[@"TRTCParams"];
        TIOTTRTCModel *model = [TIOTTRTCModel yy_modelWithJSON:tempDic];
        [[TIoTTRTCSessionManager sharedManager] configRoom:model];
        [[TIoTTRTCSessionManager sharedManager] enterRoom];
        
        //取消计时器
        [[TIoTTRTCUIManage sharedManager] cancelTimer];
        
         //一方已进入房间，另一方未成功进入或者异常退出，已等待15秒,已进入房间15秒内对方没有进入房间(TRTC有个回调onUserEnter，对方进入房间会触发这个回调)，则设备端和应用端提示对方已挂断，并退出
        [TIoTTRTCUIManage sharedManager].isEnterError = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([TIoTTRTCUIManage sharedManager].isEnterError == YES) {
                UIViewController *topVC = [TIoTCoreUtil topViewController];
                if (self->_callAudioVC == topVC) {
                    [self->_callAudioVC beHungUp];
                }else {
                    [self->_callVideoVC beHungUp];
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[TIoTTRTCUIManage sharedManager] exitRoom:[TIoTTRTCUIManage sharedManager].deviceParam._sys_userid];
                });
            }
        });
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        UIViewController *topVC = [TIoTCoreUtil topViewController];
        if (self->_callAudioVC == topVC) {
            [self->_callAudioVC hungUp];
        }else {
            [self->_callVideoVC hungUp];
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[TIoTTRTCUIManage sharedManager] exitRoom:[TIoTTRTCUIManage sharedManager].deviceParam._sys_userid];
        });
    }];
}

- (void)didRefuseedRoom {
    
    if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_free) {
        if ([TIoTTRTCUIManage sharedManager].preCallingType == TIoTTRTCSessionCallType_audio) {
            if ([TIoTTRTCUIManage sharedManager].tempModel._sys_audio_call_status.intValue != 2) {
                [[TIoTTRTCUIManage sharedManager] refuseOtherCallWithDeviceReport:@{@"_sys_audio_call_status":@"0"} deviceID:[TIoTTRTCUIManage sharedManager].deviceIDTempStr];
            }
        }else if ([TIoTTRTCUIManage sharedManager].preCallingType == TIoTTRTCSessionCallType_video) {
            if ([TIoTTRTCUIManage sharedManager].tempModel._sys_video_call_status.intValue != 2) {
                [[TIoTTRTCUIManage sharedManager] refuseOtherCallWithDeviceReport:@{@"_sys_video_call_status":@"0"} deviceID:[TIoTTRTCUIManage sharedManager].deviceIDTempStr];
            }

        }

        [[TIoTTRTCUIManage sharedManager] cancelTimer];
    }

    if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
        if ([TIoTTRTCUIManage sharedManager].preCallingType == TIoTTRTCSessionCallType_audio) {
            [[TIoTTRTCUIManage sharedManager] exitRoom:@""];
        }else if ([TIoTTRTCUIManage sharedManager].preCallingType == TIoTTRTCSessionCallType_video) {
            [[TIoTTRTCUIManage sharedManager] exitRoom:@""];
        }
    }
    
}

- (void)leaveRoomWithPayload:(TIOTtrtcPayloadParamModel *)deviceParam {
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC) {
        
        if ([TIoTTRTCUIManage sharedManager].isActiveStatus == YES) {
            if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
                [_callAudioVC hungUp];
            }
            if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
                //单设备主叫 接通后 设备挂断
                if (deviceParam._sys_audio_call_status.intValue == 0) {
                    [self->_callAudioVC beHungUp];
                    
                }
            }

        }else {
            if (deviceParam._sys_audio_call_status.intValue == 2) {
                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling)  {
                    [_callAudioVC otherAnswered];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [TIoTTRTCUIManage sharedManager].tempModel = deviceParam;
                        [self->_callAudioVC hangupTapped];
                        [TIoTTRTCUIManage sharedManager].isActiveStatus = NO;
//                        self->_isActiveStatus = self->_isActiveCall;
                    });
                    return;
                }
                
            }else {
                
                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
                    [_callAudioVC hungUp];
                }else {
                    [_callAudioVC beHungUp];
                }
                
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!(deviceParam._sys_video_call_status.intValue == 2 || deviceParam._sys_audio_call_status.intValue == 2)) {
                
                UIViewController *topVC = [TIoTCoreUtil topViewController];
                if (self->_callAudioVC == topVC) {
                    [[TIoTTRTCUIManage sharedManager] exitRoom:deviceParam._sys_userid];
                }
            }
        });
    }else if (_callVideoVC == topVC) {
        
        if ([TIoTTRTCUIManage sharedManager].isActiveStatus == YES) {
            if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
                [_callVideoVC hungUp];
            }
            if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
                //单设备主叫 接通后 设备挂断
                if (deviceParam._sys_video_call_status.intValue == 0) {
                    [_callVideoVC beHungUp];
                }
            }
            
        }else {
            if (deviceParam._sys_video_call_status.intValue == 2) {
                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
                    [_callVideoVC otherAnswered];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [TIoTTRTCUIManage sharedManager].tempModel = deviceParam;
                        [self->_callVideoVC hangupTapped];
                        [TIoTTRTCUIManage sharedManager].isActiveStatus = NO;
//                        self->_isActiveStatus = self->_isActiveCall;
                    });
                    return;
                }
                
            }else {
                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
                    [_callVideoVC hungUp];
                }else {
                    [_callVideoVC beHungUp];
                }
                
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!(deviceParam._sys_video_call_status.intValue == 2 || deviceParam._sys_audio_call_status.intValue == 2)) {
                
                UIViewController *topVC = [TIoTCoreUtil topViewController];
                if (self->_callVideoVC ==topVC) {
                    [[TIoTTRTCUIManage sharedManager] exitRoom:deviceParam._sys_userid];
                }
            }
        });
    }
}

- (BOOL )isActiveCallingDeviceID:(NSString *_Nullable)deviceID topVC:(UIViewController *_Nullable)topVC {
    if (_callAudioVC == topVC || _callVideoVC == topVC) {
        //正在主动呼叫中，或呼叫UI已启动,直接进房间
        
        if ([TIoTTRTCUIManage sharedManager].isActiveStatus) { //如果是被动呼叫的话，不能自动进入房间
            [self didAcceptJoinRoom];
        }else {
            //当前是被叫空闲或是正在通话，这时需要判断：设备A、B同时呼叫同一个用户1，用户1已经被一台比方说是设备A呼叫，后接到其他设备B的呼叫请求，用户1则调用AppControldeviceData 发送callstatus为0拒绝其他设备B的请求。
            if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_free || [TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
                if ([TIoTTRTCUIManage sharedManager].deviceParam._sys_audio_call_status.intValue == 1) {
                    [[TIoTTRTCUIManage sharedManager] refuseOtherCallWithDeviceReport:@{@"_sys_audio_call_status":@"0"} deviceID:deviceID];
                }else if ([TIoTTRTCUIManage sharedManager].deviceParam._sys_video_call_status.intValue == 1) {
                    [[TIoTTRTCUIManage sharedManager] refuseOtherCallWithDeviceReport:@{@"_sys_video_call_status":@"0"} deviceID:deviceID];
                }
                
            }
        }
        return  YES;
    }else {
        return NO;
    }
}

- (void)remoteDismissAndDistoryVC {
    [_callAudioVC remoteDismiss];
    [_callVideoVC remoteDismiss];
    
    _callAudioVC = nil;
    _callVideoVC = nil;
}

- (void)audioNoAnswered {
    [_callAudioVC noAnswered];
}
- (void)videoNoAnswered {
    [_callVideoVC noAnswered];
}

- (void)enterUserRemoteUserID:(NSString *_Nullable)userID targetVC:(UIViewController *_Nullable)topVC  {
    if (_callAudioVC == topVC) {
        //正在主动呼叫中，或呼叫UI已启动
        [_callAudioVC OCEnterUserWithUserID:userID];
    }else {
        [_callVideoVC OCEnterUserWithUserID:userID];
    }
}

#pragma mark - getter

- (NSMutableDictionary *)reqArray
{
    if (!_reqArray) {
        _reqArray = [NSMutableDictionary dictionary];
    }
    return _reqArray;
}

@end
