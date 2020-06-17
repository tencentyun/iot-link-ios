//
//  AppDelegate.m
//  QCFrameworkDemo
//
//  Created by Wp on 2019/12/9.
//  Copyright © 2019 Reo. All rights reserved.
//

#import "AppDelegate.h"
#import <QCFoundation/TIoTCoreFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[TIoTCoreServices shared] setAppKey:@"您的Key"];
    [TIoTCoreServices shared].logEnable = YES;
    
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
