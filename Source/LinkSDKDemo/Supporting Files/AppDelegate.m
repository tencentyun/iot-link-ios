//
//  AppDelegate.m
//  QCFrameworkDemo
//
//

#import "AppDelegate.h"
#import "TIoTCoreFoundation.h"
#import "TIoTCoreAppEnvironment.h"
#import "TIoTDemoWebSocketManager.h"
#import "TIoTCoreServices.h"
#import "TIoTPrintLogManager.h"
#import "WxManager.h"
#import "LinkSDKDemo-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
        
    /*
     * 此处仅供参考, 需自建服务接入物联网平台服务，以免 App Secret 泄露
     * 自建服务可参考此处 https://cloud.tencent.com/document/product/1081/45901#.E6.90.AD.E5.BB.BA.E5.90.8E.E5.8F.B0.E6.9C.8D.E5.8A.A1.2C-.E5.B0.86-app-api-.E8.B0.83.E7.94.A8.E7.94.B1.E8.AE.BE.E5.A4.87.E7.AB.AF.E5.8F.91.E8.B5.B7.E5.88.87.E6.8D.A2.E4.B8.BA.E7.94.B1.E8.87.AA.E5.BB.BA.E5.90.8E.E5.8F.B0.E6.9C.8D.E5.8A.A1.E5.8F.91.E8.B5.B7
     */
    
    TIoTCoreAppEnvironment *environment = [TIoTCoreAppEnvironment shareEnvironment];
    [environment setEnvironment];
    
//    [[TIoTDemoWebSocketManager shared] SRWebSocketOpen];
    
    //注册微信
    [[WxManager sharedWxManager] registerApp:@"wx3c5a586d7fbcbace"];
    
    environment.appKey = @"物联网开发平台申请的 App Key";
    environment.appSecret = @"物联网开发平台申请的 App Secret";

    
    //开启打印日志
    [TIoTCoreServices shared].logEnable = true;
    //打印日志配
    [[TIoTPrintLogManager sharedManager] config];
    [[TIoTPrintLogManager sharedManager] setLogLevel:ddLogLevel];
    
    // 根据登录状态决定显示哪个页面
    if ([TIoTCoreUserManage shared].isValidToken) {
        // 已登录，跳转到DeviceListView
        [self showDeviceListView];
    } else {
        // 未登录，跳转到LoginView
        [self showLoginView];
    }
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterForeground" object:nil];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    return [[WxManager sharedWxManager] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    
    return [[WxManager sharedWxManager] handleOpenUniversalLink:userActivity];
}

#pragma mark - Navigation Methods

// 显示设备列表页面
- (void)showDeviceListView {
    // 创建UserManager、DeviceViewModel和NavigationBridge
    UserManager *userManager = [[UserManager alloc] init];
    DeviceViewModel *deviceViewModel = [[DeviceViewModel alloc] init];
    NavigationBridge *navigationBridge = [[NavigationBridge alloc] init];
    
    // 设置退出登录回调
    __weak typeof(self) weakSelf = self;
    userManager.logoutCallback = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoginView];
        });
    };
    
    // 创建DeviceListView控制器
    UIViewController *deviceListVC = [SwiftUIHelper createDeviceListViewControllerWithUserManager:userManager 
                                                                                   deviceViewModel:deviceViewModel 
                                                                                  navigationBridge:navigationBridge];
    
    // 创建导航控制器并设置为根视图控制器
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:deviceListVC];
    navController.navigationBar.prefersLargeTitles = NO;
    
    self.window.rootViewController = navController;
    
    [SwiftUIHelper setNavigationController:navController];
}

// 显示登录页面
- (void)showLoginView {
    // 创建LoginView控制器
    UIViewController *loginVC = [NSClassFromString(@"LoginVC") new];
    
    // 创建导航控制器并设置为根视图控制器
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    navController.navigationBar.prefersLargeTitles = NO;
    
    self.window.rootViewController = navController;
}

@end
