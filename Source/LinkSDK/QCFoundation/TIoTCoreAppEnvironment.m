//
//  XDPAppEnvironment.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/4/2.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "TIoTCoreAppEnvironment.h"

NSString *const TIoTLinkKitShortVersionString = @"1.0.3";

@interface TIoTCoreAppEnvironment ()

@property (nonatomic , assign) WCAppEnvironmentType type;

@end

@implementation TIoTCoreAppEnvironment

+ (instancetype)shareEnvironment{
    
    static TIoTCoreAppEnvironment *_inst ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inst = [[self alloc] init];
    });
    return _inst;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configBuglySDKInfos];
    }
    return self;
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

- (void)configBuglySDKInfos {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * componentId = @"3c26077475";
        NSString * version = TIoTLinkKitShortVersionString;
        if (componentId && version) {
            NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
            // 读取已有信息并记录
            NSDictionary * dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"BuglySDKInfos"];
            if (dict) {
                [dictionary addEntriesFromDictionary:dict];
            }
            // 添加当前组件的唯⼀一标识和版本
            [dictionary setValue:version forKey:componentId];
            // 写⼊入更更新的信息
            [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:dictionary] forKey:@"BuglySDKInfos"];
        }
    });
}

@end
