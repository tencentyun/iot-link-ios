//
//  XDPAppEnvironment.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/4/2.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "WCAppEnvironment.h"
#import "ESP_NetUtil.h"
#import "XGPushManage.h"

@interface WCAppEnvironment ()

@property (nonatomic , assign) WCAppEnvironmentType type;

@end

@implementation WCAppEnvironment

+ (instancetype)shareEnvironment{
    
    static WCAppEnvironment *_environment ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _environment = [WCAppEnvironment new];
    });
    return _environment;
}

- (void)selectEnvironmentType:(WCAppEnvironmentType)type{
    self.type = type;
    
    switch (type) {
        case WCAppEnvironmentTypeRelease:{
            self.baseUrl = @"https://iot.cloud.tencent.com/api/studioapp";
            self.baseUrlForLogined = @"https://iot.cloud.tencent.com/api/exploreropen/tokenapi";
            self.wsUrl = @"wss://iot.cloud.tencent.com/ws/explorer";
            self.wxShareType = 0;
            self.action = @"YunApi";
            self.appKey = @"iftGgQcbDMGlzZTMU";
            self.appSecret = @"QMOGnPaBACBKFDLGbTby";
            self.platform = @"iOS";
        }
            break;
        case WCAppEnvironmentTypeDebug:{
            self.baseUrl = @"https://iot.cloud.tencent.com/api/studioapp";
            self.baseUrlForLogined = @"https://iot.cloud.tencent.com/api/exploreropen/tokenapi";
            self.wsUrl = @"wss://iot.cloud.tencent.com/ws/explorer";
            self.wxShareType = 1;
            self.action = @"YunApi";
            self.appKey = @"iftGgQcbDMGlzZTMU";
            self.appSecret = @"QMOGnPaBACBKFDLGbTby";
            self.platform = @"iOS";
        }
            break;
        default:
            break;
    }
    
}

- (void)loginOut {
//    [[XGPushManage sharedXGPushManage] stopPushService];
    [HXYNotice addLoginOutPost];
    [[WCUserManage shared] clear];
    
}

@end
