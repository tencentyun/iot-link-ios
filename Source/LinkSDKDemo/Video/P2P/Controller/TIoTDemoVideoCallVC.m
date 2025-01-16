//
//  TIoTDemoVideoCallVC.m
//  LinkSDKDemo
//
//

#import "TIoTDemoVideoCallVC.h"
#import "TIoTDemoCustomSheetView.h"
#import "TIoTCoreXP2PBridge.h"
#import "NSString+Extension.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "TIoTCoreAppEnvironment.h"
#import "TIoTDemoDeviceStatusModel.h"
#import "TIoTCoreUtil+TIoTDemoDeviceStatus.h"
#import "TIoTXp2pInfoModel.h"
#import <AVFoundation/AVFoundation.h>
#import "ReachabilityManager.h"
#import "TIoTSessionManager.h"

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

@interface TIoTDemoVideoCallVC ()
@property (nonatomic, assign) CGRect screenRect;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *remoteVideoView; //录像中提示view

@property (nonatomic, strong) UIButton *definitionBtn; //竖屏-切换清晰度按钮


@property(atomic, retain) IJKFFMoviePlayerController *player;
@property (nonatomic, strong) NSString *videoUrl;

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
@end

@implementation TIoTDemoVideoCallVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.is_reconnect_xp2p = NO;
        self.endPlayer = 0;
        [self registerNetworkNotifications];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.is_reconnect_break = NO;
    
    _is_ijkPlayer_stream = YES;
    //关闭日志
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
            
    [self requestXp2pInfo];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"播放调试面板" style:UIBarButtonItemStylePlain target:self action:@selector(showHudView)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)requestDiffDeviceDataWithXp2pInfo:(NSString *)xp2pInfo {
    
    TIoTCoreAppEnvironment *env = [TIoTCoreAppEnvironment shareEnvironment];
    
    TIoTP2PAPPConfig *config = [TIoTP2PAPPConfig new];
    config.appkey = env.appKey;         //为explorer平台注册的应用信息(https://console.cloud.tencent.com/iotexplorer/v2/instance/app/detai) explorer控制台- 应用开发 - 选对应的应用下的 appkey/appsecret
    config.appsecret = env.appSecret;   //为explorer平台注册的应用信息(https://console.cloud.tencent.com/iotexplorer/v2/instance/app/detai) explorer控制台- 应用开发 - 选对应的应用下的 appkey/appsecret
    config.userid = [[TIoTCoreXP2PBridge sharedInstance] getAppUUID];
    
    config.autoConfigFromDevice = NO;
    config.type = XP2P_PROTOCOL_AUTO;
    config.crossStunTurn = NO;
    
    int errorcode = [[TIoTCoreXP2PBridge sharedInstance] startAppWith:env.cloudProductId dev_name:self.deviceName?:@"" appconfig:config];
    [[TIoTCoreXP2PBridge sharedInstance] setXp2pInfo:self.deviceName?:@"" xp2pinfo:xp2pInfo?:@""];
    
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

- (void)showHudView {
    self.player.shouldShowHudView = !self.player.shouldShowHudView;
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
    
    [self stopPlayMovie];
    [self recoverNavigationBar];
        
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc{
    
    [self stopPlayMovie];
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
                [weakSelf setVieoPlayerStartPlayWith:qualityType];
            }else if ([singleType isEqualToString:action_voice]) {
                //对讲
                NSString *channel = @"";
                if (weakSelf.isNVR == NO) {
                    channel = @"channel=0";
                }else {
                    NSString *channelNum = weakSelf.selectedModel.Channel?:@"0";
                    channel = [NSString stringWithFormat:@"channel=%d",channelNum.intValue];
                }
                
                [[TIoTSessionManager sharedInstance] resumeRTCAudioSession];
                
                static int tt_pitch = 0;
                TIoTCoreAudioConfig *audio_config = [TIoTCoreAudioConfig new];
                audio_config.refreshSession = NO;
                audio_config.sampleRate = TIoTAVCaptionFLVAudio_8;
                audio_config.channels = 1;
                audio_config.isEchoCancel = YES;
                audio_config.pitch =  tt_pitch; // -6声音会变粗一点;    6声音会变细一点
                
                TIoTCoreVideoConfig *video_config = [TIoTCoreVideoConfig new];
                video_config.localView = self.remoteVideoView;
                video_config.videoPosition = AVCaptureDevicePositionFront;
                video_config.bitRate = 250000;
                
                [[TIoTCoreXP2PBridge sharedInstance] sendVoiceToServer:weakSelf.deviceName?:@"" channel:channel audioConfig:audio_config videoConfig:video_config];
                
                /*if(tt_pitch == 6){
                    tt_pitch = -6;
                }else {
                    tt_pitch = 6;
                }*/
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
                [weakSelf setVieoPlayerStartPlayWith:qualityType];
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
        make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
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
        make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
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

#pragma mark - request network



#pragma mark -IJKPlayer
- (void)loadStateDidChange:(NSNotification*)notification {
    IJKMPMovieLoadState loadState = _player.loadState;

    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        DDLogInfo(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d", (int)loadState);
        [self initVideoParamView];
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        DDLogInfo(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d", (int)loadState);
    } else {
        DDLogInfo(@"loadStateDidChange: ???: %d", (int)loadState);
    }
}


- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    NSString *seicontent = [notification.userInfo objectForKey:@"FFP_MSG_VIDEO_SEI_CONTENT"];
    if (seicontent) {
        return;
    }
    
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            DDLogInfo(@"IJKMPMoviePlayBackStateDidChange %d: stoped %p", (int)_player.playbackState,_player);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            DDLogInfo(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            
            // 播放器加载完出图时间
            self.endPlayer = CACurrentMediaTime();
            //p2p 连接时间
            NSInteger p2pConnectTime = 0;
            if (self.isNVR == NO) {
                p2pConnectTime = (NSInteger)((self.endIpcP2P - self.startIpcP2P)*1000);
            }else {
                if (![NSString isNullOrNilWithObject:self.deviceName]) {
                    NSDictionary *p2pTimeDic = [[NSUserDefaults standardUserDefaults] objectForKey:self.deviceName?:@""];
                    NSNumber *p2pTime = p2pTimeDic[@"p2pConnectTime"];
                    p2pConnectTime = p2pTime.integerValue;
                }
            }
            
            //弹框
            NSString *messageString = [NSString stringWithFormat: @"P2P连接时间:  %ld(ms)\n画面显示时间: %ld(ms)",(long)p2pConnectTime,(NSInteger)((self.endPlayer - self.startPlayer)*1000)];
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"设备名:%@",self.deviceName?:@""] message:messageString preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
            
            //获取当前发送链路的连接模式：0 无效；62 直连；63 转发
            int netmode = [TIoTCoreXP2PBridge getStreamLinkMode:self.deviceName];
            NSLog(@"nnnnnn---netmode==%d",netmode);
            
            //开始推流
            dispatch_async(dispatch_get_main_queue(), ^{
                [self clickTalkback:YES];
            });
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            DDLogInfo(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            DDLogInfo(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            DDLogInfo(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            DDLogWarn(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}
#pragma mark Install Movie Notifications
-(void)installMovieNotificationObservers
{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    if (self.isNVR == NO) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refushVideo:)
                                                     name:TIoTCoreXP2PBridgeNotificationReady
                                                   object:nil];
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseP2PdisConnect:)
                                                 name:TIoTCoreXP2PBridgeNotificationDisconnect
                                               object:nil];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TIoTCoreXP2PBridgeNotificationReady object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TIoTCoreXP2PBridgeNotificationDisconnect object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refushVideo:(NSNotification *)notify {
    
    UIViewController *view = [self getCurrentViewController];
    if ([view isMemberOfClass:[TIoTDemoVideoCallVC class]]) {
        NSString *DeviceName = [notify.userInfo objectForKey:@"id"];
        NSString *selectedName = self.deviceName?:@"";
        
        if (![DeviceName isEqualToString:selectedName]) {
            return;
        }
        
        [MBProgressHUD show:[NSString stringWithFormat:@"%@ 本地服务已ready，可发起拉流或推流",selectedName] icon:@"" view:self.view];
        
        //计算IPC打洞时间
        self.endIpcP2P = CACurrentMediaTime();
        //拉流
        [self setVieoPlayerStartPlayWith:self.qualityString];
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
    [[TIoTCoreXP2PBridge sharedInstance] setXp2pInfo:deviceName?:@"" xp2pinfo:xp2pInfo?:@""];
    
    [self getDeviceStatusWithType:action_live qualityType:self.qualityString completion:^(BOOL finished) {
        if (finished) {
            self.is_reconnect_xp2p = NO; //连通成功后，复位标记
        }else {
            [self resconnectXp2pRequestInfo:deviceName];
        }
        
    }];
}

/// MARK:新设备
- (void)setVieoPlayerStartPlayWith:(NSString *)qualityString {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString *qualityID = @"";
        if (self.isNVR == YES) {
            qualityID = [NSString stringWithFormat:@"%@&channel=%@",qualityString,self.selectedModel.Channel];
            
        }else {
            qualityID = [NSString stringWithFormat:@"%@&channel=0",qualityString];
        }
        
        NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:self.deviceName?:@""];
        
        self.videoUrl = [NSString stringWithFormat:@"%@%@",urlString,qualityID?:@""];
        
        [self configVideo];
        [self.player prepareToPlay];
        [self.player play];
        
        /// 播放器出图开始时间
        self.startPlayer = CACurrentMediaTime();
    });
}

- (void)nav_customBack {
    self.is_reconnect_break = YES;
    [self stopPlayMovie];
    [self removeMovieNotificationObservers];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)stopPlayMovie {
    if (self.player != nil) {
        [self.player stop];
        [self.player shutdown];
        [self.player.view removeFromSuperview];
        self.player = nil;
    }
}

- (void)configVideo {

    // 1.通过播放器发起的拉流
    if (_is_ijkPlayer_stream) {
        [TIoTCoreXP2PBridge sharedInstance].writeFile = YES;
        [TIoTCoreXP2PBridge recordstream:self.deviceName]; //保存到 document 目录 video.data 文件，需打开writeFile开关

        [self stopPlayMovie];
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:YES];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
        
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
        // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];
        
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        
        self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrl] withOptions:options];
        self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.player.view.frame = self.imageView.bounds;
        self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
        self.player.shouldAutoplay = YES;
        self.player.shouldShowHudView = YES;
        
        self.view.autoresizesSubviews = YES;

        [self.imageView addSubview:self.player.view];
        [self.player resetHubFrame:self.player.view.frame];
        
//        [self.player setOptionIntValue:5000 * 1000 forKey:@"analyzeduration" ofCategory:kIJKFFOptionCategoryFormat];
        [self.player setOptionIntValue:25 * 1024 forKey:@"probesize" ofCategory:kIJKFFOptionCategoryFormat];
        [self.player setOptionIntValue:0 forKey:@"packet-buffering" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:1 forKey:@"start-on-prepared" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:1 forKey:@"threads" ofCategory:kIJKFFOptionCategoryCodec];
        [self.player setOptionIntValue:0 forKey:@"sync-av-start" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:1 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];//iformat_name
//        [self.player setOptionValue:@"8000" forKey:@"ar" ofCategory:kIJKFFOptionCategoryCodec];
//        [self.player setOptionValue:@"1" forKey:@"ac" ofCategory:kIJKFFOptionCategoryCodec];
        
        [self.player setAudioSpeed:1.2f];
        [self.player setMaxPacketNum:3];
        
    }else {
        // 2.通过裸流服务拉流
        [TIoTCoreXP2PBridge sharedInstance].writeFile = YES; //是否保存到 document 目录 video.data 文件
        
        UILabel *fileTip = [[UILabel alloc] initWithFrame:self.imageView.bounds];
        fileTip.text = @"数据帧写文件中...";
        fileTip.textAlignment = NSTextAlignmentCenter;
        fileTip.textColor = [UIColor whiteColor];
        [self.imageView addSubview:fileTip];
        if (self.isNVR == NO) {
            [[TIoTCoreXP2PBridge sharedInstance] startAvRecvService:self.deviceName?:@"" cmd:@"action=live"];
        }
        
    }
}

///MARK: 切换live 清晰度
- (void)resetVideoPlayerWithQuality:(NSString *)qualityString {
    
    [self stopPlayMovie];
    
    if (self.isNVR == NO) {
        
        if ([TIoTCoreXP2PBridge sharedInstance].writeFile) {
            [[TIoTCoreXP2PBridge sharedInstance] stopAvRecvService:self.deviceName?:@""];
        }
    }
    
    NSString *qualityID = @"";
    
    if (self.isNVR == YES) {
        qualityID = [NSString stringWithFormat:@"%@&channel=%@",qualityString,self.selectedModel.Channel];
    }else {
        qualityID = [NSString stringWithFormat:@"%@&channel=0",qualityString];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:self.deviceName?:@""];
        self.videoUrl = [NSString stringWithFormat:@"%@%@",urlString,qualityID?:@""];
        [self configVideo];

        [self.player prepareToPlay];
        [self.player play];
        
        /// 播放器出图开始时间
        self.startPlayer = CACurrentMediaTime();
    });
    
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
    [self requestXp2pInfo];// 重新获取info，启动p2p
//    [[TIoTCoreXP2PBridge sharedInstance] startAppWith:env.cloudSecretId sec_key:env.cloudSecretKey pro_id:env.cloudProductId dev_name:self.deviceName?:@""];

}

@end
