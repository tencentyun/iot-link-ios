//
//  TIoTDemoPlaybackVC.m
//  LinkSDKDemo
//
//

#import "TIoTDemoPlaybackVC.h"
#import "CMPageTitleView.h"
#import "TIoTCloudStorageVC.h"
#import "TIoTDemoLocalRecordVC.h"
#import "TIoTCoreXP2PBridge.h"
#import "TIoTCoreAppEnvironment.h"
#import "TIoTXp2pInfoModel.h"
#import "NSString+Extension.h"

@interface TIoTDemoPlaybackVC ()<CMPageTitleViewDelegate>
@property (nonatomic, strong) CMPageTitleView *pageView;
@property (nonatomic, strong) NSArray *childControllers;
@property (nonatomic, strong) TIoTCloudStorageVC *cloudStorageVC;
@property (nonatomic, strong) TIoTDemoLocalRecordVC *localRecordVC;
@end

@implementation TIoTDemoPlaybackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubViews];
    
    [self requestXp2pInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.cloudStorageVC clearMessage];
    
    [self.localRecordVC clearMessage];

}

- (void)nav_customBack {
    if (self.isFromHome) {
        if (self.isNVR == NO) {
            [[TIoTCoreXP2PBridge sharedInstance] stopService:self.deviceName?:@""];
        }
        [self removeMovieNotificationObservers];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    
    if (self.playerReloadBlock) {
        self.playerReloadBlock();
    }
    
    if (self.isNVR == NO) {
        if (self.isFromHome) {
            [[TIoTCoreXP2PBridge sharedInstance] stopService:self.deviceName?:@""];
        }
    }
    
    printf("debugdeinit---%s,%s,%d", __FILE__, __FUNCTION__, __LINE__);
}

- (void)requestXp2pInfo {
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"Version"] = @"2021-11-25";//@"2020-12-15";
    paramDic[@"DeviceName"] = self.deviceName?:@"";
    
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeDeviceData vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTXp2pInfoModel *model = [TIoTXp2pInfoModel yy_modelWithJSON:responseObject];
        NSDictionary *p2pInfo = [NSString jsonToObject:model.Data?:@""];
        TIoTXp2pModel *infoModel = [TIoTXp2pModel yy_modelWithJSON:p2pInfo];
        NSString *xp2pInfoString = infoModel._sys_xp2p_info.Value?:@"";
        
        [self requestDiffDeviceDataWithXp2pInfo:xp2pInfoString];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        [self requestDiffDeviceDataWithXp2pInfo:@""];
        [MBProgressHUD showError:@"xp2pInfo api请求失败"];
    }];
}

- (void)requestDiffDeviceDataWithXp2pInfo:(NSString *)xp2pInfo {
    if (self.isFromHome == YES) {
        if (self.isNVR == NO) {
            
            TIoTCoreAppEnvironment *env = [TIoTCoreAppEnvironment shareEnvironment];
            int errorcode = [[TIoTCoreXP2PBridge sharedInstance] startAppWith:env.cloudProductId dev_name:self.deviceName?:@""];
            [[TIoTCoreXP2PBridge sharedInstance] setXp2pInfo:self.deviceName?:@"" sec_id:env.cloudSecretId sec_key:env.cloudSecretKey xp2pinfo:xp2pInfo?:@""];
            
            if (errorcode == XP2P_ERR_VERSION) {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"APP SDK 版本与设备端 SDK 版本号不匹配，版本号需前两位保持一致" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
            }
            
            //计算IPC打洞开始时间
    //        self.startIpcP2P = CACurrentMediaTime();
            
        }
        
        [self installMovieNotificationObservers];
    }
}

- (void)initSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"回放";
    if (self.isFromHome == YES) {
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    }
//    self.fd_interactivePopDisabled = YES;
//    self.fd_prefersNavigationBarHidden = YES;
    
    [self.view addSubview:self.pageView];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64);
        }
        make.bottom.mas_equalTo(0);
    }];
    
    CMPageTitleConfig *config = [CMPageTitleConfig defaultConfig];
    config.cm_childControllers = self.childControllers;
    config.cm_switchMode = CMPageTitleSwitchMode_Underline;
    config.cm_additionalMode = CMPageTitleAdditionalMode_Seperateline;
    config.cm_seperaterLineColor = kRGBColor(230, 230, 230);
    config.cm_underlineColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    config.cm_underlineWidth = 30;
    config.cm_selectedColor = [UIColor colorWithHexString:@"#000000"];
    config.cm_selectedFont = [UIFont wcPfMediumFontOfSize:15];
    config.cm_font = [UIFont wcPfRegularFontOfSize:15];
    config.cm_normalColor = [UIColor colorWithHexString:kVideoDemoWeekLabelColor];
    config.cm_slideGestureEnable = NO;
    config.cm_contentMode = CMPageTitleContentMode_Center;
    config.cm_titleMargin = 0.0;
    config.cm_minTitleMargin = 0.0;
    self.pageView.cm_config = config;
    self.pageView.titleView.scrollEnabled = NO; //进制titleview滚动
    self.pageView.titleView.cm_size = CGSizeMake(kScreenWidth, 44);
}

- (CMPageTitleView *)pageView {
    if (!_pageView) {
        CMPageTitleView *pageTitleView = [[CMPageTitleView alloc] init];
        
        pageTitleView.delegate = self;
        _pageView = pageTitleView;
    }
    
    return _pageView;
}

- (NSArray *)childControllers {
    if (!_childControllers) {
        
        self.cloudStorageVC = [[TIoTCloudStorageVC alloc]init];
        self.localRecordVC = [[TIoTDemoLocalRecordVC alloc]init];
        
        self.cloudStorageVC.title = @"云记录";
        self.localRecordVC.title = @"本地记录";
        
        self.cloudStorageVC.deviceModel = self.deviceModel;
        self.cloudStorageVC.eventItemModel = self.eventItemModel;
        self.localRecordVC.deviceModel = self.deviceModel;
        self.localRecordVC.isNVR = self.isNVR;
        self.localRecordVC.deviceName = self.deviceName;
        
        _childControllers = @[self.cloudStorageVC,self.localRecordVC];
    }
    return _childControllers;
}


- (void)cm_pageTitleViewSelectedWithIndex:(NSInteger)index Repeat:(BOOL)repeat {

}

- (void)installMovieNotificationObservers{
    
    if (self.isNVR == NO) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refushVideo:)
                                                     name:@"xp2preconnect"
                                                   object:nil];
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseP2PdisConnect:)
                                                 name:@"xp2disconnect"
                                               object:nil];
}

-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"xp2preconnect" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"xp2disconnect" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refushVideo:(NSNotification *)notify {
    
    UIViewController *view = [self getCurrentViewController];
    if ([view isMemberOfClass:[TIoTDemoPlaybackVC class]]) {
        NSString *DeviceName = [notify.userInfo objectForKey:@"id"];
        NSString *selectedName = self.deviceName?:@"";
        
        if (![DeviceName isEqualToString:selectedName]) {
            return;
        }
        
        [MBProgressHUD show:[NSString stringWithFormat:@"%@ 通道建立成功",selectedName] icon:@"" view:self.view];
        
        //计算IPC打洞时间
//        self.endIpcP2P = CACurrentMediaTime();
        
        //NSString *appVersion = [TIoTCoreXP2PBridge getSDKVersion];
        // appVersion.floatValue < 2.1 旧设备直接播放，不用发送信令验证设备状态和添加参数
        /*
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:self.deviceName]?:@"";
             
             self.videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
             
             [self configVideo];
             [self.player prepareToPlay];
             [self.player play];
             
             self.startPlayer = CACurrentMediaTime();
         });
         */
        
//        [self getDeviceStatusWithType:action_live qualityType:self.qualityString];
    }
}

- (void)responseP2PdisConnect:(NSNotification *)notify {
    NSString *DeviceName = [notify.userInfo objectForKey:@"id"];
    NSString *selectedName = self.deviceName?:@"";
    
    if (![DeviceName isEqualToString:selectedName]) {
        return;
    }
    
    [MBProgressHUD showError:@"通道断开，正在重连"];
    
    
    [[TIoTCoreXP2PBridge sharedInstance] stopService: DeviceName];

    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"Version"] = @"2021-11-25";//@"2020-12-15";
    paramDic[@"DeviceName"] = self.deviceName?:@"";
    
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeDeviceData vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTXp2pInfoModel *model = [TIoTXp2pInfoModel yy_modelWithJSON:responseObject];
        NSDictionary *p2pInfo = [NSString jsonToObject:model.Data?:@""];
        TIoTXp2pModel *infoModel = [TIoTXp2pModel yy_modelWithJSON:p2pInfo];
        NSString *xp2pInfoString = infoModel._sys_xp2p_info.Value?:@"";
        
        [self resconnectXp2pWithDevicename:selectedName xp2pInfo:xp2pInfoString];
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        [self resconnectXp2pWithDevicename:selectedName xp2pInfo:@""];
        [MBProgressHUD showError:@"p2p重连 xp2pInfo api请求失败"];
    }];
}

- (void)resconnectXp2pWithDevicename:(NSString *)deviceName xp2pInfo:(NSString *)xp2pInfoString {
    TIoTCoreAppEnvironment *env = [TIoTCoreAppEnvironment shareEnvironment];
    [[TIoTCoreXP2PBridge sharedInstance] startAppWith:env.cloudProductId dev_name:deviceName?:@""];
    [[TIoTCoreXP2PBridge sharedInstance] setXp2pInfo:deviceName?:@"" sec_id:env.cloudSecretId sec_key:env.cloudSecretKey xp2pinfo:xp2pInfoString?:@""];
}

- (UIViewController *)getCurrentViewController
{
    UIViewController* currentViewController = [self getRootViewController];
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {

            currentViewController = currentViewController.presentedViewController;
        } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {

          UINavigationController* navigationController = (UINavigationController* )currentViewController;
            currentViewController = [navigationController.childViewControllers lastObject];

        } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {

          UITabBarController* tabBarController = (UITabBarController* )currentViewController;
            currentViewController = tabBarController.selectedViewController;
        } else {
            NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
                    if (childViewControllerCount > 0) {

                        currentViewController = currentViewController.childViewControllers.lastObject;

                        return currentViewController;
                    } else {

                        return currentViewController;
                    }
                }

            }
            return currentViewController;
}

- (UIViewController *)getRootViewController{

    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
