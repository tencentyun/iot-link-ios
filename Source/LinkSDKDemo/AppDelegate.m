//
//  AppDelegate.m
//  QCFrameworkDemo
//
//  Created by Wp on 2019/12/9.
//  Copyright © 2019 Reo. All rights reserved.
//

#import "AppDelegate.h"
#import <QCFoundation/QCFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[QCServices shared] setAppKey:@"您的Key"];
    [QCServices shared].logEnable = YES;
    
    if (![QCUserManage shared].isValidToken) {
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[NSClassFromString(@"LoginVC") new]];
    }
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterForeground" object:nil];
}


@end
