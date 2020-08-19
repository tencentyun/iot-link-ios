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
        [self setEnvironment];
    }
    return self;
}

- (void)setEnvironment {

    self.baseUrl = @"https://iot.cloud.tencent.com/api/studioapp";  //应用端 API 登录前所使用的 API URL(开源版和公版)
    self.signatureBaseUrlBeforeLogined = @"https://iot.cloud.tencent.com/api/exploreropen/appapi"; //应用端 API 登录前所使用的 API URL https://cloud.tencent.com/document/product/1081/40773
    
    self.baseUrlForLogined = @"https://iot.cloud.tencent.com/api/exploreropen/tokenapi"; //应用端 API 登录后所使用的 API URL https://cloud.tencent.com/document/product/1081/40773
    self.wsUrl = @"wss://iot.cloud.tencent.com/ws/explorer";        //长连接通信 https://cloud.tencent.com/document/product/1081/40792
    self.h5Url = @"https://iot.cloud.tencent.com/explorer-h5";
    self.wxShareType = 0;
    self.action = @"YunApi";
    self.appKey = @"";
    self.appSecret = @"";
    self.platform = @"iOS";
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
