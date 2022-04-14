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
#import "TIoTTRTCUIManage.h"
#import "UIDevice+Until.h"
#import "TIoTUIProxy.h"
#import "TIoTDemoDeviceStatusModel.h"
#import "TIoTCoreUtil+TIoTDemoDeviceStatus.h"
#import <AVFoundation/AVFoundation.h>
#import "TIoTP2PCommunicateUIManage.h"
#import "UILabel+TIoTLableFormatter.h"
#import "ReachabilityManager.h"

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

@property (nonatomic, assign) CFTimeInterval startP2PStream; //检查通话时长

@property (nonatomic, assign) BOOL is_init_alert;
@property (nonatomic, assign) BOOL is_ijkPlayer_stream; //通过播放器 还是 通过裸流拉取数据

//按钮
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *hungupBtn;
@property (nonatomic, strong) UIButton *switchCameras;
//预览
@property (nonatomic, strong) UIView *previewBottomView;

@property (nonatomic, assign) BOOL isStart;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *refuseButton;
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) UILabel *tipLabel; //状态提示语
@end

@implementation TIoTAVP2PPlayCaptureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.fd_interactivePopDisabled = YES;
    
    
    [HXYNotice addP2PVideoReportDeviceLister:self reaction:@selector(deviceP2PVideoReport:)];
    [HXYNotice addP2PVideoExitLister:self reaction:@selector(deviceP2PVideoDeviceExit)];
    
    //断网通知处理
    [HXYNotice addCallingDisconnectNetLister:self reaction:@selector(noNetworkHungupAction)];
    
    [self decetNetworkStatus];
    
    _is_init_alert = NO;
    _is_ijkPlayer_stream = YES;
    
    [self installMovieNotificationObservers];
    
    [self initializedVideo];
    
    [self setupUI];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"播放调试面板" style:UIBarButtonItemStylePlain target:self action:@selector(showHudView)];
    self.navigationItem.rightBarButtonItem = right;
    
    if (self.isCallIng == YES) {
        [self requestDeviceCommunicate];
    }
    
    if (self.isCallIng == YES) {
        //APP主叫
//        [[TIoTTRTCUIManage sharedManager] callDeviceFromPanel:self.callType withDevideId:[NSString stringWithFormat:@"%@/%@",self.productID?:@"",self.deviceName?:@""]];
        
//        [[TIoTP2PCommunicateUIManage sharedManager] setStatusManager];
//        [[TIoTP2PCommunicateUIManage sharedManager] p2pCommunicateCallDeviceFromPanel:self.callType withDevideId:[NSString stringWithFormat:@"%@/%@",self.productID?:@"",self.deviceName?:@""]];
    }else {
        //设备呼叫APP  被叫
//        [[TIoTTRTCUIManage sharedManager] showAppCalledVideoVC];
        
//        [[TIoTP2PCommunicateUIManage sharedManager] setStatusManager];
//        [[TIoTP2PCommunicateUIManage sharedManager] p2pCommunicateShowAppCalledVideoVC];
    }
}

//- (void)nav_customBack {
//    [self close];
////    [self.navigationController popViewControllerAnimated:NO];
//
//    [self dismissViewControllerAnimated:NO completion:nil];
//}

- (void)dealloc {
    [self close];
}

- (void)decetNetworkStatus{

    [[NetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(NetworkReachabilityStatus status) {
        switch (status) {
            case NetworkReachabilityStatusUnknown:
                DDLogDebug(@"状态不知道");
                break;
            case NetworkReachabilityStatusNotReachable:
                DDLogWarn(@"没网络");
                // RTC App端和设备端通话中 断网监听
                [HXYNotice postCallingDisconnectNet];
                break;
            case NetworkReachabilityStatusReachableViaWiFi:
                DDLogDebug(@"WIFI");
                break;
            case NetworkReachabilityStatusReachableViaWWAN:
                DDLogDebug(@"移动网络");
                break;
            default:
                break;
        }
    }];
    
    [[NetworkReachabilityManager sharedManager] startMonitoring];
    
}

//没网络 退出通话页面
- (void)noNetworkHungupAction {
    [MBProgressHUD showError:NSLocalizedString(@"no_netwrok_check_status", @"暂时无网络，请检查网络状态")];
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
        //拼接主呼叫方_sys_caller_id
        [dataDic setValue:[TIoTCoreUserManage shared].userId?:@"" forKey:@"_sys_caller_id"];

        //拼接被呼叫方id_sys_called_id
        NSString *deviceID = [NSString stringWithFormat:@"%@/%@",self.productID?:@"",self.deviceName?:@""];
        [dataDic setValue:deviceID forKey:@"_sys_called_id"];
    }else {
        //被叫
//        //拼接主呼叫方id_sys_caller_id
//        [dataDic setValue:self.payloadParamModel._sys_caller_id?:@"" forKey:@"_sys_caller_id"];
//
//        //拼接被呼叫方id_sys_called_id
//        [dataDic setValue:self.payloadParamModel._sys_called_id?:@"" forKey:@"_sys_called_id"];
        
        NSString *callerID = @"";
        NSString *calledID = @"";
        if ([NSString isNullOrNilWithObject:self.payloadParamModel._sys_caller_id]) {
            callerID = [NSString stringWithFormat:@"%@/%@",self.productID,self.deviceName];
        }else {
            callerID = self.payloadParamModel._sys_caller_id?:@"";
        }
        
        if ([NSString isNullOrNilWithObject:self.payloadParamModel._sys_called_id]) {
            calledID = [TIoTCoreUserManage shared].userId?:@"";
        }else {
            calledID = self.payloadParamModel._sys_called_id?:@"";
        }
        
        [dataDic setValue:callerID forKey:@"_sys_caller_id"];
        [dataDic setValue:calledID forKey:@"_sys_called_id"];
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
    
    self.captureButton = [[UIButton alloc] init];
    [self.captureButton setImage:[UIImage imageNamed:@"icon_hangup"] forState:UIControlStateNormal];
    [self.captureButton addTarget:self action:@selector(onHungupClick) forControlEvents:UIControlEventTouchUpInside];
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
    
    //顶层控制view，拒绝和接听按钮
    self.topView = [[UIView alloc]init];
    self.topView.frame = [UIApplication sharedApplication].delegate.window.frame;
    self.topView.backgroundColor = [UIColor colorWithHexString:@"#696969"];
    [self.view addSubview:self.topView];
    
    self.tipLabel = [[UILabel alloc]init];
    [self.tipLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
    [self.topView addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(70);
        }else {
            make.top.equalTo(self.view.mas_top).offset(70);
        }
        make.left.right.equalTo(self.view);
    }];
    
    self.refuseButton = [[UIButton alloc] init];
    [self.refuseButton setImage:[UIImage imageNamed:@"icon_hangup"] forState:UIControlStateNormal];
    [self.refuseButton addTarget:self action:@selector(onRefuseClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.refuseButton];
    
    self.acceptButton = [[UIButton alloc] init];
    [self.acceptButton setImage:[UIImage imageNamed:@"icon_accept"] forState:UIControlStateNormal];
    [self.acceptButton addTarget:self action:@selector(onAcceptClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.acceptButton];
    
    if (self.isCallIng == YES) { //主叫   只有拒绝一个按钮
        self.acceptButton.hidden = YES;
        
        [self.refuseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.width.height.mas_equalTo(60);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-60);
            }else {
                make.bottom.equalTo(self.view.mas_bottom).offset(-60);
            }
        }];
        
        if (self.callType == TIoTTRTCSessionCallType_audio) { //音频
            self.tipLabel.text = NSLocalizedString(@"voice_calling", @"语音呼叫中...");
        }else { // 视频
            self.tipLabel.text = NSLocalizedString(@"video_call", @"视频呼叫中...");
        }
    }else { //被叫   拒绝和接听两个按钮
        
        [self.refuseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(65);
            make.width.height.mas_equalTo(60);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-60);
            }else {
                make.bottom.equalTo(self.view.mas_bottom).offset(-60);
            }
        }];
        
        [self.acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view.mas_right).offset(-65);
            make.width.height.mas_equalTo(60);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-60);
            }else {
                make.bottom.equalTo(self.view.mas_bottom).offset(-60);
            }
        }];
        
        if (self.callType == TIoTTRTCSessionCallType_audio) { //音频
            self.tipLabel.text = NSLocalizedString(@"voice_call_invitation", @"语音通话邀请");
        }else { // 视频
            self.tipLabel.text = NSLocalizedString(@"video_call_invitation", @"视频通话邀请");
        }
    }
    
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
    if ([reportModel.params._sys_video_call_status isEqualToString:@"1"] || [reportModel.params._sys_audio_call_status isEqualToString:@"1"]) {
            //p2p请求设备状态  app 通过信令 get_device_state 请求设备p2p的
            NSString *actionString = @"action=inner_define&channel=0&cmd=get_device_st&type=live&quality=standard";
            [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:self.deviceName?:@"" cmd:actionString?:@"" timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
                NSArray *responseArray = [NSArray yy_modelArrayWithClass:[TIoTDemoDeviceStatusModel class] json:jsonList];
                TIoTDemoDeviceStatusModel *responseModel = responseArray.firstObject;
                if ([responseModel.status isEqualToString:@"0"]) {
                    //得到video audio 采样参数后 需要重新设置AWAudioConfig  AWVideoConfig 各项参数
                    
                }else {
                    //设备状态异常提示
                    if ([NetworkReachabilityManager sharedManager].networkReachabilityStatus == NetworkReachabilityStatusNotReachable) {
                        [MBProgressHUD showError:NSLocalizedString(@"no_netwrok_check_status", @"暂时无网络，请检查网络状态")];
                    }else {
                        [TIoTCoreUtil showDeviceStatusErrorWithTitle:NSLocalizedString(@"device_status_error", @"设备状态异常提示") contentText:NSLocalizedString(@"check_device_p2p_status", @"请检查设备网络和设备p2p状态是否正常")];
                    }
                }
            }];
        
        self.startP2PStream = CACurrentMediaTime();
    }else if ([reportModel.params._sys_video_call_status isEqualToString:@"0"]||[reportModel.params._sys_audio_call_status isEqualToString:@"0"]) {
        [self close];
//        [self.navigationController popViewControllerAnimated:NO];
        
        CFTimeInterval endP2PStream = CACurrentMediaTime();
//        endP2PStream - self.startP2PStream;
        NSInteger streamTime = ((endP2PStream - self.startP2PStream)*1000);
        if (streamTime < 5000) {
            [MBProgressHUD showError:@"通道建立失败，请重新拨打"];
        }else {
            [MBProgressHUD showError:NSLocalizedString(@"other_part_hangup", @"对方已挂断...")];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewController *topVC = [TIoTCoreUtil topViewController];
            NSString *selfClassName = NSStringFromClass(topVC.class);
            if ([selfClassName isEqualToString:@"TIoTAVP2PPlayCaptureVC"]) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        });
    }else if ([reportModel.params._sys_video_call_status isEqualToString:@"2"]|| [reportModel.params._sys_audio_call_status isEqualToString:@"2"]) {
        
        //开启startservier
        
        if (self.isStart == NO) {
            self.isStart = YES;

            self.topView.hidden = YES;
            //            if (self.isCallIng == NO) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:self.deviceName]?:@"";
                
                self.videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=live",urlString];
                
                [self configVideo];
                [self.player prepareToPlay];
                [self.player play];
                
                self.startPlayer = CACurrentMediaTime();
                //            }
                
                
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
                                
                [[TIoTP2PCommunicateUIManage sharedManager] setStatusManager];
                [[TIoTP2PCommunicateUIManage sharedManager] p2pCommunicateAcceptAppCallingOrCalledEnterRoom];
                
                [self startAVCapture];
                
//            });
        }
    }
}

- (void)deviceP2PVideoDeviceExit {
    [self close];
//    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -IJKPlayer
- (void)loadStateDidChange:(NSNotification*)notification
{
    IJKMPMovieLoadState loadState = _player.loadState;

    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        DDLogInfo(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        DDLogInfo(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d", (int)loadState);
    } else {
        DDLogInfo(@"loadStateDidChange: ???: %d", (int)loadState);
    }
}


- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
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
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [options setPlayerOptionIntValue:1 forKey:@"videotoolbox"];
    
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
        
//        [self.player setOptionIntValue:25 * 1024 forKey:@"probesize" ofCategory:kIJKFFOptionCategoryFormat];
        [self.player setOptionIntValue:100 * 1000 forKey:@"analyzeduration" ofCategory:kIJKFFOptionCategoryFormat];
        [self.player setOptionIntValue:1 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:0 forKey:@"packet-buffering" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:1 forKey:@"start-on-prepared" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:1 forKey:@"threads" ofCategory:kIJKFFOptionCategoryCodec];
        [self.player setOptionIntValue:0 forKey:@"sync-av-start" ofCategory:kIJKFFOptionCategoryPlayer];
}

#pragma mark 事件
- (void)startAVCapture {
    
    if (self.callType == TIoTTRTCSessionCallType_audio) {
        [[TIoTCoreXP2PBridge sharedInstance] sendVoiceToServer:self.deviceName?:@"" channel:@"channel=0" audioConfig:TIoTAVCaptionFLVAudio_8 withLocalPreviewView:nil];
    }else {
        [[TIoTCoreXP2PBridge sharedInstance] sendVoiceToServer:self.deviceName?:@"" channel:@"channel=0" audioConfig:TIoTAVCaptionFLVAudio_8 withLocalPreviewView:self.previewBottomView];
    }
}

- (void)changeCameraPositon {
    [[TIoTCoreXP2PBridge sharedInstance] changeCameraPositon];
}

-(void)onHungupClick{
    [HXYNotice postStatusManagerCommunicateType:0];
    
    [self close];
    
//    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)onRefuseClick {
    if ([self.delegate respondsToSelector:@selector(avP2PPlayRefuseOrHungupClick)]) {
        [self.delegate avP2PPlayRefuseOrHungupClick];
    }
}

- (void)onAcceptClick {
    self.topView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(avP2PPlayAcceptClick)]) {
        [self.delegate avP2PPlayAcceptClick];
    }
}

- (void)close {
    self.isStart = NO;
    
    [self stopPlayMovie];
    [self removeMovieNotificationObservers];
    
    [[TIoTCoreXP2PBridge sharedInstance] stopVoiceToServer];
    
    if (self.previewBottomView != nil) {
        [self.previewBottomView removeFromSuperview];
    }
    
//    if (self.isRefreshBlock) {
//        self.isRefreshBlock(YES);
//    }
    
//    [[TIoTTRTCUIManage sharedManager]refuseAppCallingOrCalledEnterRoom];
    
    [[TIoTP2PCommunicateUIManage sharedManager] setStatusManager];
    [[TIoTP2PCommunicateUIManage sharedManager] p2pCommunicateRefuseAppCallingOrCalledEnterRoom];
}

-(void)onSwitchClick{
//    [self.avCapture switchCamera];
}

- (void)hideTopView {
    self.topView.hidden = YES;
}
#pragma mark - 更新提示语
- (void)hungUp {
    self.tipLabel.text = NSLocalizedString(@"other_part_busy", @"对方正忙...");
}

- (void)beHungUp {
    self.tipLabel.text = NSLocalizedString(@"other_part_hangup", @"对方已挂断...");
}

- (void)noAnswered {
    self.tipLabel.text = NSLocalizedString(@"other_part_no_answer", @"对方无人接听...");
}

- (void)otherAnswered {
    self.tipLabel.text = NSLocalizedString(@"other_part_answered", @"其他用户已接听...");
}

- (void)hangupTapped {    //挂断
//    [self hungUp];
//    [self onRefuseClick];
}
#pragma mark - 懒加载
-(UIView *)previewBottomView{
    if (!_previewBottomView) {
        _previewBottomView = [[UIView alloc]initWithFrame:CGRectMake(40, 100, 150, 200)];
        [self.view addSubview:_previewBottomView];
        [self.view sendSubviewToBack:_previewBottomView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCameraPositon)];
        [_previewBottomView addGestureRecognizer:tap];
    }
    return _previewBottomView;
}
@end
