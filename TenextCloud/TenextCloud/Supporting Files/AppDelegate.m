//
//  AppDelegate.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/16.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "AppDelegate.h"
#import "WCTabBarViewController.h"
#import "WCNavigationController.h"
#import "KeyboardManage.h"
#import "WCAppEnvironment.h"
#import "XGPushManage.h"
#import "WCLoginVC.h"
#import "WxManager.h"
#import "WRNavigationBar.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[WCAppEnvironment shareEnvironment] selectEnvironmentType:WCAppEnvironmentTypeRelease];
    [[WCWebSocketManage shared] SRWebSocketOpen];
    
    //注册键盘全局事件
    [KeyboardManage registerIQKeyboard];
    
    //信鸽推送配置
    [XGPushManage sharedXGPushManage].launchOptions = launchOptions;
    [[XGPushManage sharedXGPushManage] startPushService];
    
    //注册微信
    [[WxManager sharedWxManager] registerApp];
    
    
    // 1.创建窗口
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    if (@available(iOS 13.0, *)) {
        //程序一直是浅色模式
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    if ([WCUserManage shared].isValidToken) {
        self.window.rootViewController = [[WCTabBarViewController alloc] init];
    }
    else{
        
        WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:[[WCLoginVC alloc] init]];
        self.window.rootViewController = nav;
    }
    
    [self setNavBarAppearence];
    // 4.显示窗口
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [[XGPushManage sharedXGPushManage] reportXGNotificationInfo:userInfo];
    WCLog(@"userInfo-静默消息---%@",[NSString jsonToObject:userInfo[@"custom"]]);
    completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    return [[WxManager sharedWxManager] handleOpenURL:url];
}


#pragma mark - navBar

- (void)setNavBarAppearence
{
    [WRNavigationBar wr_widely];
    [WRNavigationBar wr_setBlacklist:@[@"TZImagePickerController",
                                       @"TZPhotoPickerController",
                                       @"TZGifPhotoPreviewController",
                                       @"TZAlbumPickerController",
                                       @"TZPhotoPreviewController",
                                       @"TZVideoPlayerController"]];
    
    // 设置导航栏默认的背景颜色
    [WRNavigationBar wr_setDefaultNavBarBarTintColor:[UIColor whiteColor]];
    // 设置导航栏所有按钮的默认颜色
    [WRNavigationBar wr_setDefaultNavBarTintColor:kFontColor];
    // 设置导航栏标题默认颜色
    [WRNavigationBar wr_setDefaultNavBarTitleColor:kFontColor];
    // 统一设置状态栏样式
//    [WRNavigationBar wr_setDefaultStatusBarStyle:UIStatusBarStyleLightContent];
    // 如果需要设置导航栏底部分割线隐藏，可以在这里统一设置
    [WRNavigationBar wr_setDefaultNavBarShadowImageHidden:YES];
}

@end
