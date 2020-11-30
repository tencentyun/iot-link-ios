//
//  TIoTWebSocketManage+TRTC.m
//  LinkApp
//
//  Created by eagleychen on 2020/11/25.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTTRTCUIManage.h"
#import "TIoTCoreUtil.h"
#import "TIoTTRTCSessionManager.h"


NSString *const TIoTTRTCaudio_call_status = @"audio_call_status";
NSString *const TIoTTRTCvideo_call_status = @"video_call_status";


@interface TIoTTRTCUIManage () {
    TRTCCallingAuidoViewController *_callAudioVC;
    TRTCCallingVideoViewController *_callVideoVC;
    
    //socket payload
    TIOTtrtcPayloadParamModel *_deviceParam;
}
@end

@implementation TIoTTRTCUIManage

+ (instancetype)sharedManager {
    static TIoTTRTCUIManage *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

//该方法为5步骤，有三个方面会汇总到次，信鸽、websocket、轮训
- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure {
    if (deviceParam.userid == nil) {
        failure(@"DeviceId参数为空",nil,@{});
        return;
    }
    
    _deviceParam = deviceParam;
    
    //开始准备进房间，通话中状态
    NSDictionary *param = @{@"DeviceId":deviceParam.userid};
//    NSDictionary *tmpDic = @{@"ProductId":self.productId, @"DeviceName":self.deviceName};
    
    [[TIoTRequestObject shared] post:AppIotRTCCallDevice Param:param success:^(id responseObject) {
        NSLog(@"cccc--%@",responseObject);
        
        NSDictionary *tempDic = responseObject[@"TRTCParams"];
        TIOTTRTCModel *model = [TIOTTRTCModel yy_modelWithJSON:tempDic];
        [[TIoTTRTCSessionManager sharedManager] configRoom:model];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];

}



//---------------------TRTC设备轮训状态与注册物模型----------------------------
- (void)repeatDeviceData:(NSArray *)devices {

    NSArray *productIDs = [devices valueForKey:@"ProductId"];
    NSSet *productIDSet = [NSSet setWithArray:productIDs];//去chong
    [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":productIDSet.allObjects} success:^(id responseObject) {
        NSArray *data = responseObject[@"Data"];
        
        for (NSDictionary *configPanel in data) {
                        
            TIoTProductConfigModel *configModel = [TIoTProductConfigModel yy_modelWithJSON:configPanel[@"Config"]];
            
            if ([configModel.Global.trtc intValue] == 1) {
                
                //是trtc设备,注册socket和检测trtc设备的状态
                [self getTRTCDeviceData:configModel.profile.ProductId devices:devices];
            }
        }
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];

}


- (void)getTRTCDeviceData:(NSString *)productID devices:(NSArray *)devices {
    
    NSArray<TIoTDevicedListDataModel *> *devicelist = [NSArray yy_modelArrayWithClass:TIoTDevicedListDataModel.class json:devices];
    for (TIoTDevicedListDataModel * device in devicelist) {

        if ([device.ProductId isEqualToString:productID]) {
            //通过产品ID筛选出设备Device，开始拉取Device的TRTC状态
            
            //1.是trtc设备,注册socket通知
            [HXYNotice postHeartBeat:@[device.DeviceId]];
            [HXYNotice addActivePushPost:@[device.DeviceId]];
            
            if (device.Online.intValue != 1) {
                continue;
            }
            //2.是trtc设备,查看trtc状态是否为呼叫中1
            [[TIoTRequestObject shared] post:AppGetDeviceData Param:@{@"DeviceId":device.DeviceId} success:^(id responseObject) {
                NSString *tmpStr = (NSString *)responseObject[@"Data"];
                TIoTDeviceDataModel *product = [TIoTDeviceDataModel yy_modelWithJSON:tmpStr];
                
                
                if ([product.video_call_status.Value isEqualToString:@"1"] || [product.audio_call_status.Value isEqualToString:@"1"]) {
                    
                    TIOTtrtcPayloadParamModel *payloadParam = [TIOTtrtcPayloadParamModel new];
                    if (product.userid.Value.length > 0) {
                        payloadParam.userid = product.userid ? product.userid.Value:device.DeviceId;
                    }else {
                        payloadParam.userid = device.DeviceId;
                    }
                    payloadParam.video_call_status = product.video_call_status.Value;
                    payloadParam.audio_call_status = product.audio_call_status.Value;
                    
                    [self preEnterRoom:payloadParam failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                        NSLog(@"error--%@",error);
                    }];
                }
                
                
            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                
            }];
            
        }
    }
    
}
//---------------------TRTC设备轮训状态与注册物模型----------------------------




- (void)callDeviceFromPanel: (TIoTTRTCSessionCallType)audioORvideo {
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC || _callVideoVC == topVC) {
        //正在主动呼叫中，或呼叫UI已启动
        return;
    }

    if (audioORvideo == TIoTTRTCSessionCallType_audio) { //audio
        _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:nil];
        _callAudioVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TIoTCoreUtil topViewController] presentViewController:_callAudioVC animated:NO completion:^{}];
        
    }else if (audioORvideo == TIoTTRTCSessionCallType_video) { //video
        
        _callVideoVC = [[TRTCCallingVideoViewController alloc] initWithOcUserID:nil];
        _callVideoVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TIoTCoreUtil topViewController] presentViewController:_callVideoVC animated:NO completion:^{}];
    }
}

#pragma mark -TIoTTRTCSessionUIDelegate
//呼起被叫页面，如果当前正在主叫页面，则外界UI不处理

- (BOOL)isActiveCalling:(NSString *)deviceUserID {
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC || _callVideoVC == topVC) {
        //正在主动呼叫中，或呼叫UI已启动
        return  YES;
    }
    
    
    //被呼叫了，点击接听后才进房间吧
    if (_deviceParam.audio_call_status.intValue == 1) { //audio
        
        _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:_deviceParam.userid];
        _callAudioVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TIoTCoreUtil topViewController] presentViewController:_callAudioVC animated:NO completion:nil];

    }else if (_deviceParam.video_call_status.intValue == 1) { //video
        
        _callVideoVC = [[TRTCCallingVideoViewController alloc] initWithOcUserID:_deviceParam.userid];
        _callVideoVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [[TIoTCoreUtil topViewController] presentViewController:_callVideoVC animated:NO completion:^{
//            [[TIoTTRTCSessionManager sharedManager] enterRoom];
        }];
    }
    
    return NO;
}

- (void)showRemoteUser:(NSString *)remoteUserID {
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC) {
        //正在主动呼叫中，或呼叫UI已启动
        [_callAudioVC OCEnterUserWithUserID:remoteUserID];
    }else {
        [_callVideoVC OCEnterUserWithUserID:remoteUserID];
    }
}

- (void)exitRoom:(NSString *)remoteUserID {
    [_callAudioVC remoteDismiss];
    [_callVideoVC remoteDismiss];
    
    _callAudioVC = nil;
    _callVideoVC = nil;
}
@end
