//
//  TIoTP2PCommunicateUIManage.m
//  LinkApp
//
//

#import "TIoTP2PCommunicateUIManage.h"
#import "TIoTCoreUtil.h"
#import "TIoTTRTCSessionManager.h"
#import "HXYNotice.h"
#import "TIoTCoreUserManage.h"
//#import "TIoTRequestObject.h"
#import "YYModel.h"
#import "NSString+Extension.h"
#import "TIoTCoreRequestObject.h"
#import "UIDevice+Until.h"

#import "TIoTStatusManager.h"
#import "TIoTAVP2PPlayCaptureVC.h"

@interface TIoTP2PCommunicateUIManage ()<TRTCCallingViewDelegate,TIoTStatusManagerDelegate,TIoTAVP2PPlayCaptureVCDelegate> {
//    TRTCCallingAuidoViewController *_callAudioVC;
//    TRTCCallingVideoViewController *_callVideoVC;
    TIoTAVP2PPlayCaptureVC *_callP2PVideo;
//    socket payload
//    TIOTtrtcPayloadParamModel *_deviceParam;
    
//    BOOL _isActiveCall;
//    TIoTTRTCSessionCallType preCallingType;
//    NSString *deviceIDTempStr;
//    TIOTtrtcPayloadParamModel *tempModel;
    
//    NSTimer *noAnswerTimer; //主叫
//    NSTimer *behungupTimer; //被叫
    
}
@property (nonatomic, strong) NSMutableDictionary *deviceOfflineDic;
@property (nonatomic, strong) TIOTtrtcPayloadModel *reportModel; //监听设备上报
@property (nonatomic, strong) TIoTStatusManager *statusManager;
@end

@implementation TIoTP2PCommunicateUIManage

+ (instancetype)sharedManager {
    static TIoTP2PCommunicateUIManage *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        
//        _sharedManager.statusManager = [[TIoTStatusManager alloc]init];
//        _sharedManager.statusManager.delegate = _sharedManager;
            // RTC App端和设备端通话中 断网监听
//        [HXYNotice addCallingDisconnectNetLister:_sharedManager reaction:@selector(startHungupActionTimer)];
    });

    return _sharedManager;
}

- (void)setIsP2PVideoCommun:(BOOL)isP2PVideoCommun {
    _isP2PVideoCommun = isP2PVideoCommun;
    self.statusManager.isP2PVideoCommun = isP2PVideoCommun;
}

- (void)setStatusManager {
    if (self.statusManager == nil) {
        self.statusManager = [[TIoTStatusManager alloc]init];
        self.statusManager.delegate = [TIoTP2PCommunicateUIManage sharedManager];
    }
}

- (void)dealloc {
//    [self cancelTimer];
    
    [self.statusManager cancelTimer];
}

//该方法为5步骤，有三个方面会汇总到次，信鸽、websocket、轮训
//- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure {
//    if (deviceParam._sys_userid == nil) {
//        failure(@"DeviceId参数为空",nil,@{});
//        return;
//    }
//
//    if (_deviceParam._sys_userid) {
//        if ([_deviceParam.deviceName isEqualToString:deviceParam.deviceName]) {
//            _deviceParam = deviceParam;
//        }
//    }else {
//        _deviceParam = deviceParam;
//    }
//
////    _deviceParam = deviceParam;
//
//
//    if ([NSString isNullOrNilWithObject:_deviceID]) {
//        //单设备被呼叫
//        _isActiveCall = NO;//表示被呼叫
//        _isActiveStatus = _isActiveCall;
//    }else {
//        if (![NSString isNullOrNilWithObject:_deviceID] && ![_deviceID isEqualToString:deviceParam.deviceName]) {
//            _isActiveCall = NO;//表示被呼叫
//            _isActiveStatus = _isActiveCall;
//        }else {
//            _isActiveCall = YES;
//            _isActiveStatus = _isActiveCall;
//        }
//
//    }
//
//    //1.先启动UI，再根据UI选择决定是否走calldevice逻辑
//    [self isActiveCalling:deviceParam.deviceName];
//}

//- (void)preLeaveRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure {
//
//    _isActiveCall = NO;
//    _isActiveStatus = _isActiveCall;
//
//    if (_deviceParam._sys_userid) {
//        if ([deviceParam._sys_userid isEqualToString:_deviceParam._sys_userid]) {
//            if(deviceParam._sys_audio_call_status.intValue == 1 || deviceParam._sys_video_call_status.intValue == 1)
//            [self leaveRoomWith:deviceParam];
//        }
//
//        if ([[NSString stringWithFormat:@"%@%@",deviceParam._sys_userid,deviceParam.deviceName] isEqualToString:[NSString stringWithFormat:@"%@%@",_deviceParam._sys_userid,_deviceParam.deviceName]]) {
//            [self leaveRoomWith:deviceParam];
//        }
//
//        if (deviceParam._sys_audio_call_status.intValue == 2 || deviceParam._sys_video_call_status.intValue == 2) {
//            [self leaveRoomWith:deviceParam];
//        }
//
//        //case 1
//        if ([_deviceParam._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
//            [self leaveRoomWith:deviceParam];
//        }
//
//        if ([_deviceParam._sys_userid isEqualToString:_deviceParam.deviceName]) {
//            [self leaveRoomWith:deviceParam];
//        }
//
//    }else {
//        [self leaveRoomWith:deviceParam];
//    }
//
//}

- (void)audioActiveCallSessionNoCallingStatus {
    [_callP2PVideo hungUp];
    
    // isp2p
//    [self refuseAppCallingOrCalledEnterRoom];
    [self.statusManager refuseAppCallingOrCalledEnterRoom];
}

- (void)audioActiveCallSessionCallingStatus {
    [_callP2PVideo beHungUp];
    
    //isp2p
//    [self refuseAppCallingOrCalledEnterRoom];
    [self.statusManager refuseAppCallingOrCalledEnterRoom];
}

- (void)audioVCOtherAnswered {
    [_callP2PVideo otherAnswered];
}

- (void)audioVCHangupTapped {
    [_callP2PVideo hangupTapped];   //挂断
}

- (void)audioVCBeHungup {
    [_callP2PVideo beHungUp];
}

- (void)audioVCHungup {
    [_callP2PVideo hungUp];
}

- (void)videoActiveCallSessionNoCallingStatus {
    [_callP2PVideo hungUp];
    
    // isp2p
//    [self refuseAppCallingOrCalledEnterRoom];
    [self.statusManager refuseAppCallingOrCalledEnterRoom];
}

- (void)videoActiveCallSessionCallingStatus {
    [_callP2PVideo beHungUp];
    
    //is p2p
//    [self refuseAppCallingOrCalledEnterRoom];
    [self.statusManager refuseAppCallingOrCalledEnterRoom];
}

- (void)videoVCOtherAnswered {
    [_callP2PVideo otherAnswered];
}

- (void)videoVCHangupTapped {
    [_callP2PVideo hangupTapped];   //挂断
}

- (void)videoVCBeHungup {
    [_callP2PVideo beHungUp];
}

- (void)videoVCHungup {
    [_callP2PVideo hungUp];
}

- (void)statusManagerDismissVC {
    UIViewController *topVC = [TIoTCoreUtil topViewController];
//    if (_callVideoVC == topVC) {
//        [_callVideoVC dismissViewControllerAnimated:NO completion:nil];
//    }
//    if (_callAudioVC == topVC) {
//        [_callAudioVC dismissViewControllerAnimated:NO completion:nil];
//    }
    if (_callP2PVideo == topVC) {
        [_callP2PVideo hideTopView];
    }
}

- (void)remoteDismissSetting {
//    [_callAudioVC remoteDismiss];
//    [_callVideoVC remoteDismiss];
//
//    _callAudioVC = nil;
//    _callVideoVC = nil;
    
    //设备上报后必须进行置空，否则控制器没有释放，因为退出在前，上报再收，单例还持有
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    [topVC dismissViewControllerAnimated:NO completion:nil];
    _callP2PVideo = nil;
}

//- (void)leaveRoomWith:(TIOTtrtcPayloadParamModel *)deviceParam {
//
//    _deviceParam = nil;
//
//    UIViewController *topVC = [TIoTCoreUtil topViewController];
//    if (_callAudioVC == topVC) {
//
//        if (_isActiveCall == YES) {
//            if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
//                [_callAudioVC hungUp];
//                if (self.isP2PVideoCommun == YES) {//暂时
//                    [self refuseAppCallingOrCalledEnterRoom];
//                }
//            }
//            if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
//                //单设备主叫 接通后 设备挂断
//                if (deviceParam._sys_audio_call_status.intValue == 0) {
//                    [self->_callAudioVC beHungUp];
//                    if (self.isP2PVideoCommun == YES) {//暂时
//                        [self refuseAppCallingOrCalledEnterRoom];
//                    }
//                }
//            }
//
//        }else {
//            if (deviceParam._sys_audio_call_status.intValue == 2) {
//                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling)  {
//                    [_callAudioVC otherAnswered];
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        self->tempModel = deviceParam;
//                        [self->_callAudioVC hangupTapped];
//                        self->_isActiveCall = NO;
//                        self->_isActiveStatus = self->_isActiveCall;
////                        if (self.isP2PVideoCommun == YES) {
////                            [self exitRoom:@""];
////                        }
//                    });
//                    return;
//                }
//
//            }else {
//
//                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
//                    [_callAudioVC hungUp];
//                    if (self.isP2PVideoCommun == YES) {
//                        [self refuseAppCallingOrCalledEnterRoom];
//                    }
//                }else {
//                    [_callAudioVC beHungUp];
//                }
//
//            }
//        }
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (!(deviceParam._sys_video_call_status.intValue == 2 || deviceParam._sys_audio_call_status.intValue == 2)) {
//
//                UIViewController *topVC = [TIoTCoreUtil topViewController];
//                if (self->_callAudioVC == topVC) {
//                    [self exitRoom:deviceParam._sys_userid];
//                }
//            }
//        });
//    }else if (_callVideoVC == topVC) {
//
//        if (_isActiveCall == YES) {
//            if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
//                [_callVideoVC hungUp];
//                if (self.isP2PVideoCommun == YES) {//暂时
//                    [self refuseAppCallingOrCalledEnterRoom];
//                }
//            }
//            if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
//                //单设备主叫 接通后 设备挂断
//                if (deviceParam._sys_video_call_status.intValue == 0) {
//                    [_callVideoVC beHungUp];
//                    if (self.isP2PVideoCommun == YES) {//暂时
//                        [self refuseAppCallingOrCalledEnterRoom];
//                    }
//                }
//            }
//
//        }else {
//            if (deviceParam._sys_video_call_status.intValue == 2) {
//                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
//                    [_callVideoVC otherAnswered];
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        self->tempModel = deviceParam;
//                        [self->_callVideoVC hangupTapped];
//                        self->_isActiveCall = NO;
//                        self->_isActiveStatus = self->_isActiveCall;
////                        if (self.isP2PVideoCommun == YES) {
////                            [self exitRoom:@""];
////                        }
//                    });
//                    return;
//                }
//
//            }else {
//                if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
//                    [_callVideoVC hungUp];
//                    if (self.isP2PVideoCommun == YES) {
//                        [self refuseAppCallingOrCalledEnterRoom];
//                    }
//                }else {
//                    [_callVideoVC beHungUp];
//                }
//
//            }
//        }
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (!(deviceParam._sys_video_call_status.intValue == 2 || deviceParam._sys_audio_call_status.intValue == 2)) {
//
//                UIViewController *topVC = [TIoTCoreUtil topViewController];
//                if (self->_callVideoVC ==topVC) {
//                    [self exitRoom:deviceParam._sys_userid];
//                }
//            }
//        });
//    }
//
//}

//- (void)acceptAppCallingOrCalledEnterRoom {
//
//    _isEnterError = NO;
//
//    //取消计时器
//    [self cancelTimer];
//
//    //不存在进入房间，所以直接通话
//    UIViewController *topVC = [TIoTCoreUtil topViewController];
//    if (_callVideoVC == topVC) {
//        [_callVideoVC dismissViewControllerAnimated:NO completion:nil];
//    }
//    if (_callAudioVC == topVC) {
//        [_callAudioVC dismissViewControllerAnimated:NO completion:nil];
//    }
//}
//
//- (void)refuseAppCallingOrCalledEnterRoom {
//    [TIoTCoreUserManage shared].sys_call_status = @"-1";
//
//    if (self.isP2PVideoCommun == YES) {
//        UIViewController *topVC = [TIoTCoreUtil topViewController];
//        if (_callVideoVC == topVC) {
//            [_callVideoVC dismissViewControllerAnimated:NO completion:nil];
//        }
//        if (_callAudioVC == topVC) {
//            [_callAudioVC dismissViewControllerAnimated:NO completion:nil];
//        }
//    }
//
//    _isEnterError = NO;
//    _isActiveCall = NO;
//    _isActiveStatus = _isActiveCall;
//    preCallingType = TIoTTRTCSessionCallType_audio;
//    deviceIDTempStr = @"";
//    tempModel = nil;
//    [[TIoTTRTCSessionManager sharedManager] resetSessionType];
//    [_callAudioVC remoteDismiss];
//    [_callVideoVC remoteDismiss];
//
//    _callAudioVC = nil;
//    _callVideoVC = nil;
//
//    [self cancelTimer];
//}


- (void)acceptJoinRoom {
//    [self didAcceptJoinRoom];
    [self avP2PPlayAcceptClick];
}

- (void)didExitRoom:(NSString *)remoteUserID {
//    if (self.isP2PVideoCommun == YES) {
        UIViewController *topVC = [TIoTCoreUtil topViewController];
//        if (_callVideoVC == topVC) {
//            [_callVideoVC dismissViewControllerAnimated:NO completion:nil];
//        }
//        if (_callAudioVC == topVC) {
//            [_callAudioVC dismissViewControllerAnimated:NO completion:nil];
//        }
        if (_callP2PVideo == topVC) {
            [HXYNotice postP2PVIdeoExit];
//            [_callP2PVideo dismissViewControllerAnimated:NO completion:nil];
        }
//        [HXYNotice postP2PVIdeoExit];
//    }
}

#pragma mark- TIoTAVP2PPlayCaptureVCDelegate ui决定是否进入房间
//在TopView上  点击同意 隐藏topview后，开启start
- (void)avP2PPlayAcceptClick {
    [HXYNotice postStatusManagerCommunicateType:1];
    [self.statusManager setEnterErrorProperty:NO];
    
    if (self.statusManager.isActiveStatus == YES) { //APP主叫
        [self acceptAppCallingOrCalledEnterRoom];
    }else { //APP被叫
        //接收被呼叫
        if (![NSString isNullOrNilWithObject:self.statusManager.deviceParam._sys_video_call_status]) {
            [self requestControlDeviceDataWithReport:@{@"_sys_video_call_status":@"1"} deviceID:self.statusManager.deviceIDTempStr];

            [self acceptAppCallingOrCalledEnterRoom];
        }else if (![NSString isNullOrNilWithObject:self.statusManager.deviceParam._sys_audio_call_status]) {
            [self requestControlDeviceDataWithReport:@{@"_sys_audio_call_status":@"1"} deviceID:self.statusManager.deviceIDTempStr];
            [self acceptAppCallingOrCalledEnterRoom];
        }

    }
}

//在TopView上  点击拒绝或挂断按钮 退出，放回上页面
- (void)avP2PPlayRefuseOrHungupClick {
    [HXYNotice postStatusManagerCommunicateType:0];
    if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_free) {
        if (self.statusManager.preCallingType == TIoTTRTCSessionCallType_audio) {
            if (self.statusManager.tempModel._sys_audio_call_status.intValue != 2) {
                [self refuseOtherCallWithDeviceReport:@{@"_sys_audio_call_status":@"0"} deviceID:self.statusManager.deviceIDTempStr];
            }
        }else if (self.statusManager.preCallingType == TIoTTRTCSessionCallType_video) {
            if (self.statusManager.tempModel._sys_video_call_status.intValue != 2) {
                [self refuseOtherCallWithDeviceReport:@{@"_sys_video_call_status":@"0"} deviceID:self.statusManager.deviceIDTempStr];
            }

        }

        [self.statusManager cancelTimer];
    }

    if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
        if (self.statusManager.preCallingType == TIoTTRTCSessionCallType_audio) {
            [self exitRoom:@""];
        }else if (self.statusManager.preCallingType == TIoTTRTCSessionCallType_video) {

            [self exitRoom:@""];
        }
    }
}
/*
#pragma mark- TRTCCallingViewDelegate ui决定是否进入房间
- (void)didAcceptJoinRoom {
    //2.根据UI决定是否进入房间
    
//    if (self.isP2PVideoCommun == NO) {
//        //TRTC
//        //开始准备进房间，通话中状态
//        NSDictionary *param = @{@"DeviceId":_deviceParam.deviceName};
//
//        [[TIoTCoreRequestObject shared] post:AppIotRTCCallDevice Param:param success:^(id responseObject) {
//
//            NSDictionary *tempDic = responseObject[@"TRTCParams"];
//            TIOTTRTCModel *model = [TIOTTRTCModel yy_modelWithJSON:tempDic];
//            [[TIoTTRTCSessionManager sharedManager] configRoom:model];
//            [[TIoTTRTCSessionManager sharedManager] enterRoom];
//
//            //取消计时器
//            [self cancelTimer];
//
//
//             //一方已进入房间，另一方未成功进入或者异常退出，已等待15秒,已进入房间15秒内对方没有进入房间(TRTC有个回调onUserEnter，对方进入房间会触发这个回调)，则设备端和应用端提示对方已挂断，并退出
//            self->_isEnterError = YES;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                if (self->_isEnterError == YES) {
//                    UIViewController *topVC = [TIoTCoreUtil topViewController];
//                    if (self->_callAudioVC == topVC) {
//                        [self->_callAudioVC beHungUp];
//                    }else {
//                        [self->_callVideoVC beHungUp];
//                    }
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [self exitRoom:self->_deviceParam._sys_userid];
//                    });
//                }
//            });
//
//        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
//            UIViewController *topVC = [TIoTCoreUtil topViewController];
//            if (self->_callAudioVC == topVC) {
//                [self->_callAudioVC hungUp];
//            }else {
//                [self->_callVideoVC hungUp];
//            }
//
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self exitRoom:self->_deviceParam._sys_userid];
//            });
//        }];
//
//    }else {
        if (self.statusManager.isActiveStatus == YES) { //APP主叫
            [self acceptAppCallingOrCalledEnterRoom];
        }else { //APP被叫
            //接收被呼叫
            if (![NSString isNullOrNilWithObject:self.statusManager.deviceParam._sys_video_call_status]) {
                [self requestControlDeviceDataWithReport:@{@"_sys_video_call_status":@"1"} deviceID:self.statusManager.deviceIDTempStr];

                [self acceptAppCallingOrCalledEnterRoom];
            }else if (![NSString isNullOrNilWithObject:self.statusManager.deviceParam._sys_audio_call_status]) {
                [self requestControlDeviceDataWithReport:@{@"_sys_audio_call_status":@"1"} deviceID:self.statusManager.deviceIDTempStr];
                [self acceptAppCallingOrCalledEnterRoom];
            }

        }
//    }
}

- (void)didRefuseedRoom {
    
    if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_free) {
        if (self.statusManager.preCallingType == TIoTTRTCSessionCallType_audio) {
            if (self.statusManager.tempModel._sys_audio_call_status.intValue != 2) {
                [self refuseOtherCallWithDeviceReport:@{@"_sys_audio_call_status":@"0"} deviceID:self.statusManager.deviceIDTempStr];
            }
        }else if (self.statusManager.preCallingType == TIoTTRTCSessionCallType_video) {
            if (self.statusManager.tempModel._sys_video_call_status.intValue != 2) {
                [self refuseOtherCallWithDeviceReport:@{@"_sys_video_call_status":@"0"} deviceID:self.statusManager.deviceIDTempStr];
            }

        }

        [self.statusManager cancelTimer];
    }

    if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
        if (self.statusManager.preCallingType == TIoTTRTCSessionCallType_audio) {
            [self exitRoom:@""];
        }else if (self.statusManager.preCallingType == TIoTTRTCSessionCallType_video) {

            [self exitRoom:@""];
        }
    }
    
}
*/

- (void)statusManagerRefuseOtherCallWithDeviceReport:(NSDictionary *)reportDic deviceID:(NSString *)deviceID {
    [self requestControlDeviceDataWithReport:reportDic deviceID:deviceID];
}
- (void)statusManagerrequestControlDeviceDataWithReport:(NSDictionary *)reportDic deviceID:(NSString *)deviceID {
    [self requestControlDeviceDataWithReport:reportDic deviceID:deviceID];
}

#pragma mark - 拒绝其他设备呼叫
- (void)refuseOtherCallWithDeviceReport:(NSDictionary *)reportDic deviceID:(NSString *)deviceID {
    
//    if (self.isP2PVideoCommun == YES) {
//        [self exitRoom:@""];
//    }
    [self requestControlDeviceDataWithReport:reportDic deviceID:deviceID];
}

- (void)requestControlDeviceDataWithReport:(NSDictionary *)reportDic deviceID:(NSString *)deviceID {
    NSMutableDictionary *trtcReport = [reportDic mutableCopy];
    NSString *userId = [TIoTCoreUserManage shared].userId;
    if (userId) {
        [trtcReport setValue:userId forKey:@"_sys_userid"];
    }
    NSString *username = [TIoTCoreUserManage shared].nickName;
    if (username) {
        [trtcReport setValue:username forKey:@"username"];
    }
    
    NSString *productID = [deviceID?:@"" componentsSeparatedByString:@"/"].firstObject?:@"";
    NSString *deviceName = [deviceID?:@"" componentsSeparatedByString:@"/"].lastObject?:@"";
    
    NSDictionary *tmpDic = nil;
    
//    if (self.isP2PVideoCommun == NO) {
//        //TRTC
//        tmpDic = @{
//            @"ProductId":productID,
//            @"DeviceName":deviceName,
//            @"Data":[NSString objectToJson:trtcReport]?:@""};
//    }else {
        //P2P Video
        NSMutableDictionary *dataDic = [NSMutableDictionary new];
        if (trtcReport != nil) {
            dataDic = [NSMutableDictionary dictionaryWithDictionary:trtcReport];
        }
        
        //拼接agent
        NSString *agentString = [TIoTCoreUtil getSysUserAgent];
        [dataDic setValue:agentString forKey:@"_sys_user_agent"];
        
        if (self.statusManager.isActiveStatus == YES) { //主动
            //拼接主呼叫方_sys_caller_id
            [dataDic setValue:[TIoTCoreUserManage shared].userId?:@"" forKey:@"_sys_caller_id"];
            
            //拼接被呼叫方_sys_called_id
            NSString *deviceIDString = [NSString stringWithFormat:@"%@/%@",productID,deviceName];
            [dataDic setValue:deviceIDString forKey:@"_sys_called_id"];
        }else { //被动
            
//            [dataDic setValue:self.statusManager.deviceParam._sys_caller_id?:@"" forKey:@"_sys_caller_id"];
//            [dataDic setValue:self.statusManager.deviceParam._sys_called_id?:@"" forKey:@"_sys_called_id"];
            NSString *callerID = @"";
            NSString *calledID = @"";
            if ([NSString isNullOrNilWithObject:self.statusManager.deviceParam._sys_caller_id]) {
                callerID = [NSString stringWithFormat:@"%@/%@",productID,deviceName];
            }else {
                callerID = self.statusManager.deviceParam._sys_caller_id?:@"";
            }
            
            if ([NSString isNullOrNilWithObject:self.statusManager.deviceParam._sys_called_id]) {
                calledID = [TIoTCoreUserManage shared].userId?:@"";
            }else {
                calledID = self.statusManager.deviceParam._sys_called_id?:@"";
            }
            
            [dataDic setValue:callerID forKey:@"_sys_caller_id"];
            [dataDic setValue:calledID forKey:@"_sys_called_id"];
        }
        
        //Data json
        NSString *dataDicJson = [NSString objectToJson:dataDic];

        tmpDic = @{
            @"ProductId":productID,
            @"DeviceName":deviceName,
            @"Data":dataDicJson?:@""};
//    }
    
    [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
        DDLogDebug(@"AppControlDeviceData responseObject  %@",responseObject);
//        if (self.isP2PVideoCommun == YES) {
            if (self.statusManager.isActiveStatus == YES) {
                [self exitRoom:@""];
                [HXYNotice postP2PVIdeoExit];
            }
//        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
//        if (self.isP2PVideoCommun == YES) {
        [self exitRoom:@""];
            [HXYNotice postP2PVIdeoExit];
//        }
    }];
}
//---------------------TRTC设备轮训状态与注册物模型----------------------------

//- (void)repeatDeviceData:(NSArray *)devices{
//    //1.是trtc设备,注册socket通知
//    NSArray *devIds = [devices valueForKey:@"DeviceId"];
//    [HXYNotice postHeartBeat:devIds];
//    [HXYNotice addActivePushPost:devIds];
////    if (socketNotifitionBlock) {
////        socketNotifitionBlock(devIds);
////    }
//
//    NSArray *productIDs = [devices valueForKey:@"ProductId"];
//    NSSet *productIDSet = [NSSet setWithArray:productIDs];//去chong
//    [[TIoTCoreRequestObject shared] post:AppGetProducts Param:@{@"ProductIds":productIDSet.allObjects} success:^(id responseObject) {
//
//        NSArray *tmpArr = responseObject[@"Products"];
//        if (tmpArr.count > 0) {
//            for (NSDictionary *productDic in tmpArr) {
////                NSString *DataTemplate = productDic[@"DataTemplate"];
//    //            NSDictionary *DataTemplateDic = [NSString jsonToObject:DataTemplate];
////                TIoTDataTemplateModel *product = [TIoTDataTemplateModel yy_modelWithJSON:DataTemplate];
//    //            TIoTProductConfigModel *configModel = [TIoTProductConfigModel yy_modelWithJSON:config];
//                NSArray *serverArray = productDic[@"Services"]?:@[];
//
//                id categoryID = tmpArr.firstObject[@"CategoryId"];
//
//                if ([categoryID isKindOfClass:[NSString class]]) {
//                    if ([categoryID isEqualToString:@"567"]) {
//                        self.isP2PVideoCommun = YES;
//                    }
//                }else if ([categoryID isKindOfClass:[NSNumber class]]){
//                    NSNumber * categoryIDNum = categoryID;
//                    if (categoryIDNum.intValue == 567) {
//                        self.isP2PVideoCommun = YES;
//                    }
//                }else {
//                    self.isP2PVideoCommun = NO;
//                }
//
//                if ([serverArray containsObject:@"TRTC"] || self.isP2PVideoCommun == YES) {
//                    //是trtc设备,注册socket和检测trtc设备的状态
//                    [self getTRTCDeviceData:productDic[@"ProductId"]?:@"" devices:devices];
//                }
//            }
//
//        }
//
//    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
//
//    }];
//
//}


//- (void)getTRTCDeviceData:(NSString *)productID devices:(NSArray *)devices {
//
//    NSArray<TIoTDevicedListDataModel *> *devicelist = [NSArray yy_modelArrayWithClass:TIoTDevicedListDataModel.class json:devices];
//    for (TIoTDevicedListDataModel * device in devicelist) {
//
//        if ([device.ProductId isEqualToString:productID]) {
//            //通过产品ID筛选出设备Device，开始拉取Device的TRTC状态
//
//            //1.是trtc设备,注册socket通知,提前了注册时机了，要不然接口太多失败了就不知道啥原因
////            [HXYNotice postHeartBeat:@[device.DeviceId]];
////            [HXYNotice addActivePushPost:@[device.DeviceId]];
//
//            if (device.Online.intValue != 1) {
//                continue;
//            }
//            //2.是trtc设备,查看trtc状态是否为呼叫中1
//            [[TIoTCoreRequestObject shared] post:AppGetDeviceData Param:@{@"DeviceId":device.DeviceId} success:^(id responseObject) {
//                NSString *tmpStr = (NSString *)responseObject[@"Data"];
//                TIoTDeviceDataModel *product = [TIoTDeviceDataModel yy_modelWithJSON:tmpStr];
//
//
//                if ([product._sys_video_call_status.Value isEqualToString:@"1"] || [product._sys_audio_call_status.Value isEqualToString:@"1"]) {
//
//                    TIOTtrtcPayloadParamModel *payloadParam = [TIOTtrtcPayloadParamModel new];
//                    if (product._sys_userid.Value.length > 0) {
//                        payloadParam._sys_userid = product._sys_userid ? product._sys_userid.Value:device.DeviceId;
//
//                        if (![payloadParam._sys_userid containsString:[TIoTCoreUserManage shared].userId]) {
//                            //没给你打，目前正在跟别人打呢
//                            return;
//                        }
//                    }else {
//                        payloadParam._sys_userid = device.DeviceId;
//                    }
//                    payloadParam._sys_video_call_status = product._sys_video_call_status.Value;
//                    payloadParam._sys_audio_call_status = product._sys_audio_call_status.Value;
//                    payloadParam.deviceName = device.DeviceName;
//
//                    [self preEnterRoom:payloadParam failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
//                        DDLogError(@"error--%@",error);
//                    }];
//                }
//
//
//            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
//
//            }];
//
//        }
//    }
//
//}
//---------------------TRTC设备轮训状态与注册物模型----------------------------




//MARK: 监听到的设备上报信息处理
//- (void)receiveDeviceData:(NSDictionary *)deviceInfo {
//    //检测是否TRTC设备，是否在呼叫中
//    NSDictionary *payloadDic = [NSString base64Decode:deviceInfo[@"Payload"]];
//    DDLogInfo(@"----设备上报 payload:---%@",payloadDic);
//    DDLogInfo(@"----用户ID:---%@",[TIoTCoreUserManage shared].userId);
//    TIOTtrtcPayloadModel *model = [TIOTtrtcPayloadModel yy_modelWithJSON:payloadDic];
//    self.reportModel = model;
//    model.params.deviceName = deviceInfo[@"DeviceId"];
//    if (model.params._sys_userid.length < 1) {
//        model.params._sys_userid = deviceInfo[@"DeviceId"];
//    }
//
//
//    if ([payloadDic.allKeys containsObject:@"params"]) {
//        NSDictionary *paramsDic = payloadDic[@"params"];
//        if (paramsDic[@"_sys_audio_call_status"]) {
//            [TIoTCoreUserManage shared].sys_call_status = model.params._sys_audio_call_status;
//        }else if (paramsDic[@"_sys_video_call_status"]) {
//            [TIoTCoreUserManage shared].sys_call_status = model.params._sys_video_call_status;
//        }
//    }
//
//    if ([model.method isEqualToString:@"report"]) {
//
//        NSString *extrainfo = model.params._sys_extra_info;
//        if (extrainfo) {
//            //被拒绝就退出房间
//            TIOTtrtcRejectModel *rejectModel = [TIOTtrtcRejectModel yy_modelWithJSON:extrainfo];
//            if ([rejectModel.rejectUserId isEqualToString:[TIoTCoreUserManage shared].userId]) {
//                [self preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
//                    [MBProgressHUD showError:reason];
//                }];
//            }
//            return;
//        }
//
//
//        if (!model.params._sys_audio_call_status && !model.params._sys_video_call_status) {
//            //防止没上报status时候，走到了status=0的情况，新增if需要加在次前面，后面的status避免新增加判断
//            return;
//        }
//
//
//        if (model.params._sys_audio_call_status.intValue == 1 || model.params._sys_video_call_status.intValue == 1) {
//
//
//            if (self.isActiveStatus == YES && (![NSString isNullOrNilWithObject:self.deviceID] && [self.deviceID isEqualToString:model.params.deviceName])) {
//                //用户1和用户2（不同账号）同时呼叫设备,deviceA 接听，则会上报对应callstatus属性为1 和 先接收到的比方说是用户1的userid，对应的用户1会调用App::IotRTC::CallDevice加入房间，另一个用户2收到的上报消息查看userid不是自己，则提示对方正忙…，并退出
//                if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
//                    //TRTC设备需要通话，开始通话,防止不是trtc设备的通知
//                    [self preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
//
//                        [MBProgressHUD showError:reason];
//                    }];
//                }else {
//                    [self preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
//                        [MBProgressHUD showError:reason];
//                    }];
//                }
//            }else {
//
//                if ([model.params._sys_userid isEqualToString:model.params.deviceName]) {
//                    [self preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
//
//                        [MBProgressHUD showError:reason];
//                    }];
//                }else {
//                    NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
//                    for (NSString *userIdString in userIdArray) {
//                        model.params._sys_userid = userIdString?:@"";
//                        if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
//                            [self preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
//
//                                [MBProgressHUD showError:reason];
//                            }];
//                        }
//
//                    }
//                }
//
//            }
//        }else if (model.params._sys_audio_call_status.intValue == 2 || model.params._sys_video_call_status.intValue == 2) {
//
//            NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
//            for (NSString *userIdString in userIdArray) {
//
//                model.params._sys_userid = userIdString?:@"";
//                [self preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
//                    [MBProgressHUD showError:reason];
//                }];
//            }
//
//        }else if (model.params._sys_audio_call_status.intValue == 0 || model.params._sys_video_call_status.intValue == 0) {
//
//            NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
//            for (NSString *userIdString in userIdArray) {
//
//                model.params._sys_userid = userIdString?:@"";
//                if (self.isEnterError == NO) {
//                    if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
//
//                        if ([self.deviceID isEqualToString:model.params.deviceName]) {
//                            [self preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
//                                [MBProgressHUD showError:reason];
//                            }];
//                        }
//
//                    }else if ([model.params._sys_userid isEqualToString:model.params.deviceName]) {   //返回socket params 里没有userid时候（设备端主动呼叫，未接听，设备主动挂断）
//                           //防止case 3 中另一个设备 呼叫正在调起通话页面的APP
//                            [self preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
//                                [MBProgressHUD showError:reason];
//                            }];
//
//                    }
//
//                }
//
//            }
//
//
//        }
//
//    }
//
//    //异常
//    if ([deviceInfo[@"SubType"] isEqualToString:@"Offline"]) {
//
//        NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
//        for (NSString *userIdString in userIdArray) {
//
//            model.params._sys_userid = userIdString?:@"";
//            if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
//                [self preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
//                    [MBProgressHUD showError:reason];
//                }];
//            }
//
//        }
//    }
//}

- (void)statusManagerPayloadParamModel:(TIOTtrtcPayloadParamModel *)model type:(TIoTTRTCSessionCallType)type isFromReceived:(BOOL)isFromReceived reportDeviceDic:(NSMutableDictionary *)reportDeviceDic deviceID:(NSString *)deviceIDString;{
    
    if (self.isP2PVideoCommun == NO) {
        return;
    }
    
    BOOL isAccess = NO;
    if (type == TIoTTRTCSessionCallType_audio) {
       isAccess = [TIoTCoreUtil requestMediaAuthorization:AVMediaTypeAudio];
    }else {
       isAccess = [TIoTCoreUtil requestMediaAuthorization:AVMediaTypeVideo];
    }
    
    
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    NSString *productID = [deviceIDString?:@"" componentsSeparatedByString:@"/"].firstObject?:@"";
    NSString *deviceName = [deviceIDString?:@"" componentsSeparatedByString:@"/"].lastObject?:@"";
    
    if (isFromReceived == YES) {
//        if (type == TIoTTRTCSessionCallType_audio) { //audio
//            _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:self.statusManager.deviceParam._sys_userid];
//            _callAudioVC.deviceName = self.statusManager.deviceParam.deviceName;
//            _callAudioVC.actionDelegate = self;
//            _callAudioVC.modalPresentationStyle = UIModalPresentationFullScreen;
//            [[TIoTCoreUtil topViewController] presentViewController:_callAudioVC animated:NO completion:nil];
//
//            self.statusManager.callAudioVC = _callAudioVC;
//
//        }else if (type == TIoTTRTCSessionCallType_video) { //video
//            _callVideoVC = [[TRTCCallingVideoViewController alloc] initWithOcUserID:self.statusManager.deviceParam._sys_userid];
//            _callVideoVC.deviceName = self.statusManager.deviceParam.deviceName;
//            _callVideoVC.actionDelegate = self;
//            _callVideoVC.modalPresentationStyle = UIModalPresentationFullScreen;
//            [[TIoTCoreUtil topViewController] presentViewController:_callVideoVC animated:NO completion:nil];
//
//            self.statusManager.callVideoVC = _callVideoVC;
//        }
        
        
        NSMutableDictionary *reportDic = [NSMutableDictionary new];
        if (![NSString isNullOrNilWithObject:model._sys_video_call_status]) {
            [reportDic setValue:model._sys_video_call_status?:@"" forKey:@"_sys_video_call_status"];
        }else if (![NSString isNullOrNilWithObject:model._sys_audio_call_status]) {
            [reportDic setValue:model._sys_audio_call_status?:@"" forKey:@"_sys_audio_call_status"];
        }
        
//        [reportDic setValue:model._sys_userid?:@"" forKey:@"_sys_userid"];
        if (self.statusManager.isActiveStatus == YES) {
            if (![NSString isNullOrNilWithObject:model._sys_caller_id]) {
                [reportDic setValue:model._sys_caller_id?:@"" forKey:@"_sys_userid"];
            }else {
                [reportDic setValue:model._sys_userid?:@"" forKey:@"_sys_userid"];
            }
        }else if (self.statusManager.isActiveStatus == NO){
            
        }
        [reportDic setValue:[TIoTCoreUserManage shared].nickName?:@"" forKey:@"username"];
        
        _callP2PVideo = [[TIoTAVP2PPlayCaptureVC alloc]init];
        _callP2PVideo.deviceName = deviceName?:@"";
        _callP2PVideo.productID = productID?:@"";
        _callP2PVideo.callType = type;
        _callP2PVideo.reportDataDic = reportDic;
        _callP2PVideo.payloadParamModel = model;  //(被叫才传)
        _callP2PVideo.isCallIng = NO;
        _callP2PVideo.delegate = self;
        _callP2PVideo.modalPresentationStyle = UIModalPresentationFullScreen;
        if (isAccess == YES) {
            [topVC presentViewController:_callP2PVideo animated:NO completion:^{}];
        }
        
    }else {
        //面板手动呼叫
        
//        if (type == TIoTTRTCSessionCallType_audio) { //audio
//            _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:nil];
//            _callAudioVC.actionDelegate = self;
//            _callAudioVC.modalPresentationStyle = UIModalPresentationFullScreen;
//            [[TIoTCoreUtil topViewController] presentViewController:_callAudioVC animated:NO completion:^{}];
//
//            self.statusManager.callAudioVC = _callAudioVC;
//
//        }else if (type == TIoTTRTCSessionCallType_video) { //video
//            _callVideoVC = [[TRTCCallingVideoViewController alloc] initWithOcUserID:nil];
//            _callVideoVC.actionDelegate = self;
//            _callVideoVC.modalPresentationStyle = UIModalPresentationFullScreen;
//            [[TIoTCoreUtil topViewController] presentViewController:_callVideoVC animated:NO completion:^{}];
//
//            self.statusManager.callVideoVC = _callVideoVC;
//
//        }
        
        NSString *productID = [deviceIDString?:@"" componentsSeparatedByString:@"/"].firstObject?:@"";
        NSString *deviceName = [deviceIDString?:@"" componentsSeparatedByString:@"/"].lastObject?:@"";
        
        _callP2PVideo = [[TIoTAVP2PPlayCaptureVC alloc]init];
        _callP2PVideo.deviceName = deviceName?:@"";
        _callP2PVideo.productID = productID?:@"";
        _callP2PVideo.callType = type;
        _callP2PVideo.reportDataDic = reportDeviceDic;
        _callP2PVideo.isCallIng = YES;
        _callP2PVideo.delegate = self;
        _callP2PVideo.modalPresentationStyle = UIModalPresentationFullScreen;
        if (isAccess == YES) {
            [topVC presentViewController:_callP2PVideo animated:NO completion:^{}];
        }
    }
}

//- (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo withDevideId:(NSString *)deviceIdString {
//    _isActiveCall = YES; //表示主动呼叫
//    _isActiveStatus = _isActiveCall;
//
//    preCallingType = audioORvideo;
//    deviceIDTempStr = deviceIdString?:@"";
//
//    UIViewController *topVC = [TIoTCoreUtil topViewController];
//    if (_callAudioVC == topVC || _callVideoVC == topVC) {
//        //正在主动呼叫中，或呼叫UI已启动
//        return;
//    }
//
//    if (audioORvideo == TIoTTRTCSessionCallType_audio) { //audio
//        _deviceID = deviceIDTempStr;
//        _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:nil];
//        _callAudioVC.actionDelegate = self;
//        _callAudioVC.modalPresentationStyle = UIModalPresentationFullScreen;
//        [[TIoTCoreUtil topViewController] presentViewController:_callAudioVC animated:NO completion:^{}];
//
//    }else if (audioORvideo == TIoTTRTCSessionCallType_video) { //video
//        _deviceID = deviceIDTempStr;
//        _callVideoVC = [[TRTCCallingVideoViewController alloc] initWithOcUserID:nil];
//        _callVideoVC.actionDelegate = self;
//        _callVideoVC.modalPresentationStyle = UIModalPresentationFullScreen;
//        [[TIoTCoreUtil topViewController] presentViewController:_callVideoVC animated:NO completion:^{}];
//    }
//
//    //若对方60秒未接听，则显示对方无人接听…，并主动挂断退出
//
//    noAnswerTimer = [NSTimer scheduledTimerWithTimeInterval:59.0 target:self selector:@selector(hungupAction:) userInfo:nil repeats:NO];
//    [[NSRunLoop mainRunLoop] addTimer:noAnswerTimer forMode: NSRunLoopCommonModes];
//}

//- (void)hungupAction:(NSTimer *)sender {
//    if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling)  {
//        [self hungupActionUIStatusJudgement];
//    }
//}

//- (void)hungupActionUIStatusJudgement {
//    if (self->_deviceParam._sys_audio_call_status.intValue == 0 || self->_deviceParam._sys_video_call_status.intValue == 0) {
//        if (preCallingType == TIoTTRTCSessionCallType_audio) {
//            [self->_callAudioVC noAnswered];
//
//        }else if (preCallingType == TIoTTRTCSessionCallType_video) {
//            [self->_callVideoVC noAnswered];
//        }
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self exitRoom:@""];
//        });
//    }
//}

- (void)audioVCNoAnswered {
    [_callP2PVideo noAnswered];
}

- (void)videoVCNoAnswered {
    [_callP2PVideo noAnswered];
}

//- (BOOL)isActiveCalling:(NSString *)deviceID {
//    deviceIDTempStr = deviceID;
//    UIViewController *topVC = [TIoTCoreUtil topViewController];
//    if (_callAudioVC == topVC || _callVideoVC == topVC) {
//        //正在主动呼叫中，或呼叫UI已启动,直接进房间
//
//        if (_isActiveCall) { //如果是被动呼叫的话，不能自动进入房间
//            [self didAcceptJoinRoom];
//        }else {
//            //当前是被叫空闲或是正在通话，这时需要判断：设备A、B同时呼叫同一个用户1，用户1已经被一台比方说是设备A呼叫，后接到其他设备B的呼叫请求，用户1则调用AppControldeviceData 发送callstatus为0拒绝其他设备B的请求。
//            if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_free || [TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling) {
//                if (_deviceParam._sys_audio_call_status.intValue == 1) {
//                    [self refuseOtherCallWithDeviceReport:@{@"_sys_audio_call_status":@"0"} deviceID:deviceID];
//                }else if (_deviceParam._sys_video_call_status.intValue == 1) {
//                    [self refuseOtherCallWithDeviceReport:@{@"_sys_video_call_status":@"0"} deviceID:deviceID];
//                }
//
//            }
//        }
//        return  YES;
//    }
//
//    _isActiveCall = NO;//表示被呼叫
//    _isActiveStatus = _isActiveCall;
//    if (self.isP2PVideoCommun == NO) {
//        [self showAppCalledVideoVC];
//    }
//
//    //若60秒被叫不接听，则主动挂断退出  应该在接收到socket status=0时 触发
//    behungupTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(beHungupAction:) userInfo:nil repeats:NO];
//    [[NSRunLoop mainRunLoop] addTimer:behungupTimer forMode: NSRunLoopCommonModes];
//
//    return NO;
//}

//- (void)showAppCalledVideoVC {
//    //被呼叫了，点击接听后才进房间吧
//    if (_deviceParam._sys_audio_call_status.intValue == 1) { //audio
//
//        _deviceID = _deviceParam.deviceName;
//        _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:_deviceParam._sys_userid];
//        _callAudioVC.deviceName = _deviceParam.deviceName;
//        _callAudioVC.actionDelegate = self;
//        _callAudioVC.modalPresentationStyle = UIModalPresentationFullScreen;
//        [[TIoTCoreUtil topViewController] presentViewController:_callAudioVC animated:NO completion:nil];
//
//
//    }else if (_deviceParam._sys_video_call_status.intValue == 1) { //video
//
//        _deviceID = _deviceParam.deviceName;
//            _callVideoVC = [[TRTCCallingVideoViewController alloc] initWithOcUserID:_deviceParam._sys_userid];
//            _callVideoVC.deviceName = _deviceParam.deviceName;
//            _callVideoVC.actionDelegate = self;
//            _callVideoVC.modalPresentationStyle = UIModalPresentationFullScreen;
//            [[TIoTCoreUtil topViewController] presentViewController:_callVideoVC animated:NO completion:^{
//        //            [[TIoTTRTCSessionManager sharedManager] enterRoom];
//            }];
//    }
//}

//- (void)beHungupAction:(NSTimer *)sender {
//    if ([TIoTTRTCSessionManager sharedManager].state != TIoTTRTCSessionType_calling) {
//        if (self->_deviceParam._sys_audio_call_status.intValue == 0 || self->_deviceParam._sys_video_call_status.intValue == 0) {
//            [self exitRoom:@""];
//        }
//
//    }
//}

/// MARK: 设备断网后保存DeviceID和offline 状态用于退出页面区分提示判断 @{@"DeviceId:":@"";@"Offline":@(YES)}
//- (void)setDeviceDisConnectDic:(NSDictionary *)deviceDic {
//    self.deviceOfflineDic = [NSMutableDictionary dictionaryWithDictionary:deviceDic];
//}

- (void)judgeTopVC {
    UIViewController *topVC = [TIoTCoreUtil topViewController];
//    if (_callAudioVC == topVC || _callVideoVC == topVC || _callP2PVideo == topVC) {
    if (_callP2PVideo == topVC) {
        //正在主动呼叫中，或呼叫UI已启动
        return;
    }
}

#pragma mark - 断网Timer

//- (void)startHungupActionTimer {
//
//    if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling)  {
//        [self performSelector:@selector(callingHungupAction) withObject:nil afterDelay:60];
//    }
//
//}

//- (void)callingHungupAction {
//    if ([TIoTTRTCSessionManager sharedManager].state == TIoTTRTCSessionType_calling)  {
//        [self hungupActionUIStatusJudgement];
//    }
//}

#pragma mark -TIoTTRTCSessionUIDelegate   (video 不走TRTCsession代理)
//呼起被叫页面，如果当前正在主叫页面，则外界UI不处理

- (void)showRemoteUser:(NSString *)remoteUserID {
//    _isEnterError = NO;
    [self.statusManager setEnterErrorProperty:NO];
    
    /*
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC) {
        //正在主动呼叫中，或呼叫UI已启动
        [_callAudioVC OCEnterUserWithUserID:remoteUserID];
    }else {
        [_callVideoVC OCEnterUserWithUserID:remoteUserID];
    }
    */
}

- (void)exitRoom:(NSString *)remoteUserID {
    
//    [TIoTCoreUserManage shared].sys_call_status = @"-1";
//
//    if (self.isP2PVideoCommun == YES) {
//        UIViewController *topVC = [TIoTCoreUtil topViewController];
//        if (_callVideoVC == topVC) {
//            [_callVideoVC dismissViewControllerAnimated:NO completion:nil];
//        }
//        if (_callAudioVC == topVC) {
//            [_callAudioVC dismissViewControllerAnimated:NO completion:nil];
//        }
//        [HXYNotice postP2PVIdeoExit];
//    }
//
////    _isEnterError = NO;
//    [self.statusManager setEnterErrorProperty:NO];
//
//    _isActiveCall = NO;
//    _isActiveStatus = _isActiveCall;
//    preCallingType = TIoTTRTCSessionCallType_audio;
//    deviceIDTempStr = @"";
//    tempModel = nil;
//    [[TIoTTRTCSessionManager sharedManager] resetSessionType];
//    [_callAudioVC remoteDismiss];
//    [_callVideoVC remoteDismiss];
//
//    _callAudioVC = nil;
//    _callVideoVC = nil;
//
//
//    [self.statusManager cancelTimer];
//
////    self.isP2PVideoCommun = NO;
//
//    NSString *deviceString = self.deviceOfflineDic[@"DeviceId"]?:@"";
//    NSNumber *offline = self.deviceOfflineDic[@"Offline"]?:@(NO);
//    NSString *tipString = @"对方已挂断";
//    if (![NSString isNullOrNilWithObject:deviceString] && [deviceString isEqualToString:self.statusManager.deviceID] && offline.boolValue) {
//        tipString = @"对方设备已离线，请稍后再试";
//        self.deviceOfflineDic = nil;
//    }
//
//    if (remoteUserID.length > 0) {
//        [MBProgressHUD showError:tipString];
//    }
    
    [self didExitRoom:remoteUserID];
    
    [self.statusManager settingExitRoom:remoteUserID];
}

//- (void)cancelTimer {
//    if (noAnswerTimer) {
//        [noAnswerTimer invalidate];
//        noAnswerTimer = nil;
//    }
//
//    if (behungupTimer) {
//        [behungupTimer invalidate];
//        behungupTimer = nil;
//    }
//
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callingHungupAction) object:nil];
//}
//
//- (NSMutableDictionary *)deviceOfflineDic {
//    if (!_deviceOfflineDic) {
//        _deviceOfflineDic = [[NSMutableDictionary alloc]init];
//    }
//    return _deviceOfflineDic;
//}

#pragma mark - 内部调用
- (void)acceptAppCallingOrCalledEnterRoom {
//    //替换 可直接在控制器中退出对应音视频vc
//    //不存在进入房间，所以直接通话
//    UIViewController *topVC = [TIoTCoreUtil topViewController];
//    if (_callVideoVC == topVC) {
//        [_callVideoVC dismissViewControllerAnimated:NO completion:nil];
//    }
//    if (_callAudioVC == topVC) {
//        [_callAudioVC dismissViewControllerAnimated:NO completion:nil];
//    }
     
    
    [self.statusManager acceptAppCallingOrCalledEnterRoom];
    
}


#pragma mark - 外部调用
- (void)p2pCommunicateCallDeviceFromPanel:(TIoTTRTCSessionCallType)audioORvideo withDevideId:(NSString *)deviceIdString reportDeviceDic:(NSMutableDictionary *)reportDic {
    [self.statusManager callDeviceFromPanel:audioORvideo withDevideId:deviceIdString reportDeviceDic:reportDic];
}

- (void)p2pCommunicatePreEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure {
    [self.statusManager preEnterRoom:deviceParam failure:failure];
}

- (void)p2pCommunicatePreLeaveRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure {
    [self.statusManager preLeaveRoom:deviceParam failure:failure];
}


///轮训设备状态，查看trtc设备是否要呼叫我, 必须要实现发送socket通知，触发socket心跳:
- (void)p2pCommunicateRepeatDeviceData:(NSArray *)devices {
    [self.statusManager repeatDeviceData:devices];
}

/// 监听到的设备上报信息处理
- (void)p2pCommunicateReceiveDeviceData:(NSDictionary *)deviceInfo {
    [self.statusManager receiveDeviceData:deviceInfo];
}

/// 关闭断网时候 60超时计时器
- (void)p2pCommunicateCallingHungupAction {
    [self.statusManager callingHungupAction];
}

/// 设备断网后保存DeviceID和offline 状态用于退出页面区分提示判断 @{@"DeviceId:":@"";@"Offline":@(YES)}
- (void)p2pCommunicateSetDeviceDisConnectDic:(NSDictionary *)deviceDic {
    [self.statusManager setDeviceDisConnectDic:deviceDic];
}

///p2pVideo APP主叫(被叫)进入通话
- (void)p2pCommunicateAcceptAppCallingOrCalledEnterRoom {
    [self acceptAppCallingOrCalledEnterRoom];
}
///p2pVideo 退出页面
- (void)p2pCommunicateRefuseAppCallingOrCalledEnterRoom {
    [self.statusManager refuseAppCallingOrCalledEnterRoom];
}
///p2pVieo APP被叫 推出音、视频请求页面
- (void)p2pCommunicateShowAppCalledVideoVC {
    [self.statusManager showAppCalledVideoVC];
}

@end
