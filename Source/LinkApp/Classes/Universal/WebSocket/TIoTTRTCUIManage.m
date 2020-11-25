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
        
        _callAudioVC = nil;
        _callVideoVC = nil;
        return  YES;
    }
    
    
#warning audio example
    _callAudioVC = [[TRTCCallingAuidoViewController alloc] initWithOcUserID:nil];
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

@end
