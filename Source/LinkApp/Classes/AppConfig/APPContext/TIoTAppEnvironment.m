//
//  XDPAppEnvironment.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/4/2.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "TIoTAppEnvironment.h"
#import "ESP_NetUtil.h"
#import "XGPushManage.h"
#import "TIoTAppConfig.h"

@interface TIoTAppEnvironment ()
@end

@implementation TIoTAppEnvironment

+ (instancetype)shareEnvironment{
    
    static TIoTAppEnvironment *_environment ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _environment = [TIoTAppEnvironment new];
    });
    return _environment;
}

- (void)selectEnvironmentType{

    TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
    
    TIoTCoreAppEnvironment *environment = [TIoTCoreAppEnvironment shareEnvironment];
    [environment setEnvironment];
    
    environment.appKey = model.TencentIotLinkAppkey;
    environment.appSecret = model.TencentIotLinkAppSecret;
    // 请在 [environment setEnvironment]; 之后设置 oemAppApi 以免被覆盖。
//    environment.oemAppApi = @"需要替换为自建后台服务地址";
}

- (void)loginOut {
//    [[XGPushManage sharedXGPushManage] stopPushService];
    [HXYNotice addLoginOutPost];
    [[TIoTCoreUserManage shared] clear];
}

@end
