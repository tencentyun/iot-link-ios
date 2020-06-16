//
//  XDPAppEnvironment.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/4/2.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "WCAppEnvironment.h"

@interface WCAppEnvironment ()

@property (nonatomic , assign) WCAppEnvironmentType type;

@end

@implementation WCAppEnvironment

+ (instancetype)shareEnvironment{
    
    static WCAppEnvironment *_inst ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inst = [[self alloc] init];
    });
    return _inst;
}

- (void)setEnvironment:(WCAppEnvironmentType)environment
{
    _environment = environment;
    
    switch (environment) {
        case WCAppEnvironmentTypeRelease:{
            self.baseUrl = @"https://iot.cloud.tencent.com/api/studioapp";
            self.baseUrlForLogined = @"https://iot.cloud.tencent.com/api/exploreropen/tokenapi";
            self.wsUrl = @"wss://iot.cloud.tencent.com/ws/explorer";
            self.wxShareType = 0;
            self.action = @"YunApi";
            self.appKey = @"";
            self.appSecret = @"";
            self.platform = @"iOS";
        }
            break;
        case WCAppEnvironmentTypeDebug:{
            self.baseUrl = @"https://iot.cloud.tencent.com/api/studioapp";
            self.baseUrlForLogined = @"https://iot.cloud.tencent.com/api/exploreropen/tokenapi";
            self.wsUrl = @"wss://iot.cloud.tencent.com/ws/explorer";
            self.wxShareType = 1;
            self.action = @"YunApi";
            self.appKey = @"";
            self.appSecret = @"";
            self.platform = @"iOS";
        }
            break;
        default:
            break;
    }
}

@end
