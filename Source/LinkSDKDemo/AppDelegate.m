//
//  AppDelegate.m
//  QCFrameworkDemo
//
//  Created by Wp on 2019/12/9.
//  Copyright © 2019 Reo. All rights reserved.
//

#import "AppDelegate.h"
#import "TIoTCoreFoundation.h"
#import "Firebase.h"
#import "TIoTCoreAppEnvironment.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
        
    TIoTCoreAppEnvironment *environment = [TIoTCoreAppEnvironment shareEnvironment];
    [environment setEnvironment];
    
    environment.appKey = @"物联网开发平台申请的 App Key";
    environment.appSecret = @"物联网开发平台申请的 App Secret";

    //firebase注册
    [FIRApp configure];
    
    if (![TIoTCoreUserManage shared].isValidToken) {
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[NSClassFromString(@"LoginVC") new]];
    }
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterForeground" object:nil];
}


@end
