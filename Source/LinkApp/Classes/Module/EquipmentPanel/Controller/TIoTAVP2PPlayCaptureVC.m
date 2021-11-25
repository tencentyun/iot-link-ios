//
//  TIoTAVP2PPlayCaptureVC.m
//  LinkApp
//

#import "TIoTAVP2PPlayCaptureVC.h"
#import "AppDelegate.h"
#import "TIoTCoreXP2PBridge.h"
#import "NSString+Extension.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import <YYModel.h>
#import "TIoTCoreUtil.h"
#import "NSObject+additions.h"
#import "AWAVCaptureManager.h"
#import "TIoTTRTCUIManage.h"
#import "UIDevice+Until.h"
#import "TIoTUIProxy.h"
#import "TIoTDemoDeviceStatusModel.h"
#import "TIoTCoreUtil+TIoTDemoDeviceStatus.h"

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

@implementation TIoTVideoDeviceCollectionView

@end

@interface TIoTAVP2PPlayCaptureVC ()

@property (nonatomic, strong) UIImageView *imageView;

@property(atomic, retain) IJKFFMoviePlayerController *player;
@property (nonatomic, strong) NSString *videoUrl;

@property (nonatomic, assign) CFTimeInterval startPlayer;
@property (nonatomic, assign) CFTimeInterval endPlayer;
@property (nonatomic, assign) CFTimeInterval startIpcP2P;
@property (nonatomic, assign) CFTimeInterval endIpcP2P;
@property (nonatomic, assign) BOOL is_init_alert;
@property (nonatomic, assign) BOOL is_ijkPlayer_stream; //通过播放器 还是 通过裸流拉取数据

//按钮
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *hungupBtn;
@property (nonatomic, strong) UIButton *switchCameras;
//预览
@property (nonatomic, strong) UIView *previewBottomView;
@property (nonatomic, strong) AWAVCaptureManager *avCaptureManager;

@property (nonatomic, assign) BOOL isStart;
@end

@implementation TIoTAVP2PPlayCaptureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [HXYNotice addP2PVideoReportDeviceLister:self reaction:@selector(deviceP2PVideoReport:)];
    [HXYNotice addP2PVideoExitLister:self reaction:@selector(deviceP2PVideoDeviceExit)];
    
    _is_init_alert = NO;
    _is_ijkPlayer_stream = YES;
    
    [self installMovieNotificationObservers];
    
    [self initializedVideo];
    
    [self setupUI];
    
    NSDictionary *xp2pDic = [NSDictionary new];
    NSString *xp2pValue = @"";
    if (self.objectModelDic != nil) {
        if ([self.objectModelDic.allKeys containsObject:@"_sys_xp2p_info"]) {
            xp2pDic = self.objectModelDic[@"_sys_xp2p_info"]?:@{};
        }
        if ([xp2pDic.allKeys containsObject:@"Value"]) {
            xp2pValue = xp2pDic[@"Value"]?:@"";
        }
    }
    int errorcode = [[TIoTCoreXP2PBridge sharedInstance] startAppWith:@"" sec_key:@"" pro_id:self.productID?:@"" dev_name:self.deviceName?:@"" xp2pinfo:xp2pValue];

    if (errorcode == XP2P_ERR_VERSION) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"APP SDK 版本与设备端 SDK 版本号不匹配，版本号需前两位保持一致" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    }
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"播放调试面板" style:UIBarButtonItemStylePlain target:self action:@selector(showHudView)];
    self.navigationItem.rightBarButtonItem = right;
    
    if (self.isCallIng == YES) {
        [self requestDeviceCommunicate];
    }
}

- (void)dealloc {
    [self close];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.imageView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = obj;
        [view removeFromSuperview];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isCallIng == YES) {
        //APP主叫
        [[TIoTTRTCUIManage sharedManager] callDeviceFromPanel:self.callType withDevideId:[NSString stringWithFormat:@"%@/%@",self.productID?:@"",self.deviceName?:@""]];
    }else {
        //设备呼叫APP  被叫
        [[TIoTTRTCUIManage sharedManager] showAppCalledVideoVC];
    }
    
}

- (void)showHudView {
    self.player.shouldShowHudView = !self.player.shouldShowHudView;
}

//请求设备通话
- (void)requestDeviceCommunicate {
    
    //APP主动呼叫时候
    
    //组装_sys_user_agent Data
    NSMutableDictionary *dataDic = [NSMutableDictionary new];
    if (self.reportDataDic != nil) {
        dataDic = [NSMutableDictionary dictionaryWithDictionary:self.reportDataDic];
    }
    
    //获取sysUserAgent
    NSString *agentString = [TIoTCoreUtil getSysUserAgent];
    
    //拼接_sys_user_agent
    [dataDic setValue:agentString forKey:@"_sys_user_agent"];
    
    if (self.isCallIng == YES) {
        //拼接主呼叫方id_sys_caller_id
        [dataDic setValue:[TIoTCoreUserManage shared].userId?:@"" forKey:@"id_sys_caller_id"];

        //拼接被呼叫方id_sys_called_id
        NSString *deviceID = [NSString stringWithFormat:@"%@/%@",self.productID?:@"",self.deviceName?:@""];
        [dataDic setValue:deviceID forKey:@"id_sys_called_id"];
    }else {
        //被叫
        //拼接主呼叫方id_sys_caller_id
        [dataDic setValue:self.payloadParamModel._sys_caller_id?:@"" forKey:@"id_sys_caller_id"];

        //拼接被呼叫方id_sys_called_id
        [dataDic setValue:self.payloadParamModel._sys_called_id?:@"" forKey:@"id_sys_called_id"];
    }
    
    //Data json
    NSString *dataDicJson = [NSString objectToJson:dataDic];
    [self.reportDataDic setValue:dataDicJson forKey:@"Data"];

    [self.reportDataDic setValue:self.productID?:@"" forKey:@"ProductId"];
    [self.reportDataDic setValue:self.deviceName?:@"" forKey:@"DeviceName"];
    [[TIoTRequestObject shared] post:AppControlDeviceData Param:self.reportDataDic success:^(id responseObject) {
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

-(void) setupUI{
    
    self.title = self.deviceName?:@"";
    
    [self.previewBottomView addSubview: self.avCapture.preview];
    
    self.avCapture.preview.center = self.previewBottomView.center;
    
    self.captureButton = [[UIButton alloc] init];
//    [self.captureButton setTitle:@"开始" forState:UIControlStateNormal];
    [self.captureButton setImage:[UIImage imageNamed:@"icon_hangup"] forState:UIControlStateNormal];
    [self.captureButton addTarget:self action:@selector(onStartClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.captureButton];
    [self.captureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.height.mas_equalTo(60);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-60);
        }else {
            make.bottom.equalTo(self.view.mas_bottom).offset(-60);
        }
    }];
    
    self.switchCameras = [[UIButton alloc] init];
    UIImage *switchImage = [self imageWithPath:@"" scale:2];
    switchImage = [switchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.switchCameras setImage:switchImage forState:UIControlStateNormal];
    [self.switchCameras setTintColor:[UIColor whiteColor]];
    [self.switchCameras addTarget:self action:@selector(onSwitchClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.switchBtn];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    self.switchCameras.frame = CGRectMake(screenSize.width - 30 - self.switchCameras.currentImage.size.width, 130, self.switchCameras.currentImage.size.width, self.switchCameras.currentImage.size.height);
    
    [self.view insertSubview:self.previewBottomView belowSubview:self.captureButton];
    
    self.previewBottomView.frame = self.view.bounds;
    self.avCapture.preview.frame = self.previewBottomView.bounds;
}

-(UIImage *)imageWithPath:(NSString *)path scale:(CGFloat)scale{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:path ofType:nil];
    if (imagePath) {
        NSData *imgData = [NSData dataWithContentsOfFile:imagePath];
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData scale:scale];
            return image;
        }
    }
    
    return nil;
}

- (void)initializedVideo {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view).offset(64);
        }
    }];
    
    self.imageView.userInteractionEnabled = YES;
}

#pragma mark - 通知
- (void)deviceP2PVideoReport:(NSNotification *)reportInfo {
    NSDictionary *payloadDic = reportInfo.userInfo;
    TIOTtrtcPayloadModel *reportModel = [TIOTtrtcPayloadModel yy_modelWithJSON:payloadDic];
    //1 设备愿意进行呼叫.  0 拒绝手机通话  2 设备和手机进入通话中
    if ([reportModel.params._sys_video_call_status isEqualToString:@"1"]) {
            //p2p请求设备状态  app 通过信令 get_device_state 请求设备p2p的
            NSString *actionString = @"action=inner_define&channel=0&cmd=get_device_st&type=live&quality=standard";
            [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:self.deviceName?:@"" cmd:actionString?:@"" timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
                NSArray *responseArray = [NSArray yy_modelArrayWithClass:[TIoTDemoDeviceStatusModel class] json:jsonList];
                TIoTDemoDeviceStatusModel *responseModel = responseArray.firstObject;
                if ([responseModel.status isEqualToString:@"0"]) {
                    //得到video audio 采样参数后 需要重新设置AWAudioConfig  AWVideoConfig 各项参数
                    
                }else {
                    //设备状态异常提示
                    [TIoTCoreUtil showDeviceStatusError:responseModel commandInfo:[NSString stringWithFormat:@"发送信令: %@\n\n接收: %@",actionString,jsonList]];
                }
            }];
    }else if ([reportModel.params._sys_video_call_status isEqualToString:@"0"]) {
        [self close];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }else if ([reportModel.params._sys_video_call_status isEqualToString:@"2"]) {
        //开启startservier
        if (self.isStart == NO) {
            [[TIoTTRTCUIManage sharedManager] acceptAppCallingOrCalledEnterRoom];
            [self startAVCapture];
        }
    }
}

- (void)deviceP2PVideoDeviceExit {
    [self close];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark -IJKPlayer
- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started

    IJKMPMovieLoadState loadState = _player.loadState;

    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        DDLogInfo(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d", (int)loadState);
//        [self initVideoParamView];
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        DDLogInfo(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d", (int)loadState);
    } else {
        DDLogInfo(@"loadStateDidChange: ???: %d", (int)loadState);
    }
}


- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward

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
            NSInteger p2pConnectTime = (NSInteger)((self.endIpcP2P - self.startIpcP2P)*1000);
            
            //弹框
            if (!_is_init_alert) {
                NSString *messageString = [NSString stringWithFormat: @"P2P连接时间:  %ld(ms)\n画面显示时间: %ld(ms)",(long)p2pConnectTime,(NSInteger)((self.endPlayer - self.startPlayer)*1000)];
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"设备名:%@",self.deviceName?:@""] message:messageString preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alertC dismissViewControllerAnimated:YES completion:NULL];
                });
                
                _is_init_alert = YES;
            }
            
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refushVideo:)
                                                 name:@"xp2preconnect"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseP2PdisConnect:)
                                                 name:@"xp2disconnect"
                                               object:nil];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"xp2preconnect" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"xp2disconnect" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refushVideo:(NSNotification *)notify {
    NSString *DeviceName = [notify.userInfo objectForKey:@"id"];
    NSString *selectedName = self.deviceName?:@"";
    
    if (![DeviceName isEqualToString:selectedName]) {
        return;
    }
    
    [MBProgressHUD show:[NSString stringWithFormat:@"%@ 通道建立成功",selectedName] icon:@"" view:self.view];
    
    //计算IPC打洞时间
    self.endIpcP2P = CACurrentMediaTime();
    
    //NSString *appVersion = [TIoTCoreXP2PBridge getSDKVersion];
    // appVersion.floatValue < 2.1 旧设备直接播放，不用发送信令验证设备状态和添加参数
    
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:self.deviceName]?:@"";
         
         self.videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
         
         [self configVideo];
         [self.player prepareToPlay];
         [self.player play];
         
         self.startPlayer = CACurrentMediaTime();
     });
}

- (void)responseP2PdisConnect:(NSNotification *)notify {
    NSString *DeviceName = [notify.userInfo objectForKey:@"id"];
    NSString *selectedName = self.deviceName?:@"";
    
    if (![DeviceName isEqualToString:selectedName]) {
        return;
    }
    
    [MBProgressHUD showError:@"通道断开，正在重连"];
    
    [[TIoTCoreXP2PBridge sharedInstance] stopService: DeviceName];
    [[TIoTCoreXP2PBridge sharedInstance] startAppWith:@""
                                              sec_key:@""
                                               pro_id:self.productID?:@""
                                             dev_name:DeviceName?:@""];

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
//        self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
        self.player.shouldAutoplay = YES;
        self.player.shouldShowHudView = YES;
        
        self.view.autoresizesSubviews = YES;
        [self.imageView addSubview:self.player.view];
        
        CGRect hubFrame = self.player.view.frame;
        
        [self.player resetHubFrame:CGRectMake(hubFrame.origin.x, hubFrame.origin.y, hubFrame.size.width, hubFrame.size.height/2)];
        
        //        [self.player setOptionIntValue:10 * 1000 forKey:@"analyzeduration" ofCategory:kIJKFFOptionCategoryFormat];
        [self.player setOptionIntValue:25 * 1024 forKey:@"probesize" ofCategory:kIJKFFOptionCategoryFormat];
        [self.player setOptionIntValue:0 forKey:@"packet-buffering" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:1 forKey:@"start-on-prepared" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:1 forKey:@"threads" ofCategory:kIJKFFOptionCategoryCodec];
        [self.player setOptionIntValue:0 forKey:@"sync-av-start" ofCategory:kIJKFFOptionCategoryPlayer];
        
    }else {
        // 2.通过裸流服务拉流
        [TIoTCoreXP2PBridge sharedInstance].writeFile = YES; //是否保存到 document 目录 video.data 文件
        
        UILabel *fileTip = [[UILabel alloc] initWithFrame:self.imageView.bounds];
        fileTip.text = @"数据帧写文件中...";
        fileTip.textAlignment = NSTextAlignmentCenter;
        fileTip.textColor = [UIColor whiteColor];
        [self.imageView addSubview:fileTip];
        [[TIoTCoreXP2PBridge sharedInstance] startAvRecvService:self.deviceName?:@"" cmd:@"action=live"];
        
    }
}

#pragma mark 事件
- (void)startAVCapture {
//    AWAudioConfig *config = [[AWAudioConfig alloc] init];
//    config.bitrate = 32000;
//    config.channelCount = 1;
//    config.sampleSize = 16;
//    config.sampleRate = 8000;
    
    self.isStart = YES;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryMultiRoute withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil ];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [[TIoTCoreXP2PBridge sharedInstance] sendVideoToServer:self.deviceName?:@"" channel:@"channel=0" avConfig:self.avCaptureManager];
    
    if ([self.avCapture startCapture]) {
//        [self.captureButton setTitle:@"停止" forState:UIControlStateNormal];
    }
}

-(void)onStartClick{
//    if (self.avCapture.isCapturing) {
//        [self.captureButton setTitle:@"开始" forState:UIControlStateNormal];
//        [self.avCapture stopCapture];
//        self.isStart = NO;
//    }else{
//        [self startAVCapture];
//    }
    
    [self close];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)open {
    [self startAVCapture];
}

- (void)close {
    if (self.avCapture.isCapturing) {
//        [self.captureButton setTitle:@"开始" forState:UIControlStateNormal];
        [self.avCapture stopCapture];
    }
//    [self.avCapture stopCapture];
    
    self.isStart = NO;
    
    [TIoTCoreUserManage shared].sys_call_status = @"-1";
    
    [HXYNotice removeListener:self];
    
    [self stopPlayMovie];
    [self removeMovieNotificationObservers];
    
    [[TIoTCoreXP2PBridge sharedInstance] stopService:self.deviceName?:@""];
    
    [self.previewBottomView removeFromSuperview];
}

-(void)onSwitchClick{
    [self.avCapture switchCamera];
}

#pragma mark 懒加载
-(AWAVCaptureManager *)avCaptureManager{
    if (!_avCaptureManager) {
        _avCaptureManager = [[AWAVCaptureManager alloc] init];
        //必须设置采样类型
        _avCaptureManager.captureType = AWAVCaptureTypeSystem;
        _avCaptureManager.audioEncoderType = AWAudioEncoderTypeHWAACLC;
        _avCaptureManager.videoEncoderType = AWVideoEncoderTypeHWH264;
        _avCaptureManager.audioConfig = [[AWAudioConfig alloc] init];
        _avCaptureManager.videoConfig = [[AWVideoConfig alloc] init];
        
        [_avCaptureManager setCaptureManagerPreviewFrame:CGRectMake(-30, 100, 350, 200)];
        
        //设置竖屏
        _avCaptureManager.videoConfig.orientation = UIInterfaceOrientationPortrait;
    }
    return _avCaptureManager;
}

-(AWAVCapture *)avCapture{
    AWAVCapture *capture = self.avCaptureManager.avCapture;
    return capture;
}

-(UIView *)previewBottomView{
    if (!_previewBottomView) {
        _previewBottomView = [[UIView alloc]initWithFrame:self.view.bounds];
        [self.view addSubview:_previewBottomView];
        [self.view sendSubviewToBack:_previewBottomView];
    }
    return _previewBottomView;
}
@end
