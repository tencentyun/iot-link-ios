//
//  TIoTAppDelegate.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/16.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTAppDelegate.h"
#import "TIoTTabBarViewController.h"
#import "TIoTNavigationController.h"
#import "KeyboardManage.h"
#import "TIoTAppEnvironment.h"
#import "XGPushManage.h"
#import "TIoTLoginVC.h"
#import "TIoTMainVC.h"

#import "WxManager.h"
#import "WRNavigationBar.h"
#import "Firebase.h"

@implementation TIoTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[TIoTAppEnvironment shareEnvironment] selectEnvironmentType:WCAppEnvironmentTypeRelease];
    [[TIoTWebSocketManage shared] SRWebSocketOpen];
    
    //注册键盘全局事件
    [KeyboardManage registerIQKeyboard];
    
    //信鸽推送配置
    [XGPushManage sharedXGPushManage].launchOptions = launchOptions;
    [[XGPushManage sharedXGPushManage] startPushService];
    
    //注册微信
    [[WxManager sharedWxManager] registerApp]; 
    
    //firebase注册
    [FIRApp configure];
    
    if ([TIoTCoreUserManage shared].userId != nil) {
        //上报用户userid
        [FIRAnalytics setUserID:[TIoTCoreUserManage shared].userId];
    }
    
    TrueTimeClient *client = [TrueTimeClient sharedInstance];
    [client startWithPool:@[@"time.apple.com"] port:123];
    self.timeClient = client;
    
    // 1.创建窗口
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    if (@available(iOS 13.0, *)) {
        //程序一直是浅色模式
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    if ([TIoTCoreUserManage shared].isValidToken) {
        self.window.rootViewController = [[TIoTTabBarViewController alloc] init];
    }
    else{
        
//        TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTLoginVC alloc] init]];
        TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTMainVC alloc] init]];
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
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
      //NSLog(@"didReceiveRemoteNotification:APP在前台运行时，不做处理");
        //APP在前台，先暂不处理，后面跟产品商定
    }//当APP在后台运行时，当有通知栏消息时，点击它，就会执行下面的方法跳转到相应的页面
    else if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){
      // 取得 APNs 标准信息内容
      //NSLog(@"didReceiveRemoteNotification:APP在后台运行时，当有通知栏消息时，点击它，就会执行下面的方法跳转到相应的页面");
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    return [[WxManager sharedWxManager] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [[WxManager sharedWxManager] handleOpenUniversalLink:userActivity];
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
