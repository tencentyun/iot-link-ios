//
//  TIoTDemoVideoPushVC.m
//  LinkSDKDemo
//
//  Created by eagleychen on 2023/4/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TIoTDemoVideoPushVC.h"
#import "TIoTDemoCustomSheetView.h"
#import "TIoTCoreXP2PBridge.h"
#import "NSString+Extension.h"
#import "TIoTCoreAppEnvironment.h"
#import "TIoTDemoDeviceStatusModel.h"
#import "TIoTCoreUtil+TIoTDemoDeviceStatus.h"
#import "TIoTXp2pInfoModel.h"
#import <AVFoundation/AVFoundation.h>
#import "ReachabilityManager.h"
#import "TIoTSessionManager.h"
#import "TIoTPCMXEchoRecord.h"
#import "TIoTAACEncoder.h"
#import "TIoTH264Encoder.h"

static CGFloat const kPadding = 16;
static NSString *const kPreviewDeviceCellID = @"kPreviewDeviceCellID";
static CGFloat const kScreenScale = 0.5625; //9/16 高宽比
static NSInteger const kLimit = 999;

static NSString *const action_left = @"action=user_define&cmd=ptz_left";
static NSString *const action_right = @"action=user_define&cmd=ptz_right";
static NSString *const action_up = @"action=user_define&cmd=ptz_up";
static NSString *const action_Down = @"action=user_define&cmd=ptz_down";
static NSString *const quality_standard = @"ipc.flv?action=live&quality=standard";
static NSString *const quality_high = @"ipc.flv?action=live&quality=high";
static NSString *const quality_super = @"ipc.flv?action=live&quality=super";
static NSString *const action_live = @"live";
static NSString *const action_voice = @"voice";

typedef NS_ENUM(NSInteger, TIotDemoDeviceDirection) {
    TIotDemoDeviceDirectionLeft,
    TIotDemoDeviceDirectionRight,
    TIotDemoDeviceDirectionUp,
    TIotDemoDeviceDirectionDown,
};


@interface TIoTDemoVideoPushVC ()<H264EncoderDelegate,TIoTAACEncoderDelegate, TIoTCoreXP2PBridgeDelegate>
@property (nonatomic, assign) CGRect screenRect;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *remoteVideoView; //录像中提示view

@property (nonatomic, strong) UIButton *definitionBtn; //竖屏-切换清晰度按钮


@property (nonatomic, strong) NSString *qualityString; //保存选择video清晰度

@property (nonatomic, strong) NSString *saveFilePath; //视频保存路径
@property (nonatomic, strong) NSString *deviceName; //设备名称 NVR 和 IPC model有区别

@property (nonatomic, assign) CFTimeInterval startPlayer;
@property (nonatomic, assign) CFTimeInterval endPlayer;
@property (nonatomic, assign) CFTimeInterval startIpcP2P;
@property (nonatomic, assign) CFTimeInterval endIpcP2P;
@property (nonatomic, assign) BOOL is_ijkPlayer_stream; //通过播放器 还是 通过裸流拉取数据
@property (nonatomic, assign) BOOL is_reconnect_xp2p; //是否正在重连，指设备断网的重连，app重连不走这个
@property (nonatomic, assign) BOOL is_reconnect_break; //退出页面，停止重连

@property (nonatomic, strong) TIoTPCMXEchoRecord *pcmRecord;
@property (nonatomic, strong) TIoTAACEncoder *aacEncoder;
@end

@implementation TIoTDemoVideoPushVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.is_reconnect_xp2p = NO;
        self.endPlayer = 0;
        [self registerNetworkNotifications];
    }
    return self;
}

#pragma mark - TIoTCoreXP2PBridgeDelegate
- (NSString *)reviceDeviceMsgWithID:(NSString *)dev_name data:(NSData *)data {
    NSString *deviceMsg = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"接收到设备主动发的消息==%@", deviceMsg);

    return @"responseMES";
}

//下载完成事件
- (void)reviceEventMsgWithID:(NSString *)dev_name eventType:(XP2PType)eventType msg:(const char *)msg {
    if (eventType == XP2PTypeClose) {
        
        NSString *msgDetail = [NSString stringWithCString:msg encoding:[NSString defaultCStringEncoding]];
        if ([msgDetail containsString:@"2000"]) {
            [MBProgressHUD dismissInView:self.view];
            [MBProgressHUD showError:@"语音对讲服务关闭"];
        }
        NSLog(@"msgDDD=%@",msgDetail);
    }
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.is_reconnect_break = NO;
    
    _is_ijkPlayer_stream = YES;
    //关闭日志
    [TIoTCoreXP2PBridge sharedInstance].delegate = self;

    [TIoTCoreXP2PBridge sharedInstance].logEnable = YES;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    self.qualityString = quality_standard;
    self.screenRect = [UIApplication sharedApplication].delegate.window.frame;
    
    if (self.isNVR == NO) {
        self.deviceName = self.selectedModel.DeviceName?:@"";
        
    }else {
        self.deviceName = self.deviceNameNVR?:@"";
    }
    
    [self installMovieNotificationObservers];

    [self initializedVideo];
    [self initVideoParamView];
            
    [self requestXp2pInfo];
    
    if (NO) {
        //走外部的采集编码来发送的话，打开开关即可，最终通过  SendExternalAudioPacket 发送数据
        //打开之后需将下面代码 isExternal 参数也打开即可
        [self configAudioVideo];
    }
}

- (void)configAudioVideo {
    self.pcmRecord  = [[TIoTPCMXEchoRecord alloc] initWithChannel:1 isEcho:YES];
    [self.pcmRecord set_record_callback:record_callback user:(__bridge void * _Nonnull)(self)];
    //        [self.record start_record];
    
    AudioStreamBasicDescription inAudioStreamBasicDescription = self.pcmRecord.pcmStreamDescription;
    self.aacEncoder = [[TIoTAACEncoder alloc] initWithAudioDescription:inAudioStreamBasicDescription];
    self.aacEncoder.delegate = self;
    self.aacEncoder.audioType = TIoTAVCaptionFLVAudio_8;
}
static void record_callback(uint8_t *buffer, int size, void *u)
{
    TIoTDemoVideoPushVC *vc = (__bridge TIoTDemoVideoPushVC *)(u);
    printf("pcm_size_callback: %d\n", size);
    NSData *data = [NSData dataWithBytes:buffer length:size];
//    [_fileHandle writeData:data];
    [vc.aacEncoder encodePCMData:data];
}
#pragma mark - TIoTAACEncoderDelegate
- (void)getEncoderAACData:(NSData *)data {
//    [_fileHandle writeData:data];
    [[TIoTCoreXP2PBridge sharedInstance] SendExternalAudioPacket:data];
}

- (void)requestDiffDeviceDataWithXp2pInfo:(NSString *)xp2pInfo {
    
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
    self.startIpcP2P = CACurrentMediaTime();
}

- (void)requestXp2pInfo {
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"Version"] = @"2021-11-25";//@"2020-12-15";
    paramDic[@"DeviceName"] = self.deviceName?:@"";
    
    __weak typeof(self) weakSelf = self;
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeDeviceData vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTXp2pInfoModel *model = [TIoTXp2pInfoModel yy_modelWithJSON:responseObject];
        NSDictionary *p2pInfo = [NSString jsonToObject:model.Data?:@""];
        TIoTXp2pModel *infoModel = [TIoTXp2pModel yy_modelWithJSON:p2pInfo];
        NSString *xp2pInfoString = infoModel._sys_xp2p_info.Value?:@"";
        [weakSelf requestDiffDeviceDataWithXp2pInfo:xp2pInfoString];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        [weakSelf requestDiffDeviceDataWithXp2pInfo:@""];
        [MBProgressHUD showError:@"xp2pInfo api请求失败"];
    }];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [self.imageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = obj;
        [view removeFromSuperview];
    }];
    
    [self recoverNavigationBar];
        
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    [[TIoTCoreXP2PBridge sharedInstance] stopService:self.deviceName?:@""];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc{
    
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if (self.isNVR == NO) {
        [[TIoTCoreXP2PBridge sharedInstance] stopService:self.deviceName?:@""];
        
        [[TIoTSessionManager sharedInstance] resetToCachedAudioSession];
    }
    
    printf("debugdeinit---%s,%s,%d", __FILE__, __FUNCTION__, __LINE__);
}

///MARK: 获取ipc/nvr设备状态，是否可以推流（type 参数区分直播和对讲）
- (void)getDeviceStatusWithType:(NSString *)singleType qualityType:(NSString *)qualityType{
    
    NSString *actionString = @"";
    NSString *qualityTypeString = [qualityType componentsSeparatedByString:@"&"].lastObject;
    if (self.isNVR == YES) {
        actionString = [NSString stringWithFormat:@"action=inner_define&channel=%@&cmd=get_device_st&type=%@&%@",self.selectedModel.Channel,singleType?:@"",qualityTypeString?:@""];
    }else {
        actionString =[NSString stringWithFormat:@"action=inner_define&channel=0&cmd=get_device_st&type=%@&%@",singleType?:@"",qualityTypeString?:@""];
    }
    
    __weak typeof(self) weakSelf = self;
    [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:self.deviceName?:@"" cmd:actionString?:@"" timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
        NSArray *responseArray = [NSArray yy_modelArrayWithClass:[TIoTDemoDeviceStatusModel class] json:jsonList];
        TIoTDemoDeviceStatusModel *responseModel = responseArray.firstObject;
        if ([responseModel.status isEqualToString:@"0"]) {
            if ([singleType isEqualToString:action_live]) {
                //直播
            }else if ([singleType isEqualToString:action_voice]) {
                //对讲
                NSString *channel = @""; //channel 请求参数采用 key1=value&key2=value2
                if (weakSelf.isNVR == NO) {
                    channel = @"channel=0";
                }else {
                    NSString *channelNum = weakSelf.selectedModel.Channel?:@"0";
                    channel = [NSString stringWithFormat:@"channel=%d",channelNum.intValue];
                }
                
                [[TIoTSessionManager sharedInstance] resumeRTCAudioSession];
                
                static int tt_pitch = 0;
                TIoTCoreAudioConfig *audio_config = [TIoTCoreAudioConfig new];
                audio_config.refreshSession = YES;
                audio_config.sampleRate = TIoTAVCaptionFLVAudio_8;
                audio_config.channels = 1;
                audio_config.isEchoCancel = YES;
                audio_config.pitch =  tt_pitch; // -6声音会变粗一点;    6声音会变细一点
//                audio_config.isExternal = YES;
                
                TIoTCoreVideoConfig *video_config = [TIoTCoreVideoConfig new];
                video_config.localView = self.remoteVideoView;
                video_config.videoPosition = AVCaptureDevicePositionFront;
                video_config.bitRate = 250000;
//                video_config.isExternal = YES;

                [[TIoTCoreXP2PBridge sharedInstance] sendVoiceToServer:weakSelf.deviceName?:@"" channel:channel audioConfig:audio_config videoConfig:video_config];
                
                /*if(tt_pitch == 6){
                    tt_pitch = -6;
                }else {
                    tt_pitch = 6;
                }*/
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (video_config.isExternal) { //走外部就用外部的采集器发送aac
                        [self.pcmRecord start_record];
                    }else {
                        //否则走SDK本身的采样编码发送
                    }
                });
            }
            
        }else {
            //设备状态异常提示
            [TIoTCoreUtil showDeviceStatusError:responseModel commandInfo:[NSString stringWithFormat:@"发送信令: %@\n\n接收: %@",actionString,jsonList]];
        }
    }];
}

//带回调的状态检测
- (void)getDeviceStatusWithType:(NSString *)singleType qualityType:(NSString *)qualityType completion:(void (^ __nullable)(BOOL finished))completion {
    
    NSString *actionString = @"";
    NSString *qualityTypeString = [qualityType componentsSeparatedByString:@"&"].lastObject;
    if (self.isNVR == YES) {
        actionString = [NSString stringWithFormat:@"action=inner_define&channel=%@&cmd=get_device_st&type=%@&%@",self.selectedModel.Channel,singleType?:@"",qualityTypeString?:@""];
    }else {
        actionString =[NSString stringWithFormat:@"action=inner_define&channel=0&cmd=get_device_st&type=%@&%@",singleType?:@"",qualityTypeString?:@""];
    }
    
    __weak typeof(self) weakSelf = self;
    [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:self.deviceName?:@"" cmd:actionString?:@"" timeout:1.5*1000*1000 completion:^(NSString * _Nonnull jsonList) {
        NSArray *responseArray = [NSArray yy_modelArrayWithClass:[TIoTDemoDeviceStatusModel class] json:jsonList];
        TIoTDemoDeviceStatusModel *responseModel = responseArray.firstObject;
        if ([responseModel.status isEqualToString:@"0"]) {
            if ([singleType isEqualToString:action_live]) {
                //直播
                
            }else if ([singleType isEqualToString:action_voice]) {
                //对讲
            }
            completion(YES);
        }else {
            //设备状态异常提示
            completion(NO);
        }
    }];
}

- (void)initializedVideo {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.screenRect.size.width);
//        make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
        make.height.mas_equalTo(1);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view).offset(64);
        }
    }];
    
    self.imageView.userInteractionEnabled = YES;
}

- (void)initVideoParamView {
    
    //右上角录像提示view
    self.remoteVideoView = [[UIView alloc]init];
    self.remoteVideoView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.remoteVideoView];
    [self.remoteVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.screenRect.size.width);
        make.height.mas_equalTo(self.screenRect.size.height);
        make.left.equalTo(self.view);
        make.top.equalTo(self.imageView.mas_bottom).offset(16);
    }];
}

///MARK: 对讲
- (void)clickTalkback:(BOOL)istalk {
    if (istalk) {
        [self getDeviceStatusWithType:action_voice qualityType:self.qualityString];
    }else {
        [[TIoTCoreXP2PBridge sharedInstance] stopVoiceToServer];
        
        [[TIoTSessionManager sharedInstance] resetToCachedAudioSession];
    }
}


#pragma mark - dirention action
- (void)turnDirectionWithDirection:(TIotDemoDeviceDirection )directionType {
//        case TIotDemoDeviceDirectionLeft: {
    [self sendDeivecWithSignalling:action_left];
//    [self sendDeivecWithSignalling:action_right];
//    [self sendDeivecWithSignalling:action_up];
//    [self sendDeivecWithSignalling:action_Down];
}

///MARK:根据方向发送设备信令
- (void)sendDeivecWithSignalling:(NSString *)singleText {
    NSString *singleString  = @"";
    if (self.isNVR == YES) {
        singleString = [NSString stringWithFormat:@"%@&channel=%@",singleText,self.selectedModel.Channel];
    }else {
        singleString = [NSString stringWithFormat:@"%@&channel=0",singleText];
    }
    
    [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:self.deviceName?:@"" cmd:singleText?:@"" timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
        if (![NSString isNullOrNilWithObject:jsonList] || ![NSString isFullSpaceEmpty:jsonList]) {
            [MBProgressHUD showMessage:jsonList icon:@""];
        }
        
    }];
}

///MARK: 设置导航栏透明
- (void)setNavigationBarTransparency {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

///MARK: 恢复导航栏
- (void)recoverNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}


#pragma mark Install Movie Notifications
-(void)installMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refushVideo:)
                                                 name:TIoTCoreXP2PBridgeNotificationReady
                                               object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseP2PdisConnect:)
                                                 name:TIoTCoreXP2PBridgeNotificationDisconnect
                                               object:nil];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TIoTCoreXP2PBridgeNotificationReady object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TIoTCoreXP2PBridgeNotificationDisconnect object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refushVideo:(NSNotification *)notify {
    
    UIViewController *view = [self getCurrentViewController];
    if ([view isMemberOfClass:[TIoTDemoVideoPushVC class]]) {
        NSString *DeviceName = [notify.userInfo objectForKey:@"id"];
        NSString *selectedName = self.deviceName?:@"";
        
        if (![DeviceName isEqualToString:selectedName]) {
            return;
        }
        
        [MBProgressHUD show:[NSString stringWithFormat:@"%@ 本地服务已ready，可发起拉流或推流",selectedName] icon:@"" view:self.view];
        
        //计算IPC打洞时间
        self.endIpcP2P = CACurrentMediaTime();
        
        //开始推流
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clickTalkback:YES];
        });
    }
}

- (void)responseP2PdisConnect:(NSNotification *)notify {
    NSString *DeviceName = [notify.userInfo objectForKey:@"id"];
    NSString *selectedName = self.deviceName?:@"";
    
    if (![DeviceName isEqualToString:selectedName]) {
        return;
    }
    
    NSLog(@"通道断开，正在重连");
    [MBProgressHUD showError:@"通道断开，正在重连"];
    [self clickTalkback:NO];
    
    if (!self.is_reconnect_xp2p) {
        self.is_reconnect_xp2p = YES;
        [self resconnectXp2pRequestInfo:DeviceName];
    }
}

- (void)resconnectXp2pRequestInfo:(NSString *)DeviceName {
    if (self.is_reconnect_break) {
        //退出页面，停止重连
        return;
    }
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"Version"] = @"2021-11-25";//@"2020-12-15";
    paramDic[@"DeviceName"] = self.deviceName?:@"";
    
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeDeviceData vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTXp2pInfoModel *model = [TIoTXp2pInfoModel yy_modelWithJSON:responseObject];
        NSDictionary *p2pInfo = [NSString jsonToObject:model.Data?:@""];
        TIoTXp2pModel *infoModel = [TIoTXp2pModel yy_modelWithJSON:p2pInfo];
        NSString *xp2pInfoString = infoModel._sys_xp2p_info.Value?:@"";
        
        [self resconnectXp2pWithDevicename:DeviceName?:@"" xp2pInfo:xp2pInfoString?:@""];
//        [MBProgressHUD showError:@"p2p重连 xp2pInfo api请求成功"];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        [self resconnectXp2pWithDevicename:DeviceName?:@"" xp2pInfo:@""];
//        [MBProgressHUD showError:@"p2p重连 xp2pInfo api请求失败"];
    }];
}

- (void)resconnectXp2pWithDevicename:(NSString *)deviceName xp2pInfo:(NSString *)xp2pInfo {
    TIoTCoreAppEnvironment *env = [TIoTCoreAppEnvironment shareEnvironment];
    [[TIoTCoreXP2PBridge sharedInstance] setXp2pInfo:deviceName?:@"" sec_id:env.cloudSecretId sec_key:env.cloudSecretKey xp2pinfo:xp2pInfo?:@""];
    
    [self getDeviceStatusWithType:action_live qualityType:self.qualityString completion:^(BOOL finished) {
        if (finished) {
            self.is_reconnect_xp2p = NO; //连通成功后，复位标记
        }else {
            [self resconnectXp2pRequestInfo:deviceName];
        }
        
    }];
}


- (void)nav_customBack {
    self.is_reconnect_break = YES;
    [self removeMovieNotificationObservers];
    [self.navigationController popViewControllerAnimated:YES];
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

//需注意此方法全局覆盖，别的地方就收不到断网通知了
- (void)registerNetworkNotifications {
    __weak typeof(self)WeakSelf = self;
    [[NetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(NetworkReachabilityStatus status) {
        switch (status) {
            case NetworkReachabilityStatusUnknown:
                DDLogVerbose(@"状态不知道");
                break;
            case NetworkReachabilityStatusNotReachable:
                [MBProgressHUD showError:@"无网络"];
                [WeakSelf appNetWorkBreak];
                break;
            case NetworkReachabilityStatusReachableViaWiFi:
                [MBProgressHUD showError:@"WIFI"];
                [WeakSelf appNetWorkResume];
                break;
            case NetworkReachabilityStatusReachableViaWWAN:
                [MBProgressHUD showError:@"移动网络"];
                [WeakSelf appNetWorkResume];
                break;
            default:
                break;
        }
    }];
    
    [[NetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)appNetWorkBreak {
    if (self.endPlayer == 0) { //正在直播中，断开才响应
        return;
    }
    [[TIoTCoreXP2PBridge sharedInstance] stopService:self.deviceName?:@""];
}

- (void)appNetWorkResume {
    if (self.endPlayer == 0) { //正在直播中，断开才响应
        return;
    }
    //重连使用
    [[TIoTCoreXP2PBridge sharedInstance] stopService:self.deviceName?:@""];
    TIoTCoreAppEnvironment *env = [TIoTCoreAppEnvironment shareEnvironment];
    [[TIoTCoreXP2PBridge sharedInstance] startAppWith:env.cloudSecretId sec_key:env.cloudSecretKey pro_id:env.cloudProductId dev_name:self.deviceName?:@""];

}

@end
