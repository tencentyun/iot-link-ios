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

#pragma mark -TIoTTRTCSessionUIDelegate
//呼起被叫页面，如果当前正在主叫页面，则外界UI不处理

- (BOOL)isActiveCalling:(NSString *)deviceUserID {
    UIViewController *topVC = [TIoTCoreUtil topViewController];
    if (_callAudioVC == topVC || _callVideoVC == topVC) {
        return  YES;
    }
    
    
#warning audio example
    _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:deviceUserID];
    _callAudioVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [[TIoTCoreUtil topViewController] presentViewController:_callAudioVC animated:NO completion:^{
        
        
    }];
    
    return NO;
}


- (void)preEnterRoom:(TIOTtrtcPayloadParamModel *)deviceParam failure:(FRHandler)failure {
    _deviceParam = deviceParam;
    
    if (deviceParam.userid == nil) {
        failure(@"DeviceId参数为空",nil,@{});
        return;
    }
    
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



- (void)repeatDeviceData:(NSArray *)devices {
    
    NSArray *productIDs = [devices valueForKey:@"ProductId"];
    [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":productIDs} success:^(id responseObject) {
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
    
    NSArray<TIoTDevicedListDataModel *> *devicelist = [NSArray yy_modelWithJSON:devices];
    for (TIoTDevicedListDataModel * device in devicelist) {

        if ([device.ProductId isEqualToString:productID]) {
            //通过产品ID筛选出设备Device，开始拉取Device的TRTC状态
            
            //1.是trtc设备,注册socket通知
            [HXYNotice postHeartBeat:@[device.DeviceId]];
            [HXYNotice addActivePushPost:@[device.DeviceId]];
            
            //2.是trtc设备,查看trtc状态是否为呼叫中1
            [[TIoTRequestObject shared] post:AppGetDeviceData Param:@{@"DeviceId":device.DeviceId} success:^(id responseObject) {
                NSString *tmpStr = (NSString *)responseObject[@"Data"];
                TIoTDeviceDataModel *product = [TIoTDeviceDataModel yy_modelWithJSON:tmpStr];
                
                if ([product.video_call_status.Value isEqualToString:@"1"]) {
                    [self isActiveCalling:device.DeviceId];
                }
                
            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                
            }];
            
        }
    }
    
}

@end
