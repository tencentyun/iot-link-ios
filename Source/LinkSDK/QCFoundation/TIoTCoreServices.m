//
//  QCApiConfiguration.m
//  QCApiClient
//
//  Created by Wp on 2020/2/27.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "QCServices.h"
#import "WCAppEnvironment.h"
#import "QCSocketManager.h"

@implementation QCServices

+ (instancetype)shared{
    static QCServices *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}



- (void)setAppKey:(NSString *)appkey
{
    [WCAppEnvironment shareEnvironment].environment = WCAppEnvironmentTypeRelease;
    
    [WCAppEnvironment shareEnvironment].appKey = appkey;
    _appKey = appkey;
    
    [[QCSocketManager shared] socketOpen];
}

- (void)setLogEnable:(BOOL)logEnable
{
    [[NSUserDefaults standardUserDefaults] setBool:logEnable forKey:@"pLogEnable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
