//
//  TIoTDemoPreviewDeviceVC.m
//  LinkSDKDemo
//
//

#import "TIoTDemoPreviewDeviceVC.h"
#import "TIoTDemoPlaybackCustomCell.h"
#import "TIoTDemoCustomSheetView.h"
#import "AppDelegate.h"
#import "UIDevice+TIoTDemoRotateScreen.h"
#import "NSDate+TIoTCustomCalendar.h"
#import "TIoTCoreXP2PBridge.h"
#import "NSString+Extension.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "TIoTCoreAppEnvironment.h"
#import <YYModel.h>
#import "TIoTDemoCloudEventListModel.h"
#import "TIoTCloudStorageVC.h"
#import "TIoTCoreUtil.h"
#import "NSObject+additions.h"
#import "TIoTDemoDeviceStatusModel.h"
#import "TIoTCoreUtil+TIoTDemoDeviceStatus.h"
#import "TIoTDemoPlaybackVC.h"

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

@interface TIoTDemoPreviewDeviceVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) CGRect screenRect;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *actionBottomView; //功能操作底层view
@property (nonatomic, strong) UITableView *tableView; //事件列表
@property (nonatomic, strong) NSMutableArray *dataArray; //事件列表
@property (nonatomic, strong) UIImageView *talkbackIcon;
@property (nonatomic, strong) UIImageView *videoIcon;
@property (nonatomic, strong) UIView *videoingView; //录像中提示view
@property (nonatomic, strong) UIView *landscapeChangeDefinition; //横屏时清晰度选择视图

@property (nonatomic, strong) UIButton *definitionBtn; //竖屏-切换清晰度按钮
@property (nonatomic, strong) UIButton *voiceBtn; //音量-是否静音
@property (nonatomic, strong) UIButton *rotateBtn;//转屏

@property (nonatomic, strong) UIButton *standardDef; //横屏-切换清晰度按钮
@property (nonatomic, strong) UIButton *highDef;
@property (nonatomic, strong) UIButton *supperDef;

@property(atomic, retain) IJKFFMoviePlayerController *player;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) TIoTDemoCloudEventListModel *listModel;

@property (nonatomic, strong) NSString *qualityString; //保存选择video清晰度

@property (nonatomic, strong) NSString *saveFilePath; //视频保存路径
@property (nonatomic, strong) NSString *deviceName; //设备名称 NVR 和 IPC model有区别

@property (nonatomic, assign) CFTimeInterval startPlayer;
@property (nonatomic, assign) CFTimeInterval endPlayer;
@property (nonatomic, assign) CFTimeInterval startIpcP2P;
@property (nonatomic, assign) CFTimeInterval endIpcP2P;

@property (nonatomic, assign) BOOL is_ijkPlayer_stream; //通过播放器 还是 通过裸流拉取数据
@end

@implementation TIoTDemoPreviewDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _is_ijkPlayer_stream = YES;
    //关闭日志
//    [TIoTCoreXP2PBridge sharedInstance].logEnable = NO;
    
    
    self.qualityString = quality_standard;
    self.screenRect = [UIApplication sharedApplication].delegate.window.frame;
    
    if (self.isNVR == NO) {
        self.deviceName = self.selectedModel.DeviceName?:@"";
        
    }else {
        self.deviceName = self.deviceNameNVR?:@"";
    }
    
    [self installMovieNotificationObservers];

    [self initializedVideo];
    
    [self addRotateNotification];
    
    [self setupPreViewViews];
    
    if (self.isNVR == NO) {
        //云存事件列表
        [self requestCloudStoreVideoList];
        
        int errorcode = [[TIoTCoreXP2PBridge sharedInstance] startAppWith:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretId
                                                  sec_key:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretKey
                                                   pro_id:[TIoTCoreAppEnvironment shareEnvironment].cloudProductId
                                                 dev_name:self.deviceName?:@""];
        if (errorcode == XP2P_ERR_VERSION) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"APP SDK 版本与设备端 SDK 版本号不匹配，版本号需前两位保持一致" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
        }
        
        //计算IPC打洞开始时间
        self.startIpcP2P = CACurrentMediaTime();
        
    }else {
        [self getDeviceStatusWithType:action_live qualityType:self.qualityString];
    }
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"播放调试面板" style:UIBarButtonItemStylePlain target:self action:@selector(showHudView)];
    self.navigationItem.rightBarButtonItem = right;
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
    
    [self ratetePortrait];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)dealloc{
    
    [self stopPlayMovie];
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    if (self.isNVR == NO) {
        [[TIoTCoreXP2PBridge sharedInstance] stopService:self.deviceName?:@""];
    }
    
    printf("debugdeinit---%s,%s,%d", __FILE__, __FUNCTION__, __LINE__);
}

- (void)addRotateNotification {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orientationChange:)
                                                name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
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
    
    [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:self.deviceName?:@"" cmd:actionString?:@"" timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
        NSArray *responseArray = [NSArray yy_modelArrayWithClass:[TIoTDemoDeviceStatusModel class] json:jsonList];
        TIoTDemoDeviceStatusModel *responseModel = responseArray.firstObject;
        if ([responseModel.status isEqualToString:@"0"]) {
            if ([singleType isEqualToString:action_live]) {
                //直播
                [self setVieoPlayerStartPlayWith:qualityType];
            }else if ([singleType isEqualToString:action_voice]) {
                //对讲
                NSString *channel = @"";
                if (self.isNVR == NO) {
                    channel = @"channel=0";
                }else {
                    NSString *channelNum = self.selectedModel.Channel?:@"0";
                    channel = [NSString stringWithFormat:@"channel=%d",channelNum.intValue];
                }
                [[TIoTCoreXP2PBridge sharedInstance] sendVoiceToServer:self.deviceName?:@"" channel:channel];
            }
            
        }else {
            //设备状态异常提示
            [TIoTCoreUtil showDeviceStatusError:responseModel commandInfo:[NSString stringWithFormat:@"发送信令: %@\n\n接收: %@",actionString,jsonList]];
        }
    }];
}

- (void)setupPreViewViews {
    
    self.view.backgroundColor = [UIColor colorWithHexString:kVideoDemoBackgoundColor];
    
    self.title = self.deviceName?:@"";
    
    CGFloat actionViewHeight = 160;
    
    //操作功能底层view
    self.actionBottomView = [[UIView alloc]init];
    self.actionBottomView.backgroundColor = [UIColor colorWithHexString:kVideoDemoBackgoundColor];
    [self.view addSubview:self.actionBottomView];
    [self.actionBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(kPadding);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(actionViewHeight);
    }];
    
    //对讲、录像、回放、拍照 方向
    //对讲功能
    CGFloat kActionViewHeight = (actionViewHeight-20)/2;
    CGFloat kActionViewWidth = (kScreenWidth-kPadding-100)/2;
    CGFloat kActionIconSize = 24;
    CGFloat kActionIconLeftPadding = 28;
    CGFloat kActionIconTopPadding = 4;
    
    UIImageView *talkbackImage = [[UIImageView alloc]init];
    talkbackImage.image = [UIImage imageNamed:@"talkback"];
    [self.actionBottomView addSubview:talkbackImage];
    [talkbackImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.actionBottomView.mas_top);
        make.left.equalTo(self.actionBottomView.mas_left).offset(kPadding);
        make.height.mas_equalTo(kActionViewHeight);
        make.width.mas_equalTo(kActionViewWidth);
    }];
    
    UIButton *talkbackBtn = [[UIButton alloc]init];
    [talkbackBtn addTarget:self action:@selector(clickTalkback:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionBottomView addSubview:talkbackBtn];
    [talkbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(talkbackImage);
    }];
    
    self.talkbackIcon = [[UIImageView alloc]init];
    self.talkbackIcon.image = [UIImage imageNamed:@"talkback_unselect"];
    [talkbackBtn addSubview:self.talkbackIcon];
    [self.talkbackIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kActionIconSize);
        make.bottom.equalTo(talkbackBtn.mas_centerY);
        make.left.equalTo(talkbackBtn.mas_left).offset(kActionIconLeftPadding);
    }];
    
    UILabel *talkbackLabel = [[UILabel alloc]init];
    [talkbackLabel setLabelFormateTitle:@"对讲" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:kVideoDemoDateTipTextColor textAlignment:NSTextAlignmentCenter];
    [talkbackBtn addSubview:talkbackLabel];
    [talkbackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.talkbackIcon);
        make.top.equalTo(self.talkbackIcon.mas_bottom).offset(kActionIconTopPadding);
    }];

    //回放功能
    UIImageView *playbackImage = [[UIImageView alloc]init];
    playbackImage.userInteractionEnabled = YES;
    playbackImage.image = [UIImage imageNamed:@"playback"];
    [self.actionBottomView addSubview:playbackImage];
    [playbackImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.actionBottomView);
        make.left.equalTo(talkbackBtn);
        make.height.width.equalTo(talkbackBtn);
    }];
    
    UIButton *playbackBtn = [[UIButton alloc]init];
    [playbackBtn setImage:[UIImage imageNamed:@"playback"] forState:UIControlStateNormal];
    [playbackBtn setImage:[UIImage imageNamed:@"playback"] forState:UIControlStateHighlighted];
    [playbackBtn addTarget:self action:@selector(clickPlayback:) forControlEvents:UIControlEventTouchUpInside];
    [playbackImage addSubview:playbackBtn];
    [playbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(playbackImage);
    }];
    
    UIImageView *playbackIcon = [[UIImageView alloc]init];
    playbackIcon.image = [UIImage imageNamed:@"playback_icon"];
    [playbackBtn addSubview:playbackIcon];
    [playbackIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kActionIconSize);
        make.bottom.equalTo(playbackBtn.mas_centerY);
        make.left.equalTo(playbackBtn.mas_left).offset(kActionIconLeftPadding);
    }];
    
    UILabel *playbackLabel = [[UILabel alloc]init];
    [playbackLabel setLabelFormateTitle:@"回看" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:kVideoDemoDateTipTextColor textAlignment:NSTextAlignmentCenter];
    [playbackBtn addSubview:playbackLabel];
    [playbackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(playbackIcon);
        make.top.equalTo(playbackIcon.mas_bottom).offset(kActionIconTopPadding);
    }];

    //录像
    UIImageView *videoImage = [[UIImageView alloc]init];
    videoImage.image = [UIImage imageNamed:@"video"];
    [self.actionBottomView addSubview:videoImage];
    [videoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.actionBottomView.mas_top);
        make.right.equalTo(self.actionBottomView.mas_right).offset(-kPadding);
        make.height.width.equalTo(talkbackBtn);
    }];
    
    UIButton *videoBtn = [[UIButton alloc]init];
    [videoBtn addTarget:self action:@selector(clickVideoBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionBottomView addSubview:videoBtn];
    [videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(videoImage);
    }];
    
    self.videoIcon = [[UIImageView alloc]init];
    self.videoIcon.image = [UIImage imageNamed:@"video_unselect"];
    [videoBtn addSubview:self.videoIcon];
    [self.videoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kActionIconSize);
        make.bottom.equalTo(videoBtn.mas_centerY);
        make.right.equalTo(videoBtn.mas_right).offset(-kActionIconLeftPadding);
    }];
    
    UILabel *videoLabel = [[UILabel alloc]init];
    [videoLabel setLabelFormateTitle:@"录像" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:kVideoDemoDateTipTextColor textAlignment:NSTextAlignmentCenter];
    [videoBtn addSubview:videoLabel];
    [videoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.videoIcon);
        make.top.equalTo(self.videoIcon.mas_bottom).offset(kActionIconTopPadding);
    }];

    //拍照
    UIImageView *photographImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"photograph"]];
    photographImageView.userInteractionEnabled = YES;
    [self.actionBottomView addSubview:photographImageView];
    [photographImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.actionBottomView.mas_bottom);
        make.right.equalTo(videoBtn.mas_right);
        make.height.width.equalTo(talkbackBtn);
    }];
    
    UIButton *photographBtn = [[UIButton alloc]init];
    [photographBtn setImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateNormal];
    [photographBtn setImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateHighlighted];
    [photographBtn addTarget:self action:@selector(clickPhotograph) forControlEvents:UIControlEventTouchUpInside];
    [photographImageView addSubview:photographBtn];
    [photographBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(photographImageView);
    }];
    
    UIImageView *photographIcon = [[UIImageView alloc]init];
    photographIcon.image = [UIImage imageNamed:@"picture_icon"];
    [photographBtn addSubview:photographIcon];
    [photographIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kActionIconSize);
        make.bottom.equalTo(photographBtn.mas_centerY);
        make.right.equalTo(videoBtn.mas_right).offset(-kActionIconLeftPadding);
    }];
    
    UILabel *photographLabel = [[UILabel alloc]init];
    [photographLabel setLabelFormateTitle:@"拍照" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:kVideoDemoDateTipTextColor textAlignment:NSTextAlignmentCenter];
    [photographBtn addSubview:photographLabel];
    [photographLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(photographIcon);
        make.top.equalTo(photographIcon.mas_bottom).offset(kActionIconTopPadding);
    }];
    
    //方向控制
    UIImageView *actionDirectionImage = [[UIImageView alloc]init];
    actionDirectionImage.userInteractionEnabled = YES;;
    actionDirectionImage.image = [UIImage imageNamed:@"action_direction"];
    [self.actionBottomView addSubview:actionDirectionImage];
    [actionDirectionImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.actionBottomView);
        make.width.height.mas_equalTo(150);
    }];
    
    //四个方向按钮
    CGFloat kBtnSize = 50;
    
    UIButton *upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [upBtn addTarget:self action:@selector(turnUpDirection) forControlEvents:UIControlEventTouchUpInside];
    [actionDirectionImage addSubview:upBtn];
    [upBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(actionDirectionImage);
        make.top.equalTo(actionDirectionImage);
        make.width.height.mas_equalTo(kBtnSize);
    }];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn addTarget:self action:@selector(turnLeftDirection) forControlEvents:UIControlEventTouchUpInside];
    [actionDirectionImage addSubview:leftBtn];
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(actionDirectionImage);
        make.width.height.mas_equalTo(kBtnSize);
        make.centerY.equalTo(actionDirectionImage);
    }];
    
    UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downBtn addTarget:self action:@selector(turnDownDirection) forControlEvents:UIControlEventTouchUpInside];
    [actionDirectionImage addSubview:downBtn];
    [downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(actionDirectionImage);
        make.centerX.equalTo(actionDirectionImage);
        make.width.height.mas_equalTo(kBtnSize);
    }];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn addTarget:self action:@selector(turnRightDirection) forControlEvents:UIControlEventTouchUpInside];
    [actionDirectionImage addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(actionDirectionImage);
        make.centerY.equalTo(actionDirectionImage);
        make.width.height.mas_equalTo(kBtnSize);
    }];
    
    NSString *weekValue = [[NSDate date] getWeekDayWithDate];
    UILabel *currentWeekTip = [[UILabel alloc]init];
    [currentWeekTip setLabelFormateTitle:[NSString stringWithFormat:@"今天 %@",weekValue] font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:kVideoDemoDateTipTextColor textAlignment:NSTextAlignmentLeft];
    [self.view addSubview:currentWeekTip];
    [currentWeekTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kPadding);
        make.top.equalTo(self.actionBottomView.mas_bottom).offset(20);
    }];
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.backgroundColor = [UIColor colorWithHexString:KActionSheetBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 84;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TIoTDemoPlaybackCustomCell class] forCellReuseIdentifier:kPreviewDeviceCellID];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(currentWeekTip.mas_bottom).offset(8);
        make.left.right.bottom.equalTo(self.view);
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
    self.videoingView = [[UIView alloc]init];
    self.videoingView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
    [self.imageView addSubview:self.videoingView];
    [self.videoingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.imageView);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(88);
    }];
    
    UIImageView *videoingIcon = [[UIImageView alloc]init];
    videoingIcon.image = [UIImage imageNamed:@"video_select"];
    [self.videoingView addSubview:videoingIcon];
    [videoingIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.centerY.equalTo(self.videoingView);
        make.left.equalTo(self.videoingView.mas_left).offset(12);
    }];
    
    UILabel *videoingLabel = [[UILabel alloc]init];
    [videoingLabel setLabelFormateTitle:@"录制中" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentLeft];
    [self.videoingView addSubview:videoingLabel];
    [videoingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(videoingIcon.mas_right).offset(8);
        make.centerY.equalTo(self.videoingView);
    }];
    
    self.videoingView.hidden = YES;
    
    CGFloat kBrnSize = 32;
    CGFloat kPadding = 16;
    CGFloat kInterval = 10;
    
    //调节video参数 按钮
    self.rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rotateBtn setImage:[UIImage imageNamed:@"rotate_icon"] forState:UIControlStateNormal];
    self.rotateBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.rotateBtn.layer.cornerRadius = kBrnSize/2;
    [self.rotateBtn addTarget:self action:@selector(rotateScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.rotateBtn];
    [self.rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kBrnSize);
        make.bottom.equalTo(self.imageView.mas_bottom).offset(-10);
        make.right.equalTo(self.imageView.mas_right).offset(-kPadding);
    }];
    
    
    self.voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voiceBtn setImage:[UIImage imageNamed:@"voice_open"] forState:UIControlStateNormal];
    self.voiceBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.voiceBtn.layer.cornerRadius = kBrnSize/2;
    [self.voiceBtn addTarget:self action:@selector(controlVoice:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.voiceBtn];
    [self.voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kBrnSize);
        make.bottom.equalTo(self.rotateBtn.mas_bottom);
        make.right.equalTo(self.rotateBtn.mas_left).offset(-kInterval);
    }];

    self.definitionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([self.qualityString isEqualToString:quality_standard]) {
        [self.definitionBtn setButtonFormateWithTitlt:@"标清" titleColorHexString:@"#ffffff" font:[UIFont wcPfRegularFontOfSize:12]];
    }else if ([self.qualityString isEqualToString:quality_high]) {
        [self.definitionBtn setButtonFormateWithTitlt:@"高清" titleColorHexString:@"#ffffff" font:[UIFont wcPfRegularFontOfSize:12]];
    }else if ([self.qualityString isEqualToString:quality_super]) {
        [self.definitionBtn setButtonFormateWithTitlt:@"超清" titleColorHexString:@"#ffffff" font:[UIFont wcPfRegularFontOfSize:12]];
    }
    self.definitionBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.definitionBtn.layer.cornerRadius = kBrnSize/2;
    [self.definitionBtn addTarget:self action:@selector(changeVideoDefinitaion) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.definitionBtn];
    [self.definitionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kBrnSize);
        make.bottom.equalTo(self.imageView.mas_bottom).offset(-10);
        make.right.equalTo(self.voiceBtn.mas_left).offset(-kInterval);
    }];
}

#pragma mark - action
///MARK: 对讲
- (void)clickTalkback:(UIButton *)button {
    if (!button.selected) {
        self.talkbackIcon.image = [UIImage imageNamed:@"talkback_select"];
        [self getDeviceStatusWithType:action_voice qualityType:self.qualityString];
    }else {
        self.talkbackIcon.image = [UIImage imageNamed:@"talkback_unselect"];
        [[TIoTCoreXP2PBridge sharedInstance] stopVoiceToServer];
    }
    
    button.selected = !button.selected;
}
///MARK: 回放
- (void)clickPlayback:(UIButton *)button {
    
    TIoTDemoPlaybackVC *playBackVC = [[TIoTDemoPlaybackVC alloc]init];
    playBackVC.deviceModel = self.selectedModel;
    playBackVC.isNVR = self.isNVR;
    playBackVC.deviceName = self.deviceName;
    playBackVC.playerReloadBlock = ^{
        [self addRotateNotification];
        [self getDeviceStatusWithType:action_live qualityType:self.qualityString];
    };
    [self.navigationController pushViewController:playBackVC animated:YES];
}
///MARK: 录像
- (void)clickVideoBtn:(UIButton *)button {
    if (!button.selected) {
        self.videoIcon.image = [UIImage imageNamed:@"video_select"];
        self.videoingView.hidden = NO;
        
        //开启录像
        NSString *fileName = @"TTVideo.mp4";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = paths.firstObject;
        self.saveFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:self.saveFilePath error:nil];
        
        [self.player startRecordWithFileName:self.saveFilePath];
        
    }else {
        self.videoIcon.image = [UIImage imageNamed:@"video_unselect"];
        self.videoingView.hidden = YES;
        
        //结束录像
        [self.player stopRecord];
        [TIoTCoreUtil saveVideoToPhotoAlbum:self.saveFilePath];
    }
    
    button.selected = !button.selected;
}
///MARK: 拍照
- (void)clickPhotograph {
    [TIoTCoreUtil screenshotWithView:self.player.view];
}

#pragma mark - 控制video 显示
- (void)rotateScreen {
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.isRotation == YES) {
        appDelegate.isRotation = NO;
        [self ratetePortrait];
    }else {
        appDelegate.isRotation = YES;
        [self rotateLandscapeRight];
    }
//    [self resetScreenSubviewsWithLandscape:appDelegate.isRotation];
}

- (void)controlVoice:(UIButton *)button {
    if (!button.selected) {
        [button setImage:[UIImage imageNamed:@"voice_close"] forState:UIControlStateNormal];
        self.player.playbackVolume = 0;
    }else {
        [button setImage:[UIImage imageNamed:@"voice_open"] forState:UIControlStateNormal];
        self.player.playbackVolume = 1;
    }
    button.selected = !button.selected;
}

- (void)changeVideoDefinitaion {
    
    if ([UIDevice judgeScreenOrientationPortrait]) {
        //竖屏
        __weak typeof(self) weakSelf = self;
        TIoTDemoCustomSheetView *definitaionSheet = [[TIoTDemoCustomSheetView alloc]init];
        NSArray *actionTitleArray = @[@"超清 1080P",@"高清 720P",@"标清 360P",@"取消"];
        ChooseFunctionBlock superDefinitaionBlock = ^(TIoTDemoCustomSheetView *view){
            self.qualityString = quality_super;
            [self resetVideoPlayerWithQuality:self.qualityString];
            [weakSelf.definitionBtn setTitle:@"超清" forState:UIControlStateNormal];
            [definitaionSheet removeFromSuperview];
        };
        
        ChooseFunctionBlock highDefinitionBlock = ^(TIoTDemoCustomSheetView *view){
            self.qualityString = quality_high;
            [self resetVideoPlayerWithQuality:self.qualityString];
            [weakSelf.definitionBtn setTitle:@"高清" forState:UIControlStateNormal];
            [definitaionSheet removeFromSuperview];
        };
        
        ChooseFunctionBlock standardDefinitionBlock = ^(TIoTDemoCustomSheetView *view){
            self.qualityString = quality_standard;
            [self resetVideoPlayerWithQuality:self.qualityString];
            [weakSelf.definitionBtn setTitle:@"标清" forState:UIControlStateNormal];
            [definitaionSheet removeFromSuperview];
        };
        
        ChooseFunctionBlock cancelBlock = ^(TIoTDemoCustomSheetView *view) {
            DDLogVerbose(@"取消");
            [view removeFromSuperview];
        };
        
        NSArray *actionBlockArray = @[superDefinitaionBlock,highDefinitionBlock,standardDefinitionBlock,cancelBlock];
        
        [definitaionSheet sheetViewTopTitleArray:actionTitleArray withMatchBlocks:actionBlockArray];
        [[UIApplication sharedApplication].delegate.window addSubview:definitaionSheet];
        [definitaionSheet mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
        }];
    }else {
        //横屏
        
        [self hideSettingVidoParamView];
        
        [self.view addSubview:self.landscapeChangeDefinition];
        [self.landscapeChangeDefinition mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(self.view);
        }];
    }
}

#pragma mark - dirention action
- (void)turnUpDirection {
    [self turnDirectionWithDirection:TIotDemoDeviceDirectionUp];
}

- (void)turnLeftDirection {
    [self turnDirectionWithDirection:TIotDemoDeviceDirectionLeft];
}

- (void)turnDownDirection {
    [self turnDirectionWithDirection:TIotDemoDeviceDirectionDown];
}

- (void)turnRightDirection {
    [self turnDirectionWithDirection:TIotDemoDeviceDirectionRight];
}

- (void)turnDirectionWithDirection:(TIotDemoDeviceDirection )directionType {
    switch (directionType) {
        case TIotDemoDeviceDirectionLeft: {
            [self sendDeivecWithSignalling:action_left];
            break;
        }
        case TIotDemoDeviceDirectionRight: {
            [self sendDeivecWithSignalling:action_right];
            break;
        }
        case TIotDemoDeviceDirectionUp: {
            [self sendDeivecWithSignalling:action_up];
            break;
        }
        case TIotDemoDeviceDirectionDown: {
            [self sendDeivecWithSignalling:action_Down];
            break;
        }
        default:
            break;
    }
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

#pragma mark - handler orientation event
- (void)orientationChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:{
            //屏幕向左横置
            appDelegate.isRotation = YES;
            [self setNavigationBarTransparency];
            [self resetScreenSubviewsWithLandscape:YES];
            break;
            }
        case UIDeviceOrientationLandscapeRight: {
            //屏幕向右橫置
            appDelegate.isRotation = YES;
            [self setNavigationBarTransparency];
            [self resetScreenSubviewsWithLandscape:YES ];
            break;
        }
        case UIDeviceOrientationPortrait: {
            //屏幕直立
            appDelegate.isRotation = NO;
            [self resetScreenSubviewsWithLandscape:NO];
            break;
        }
        default:
            //无法辨识
            break;
    }
}

///MARK: viewarray 约束更新适配屏幕
- (void)resetScreenSubviewsWithLandscape:(BOOL)rotation {
    if (rotation == YES) { //横屏
        self.actionBottomView.hidden = YES;
        self.tableView.hidden = YES;
        self.screenRect = [UIApplication sharedApplication].delegate.window.frame;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.screenRect.size.width);
            make.top.bottom.equalTo(self.view);
        }];
        [self controlLandScapeDefaultQuality];
    }else { //竖屏
        if (self.definitionBtn.hidden == YES) {
            [self hideDefinitionView];
        }
        self.actionBottomView.hidden = NO;
        self.tableView.hidden = NO;
        self.screenRect = [UIApplication sharedApplication].delegate.window.frame;
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.screenRect.size.width);
            make.height.mas_equalTo(self.screenRect.size.width*kScreenScale);
            make.centerX.equalTo(self.view);
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            }else {
                make.top.equalTo(self.view).offset(64);
            }
        }];
    }
}

///MARK:横屏
- (void)rotateLandscapeRight {
    
    //
    [self controlLandScapeDefaultQuality];
    
    [self setNavigationBarTransparency];
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isRotation = YES;
    [UIDevice changeOrientation:UIInterfaceOrientationLandscapeRight];
}

///MARK:竖屏
- (void)ratetePortrait {
    [self recoverNavigationBar];
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isRotation = NO;
    [UIDevice changeOrientation:UIInterfaceOrientationPortrait];
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
///MARK: 云存事件列表
- (void)requestCloudStoreVideoList {
    
    NSDate *date = [NSDate date];
    NSInteger year = [date dateYear];
    NSInteger month = [date dateMonth];
    NSInteger day = [date dateDay];
    NSString *currentDayTime = [NSString stringWithFormat:@"%02ld-%02ld-%02ld",(long)year,(long)month,(long)day];
    
    NSString *startString = [NSString stringWithFormat:@"%@ 00:00:00",currentDayTime?:@""];
    NSString *endString = [NSString stringWithFormat:@"%@ 23:59:59",currentDayTime?:@""];
    NSString *startTimestampString = [NSString getTimeStampWithString:startString withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
    NSString *endTimesstampString = [NSString getTimeStampWithString:endString withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"Version"] = @"2020-12-15";
    paramDic[@"Size"] = [NSNumber numberWithInteger:kLimit];
    paramDic[@"DeviceName"] = self.deviceName?:@"";
    paramDic[@"StartTime"] = [NSNumber numberWithInteger:startTimestampString.integerValue];
    paramDic[@"EndTime"] = [NSNumber numberWithInteger:endTimesstampString.integerValue];
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeCloudStorageEvents vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        
        self.listModel = [TIoTDemoCloudEventListModel yy_modelWithJSON:responseObject];
        
        if (self.listModel.Events.count != 0) {
            NSMutableArray *temp = (NSMutableArray *)[[self.listModel.Events?:@[] reverseObjectEnumerator] allObjects];
            self.dataArray = [NSMutableArray arrayWithArray:temp?:@[]];
            self.dataArray = (NSMutableArray *)[[self.dataArray reverseObjectEnumerator] allObjects];
            [self.tableView reloadData];
            
            [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    TIoTDemoCloudEventModel *model = obj;
                    [self requestCloudStoreUrlWithThumbnail:model index:idx];
                });
                
            }];
        }
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {

    }];
    
}

///MARK: 云存事件缩略图
- (void)requestCloudStoreUrlWithThumbnail:(TIoTDemoCloudEventModel *)eventModel index:(NSInteger)index {
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"Version"] = @"2020-12-15";
    paramDic[@"DeviceName"] = self.deviceName?:@"";
    paramDic[@"Thumbnail"] = eventModel.Thumbnail?:@"";
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeCloudStorageThumbnail vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTDemoCloudEventModel *tuumbnailModel = [TIoTDemoCloudEventModel yy_modelWithJSON:responseObject];
        eventModel.ThumbnailURL = tuumbnailModel.ThumbnailURL;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
    }];
    
}

#pragma mark - UITableViewdelegate and UITableViewDataSrouce
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTDemoPlaybackCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:kPreviewDeviceCellID forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //跳转回看页面，并播放当前选中事件视频，滚动条滑动相应位置
    TIoTDemoCloudEventModel *itemModel = self.dataArray[indexPath.row];
    TIoTDemoPlaybackVC *playBackVC = [[TIoTDemoPlaybackVC alloc]init];
    playBackVC.eventItemModel = itemModel;
    playBackVC.deviceModel = self.selectedModel;
    playBackVC.isNVR = self.isNVR;
    playBackVC.deviceName = self.deviceName;
    playBackVC.playerReloadBlock = ^{
        [self addRotateNotification];
        [self getDeviceStatusWithType:action_live qualityType:self.qualityString];
    };
    [self.navigationController pushViewController:playBackVC animated:YES];
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
        [self initVideoParamView];
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
                                                     name:@"xp2preconnect"
                                                   object:nil];
        
    }
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
    
    UIViewController *view = [self getCurrentViewController];
    if ([view isMemberOfClass:[TIoTDemoPreviewDeviceVC class]]) {
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
        
        [self getDeviceStatusWithType:action_live qualityType:self.qualityString];
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
    [[TIoTCoreXP2PBridge sharedInstance] startAppWith:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretId
                                              sec_key:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretKey
                                               pro_id:[TIoTCoreAppEnvironment shareEnvironment].cloudProductId
                                             dev_name:DeviceName?:@""];

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
    [self stopPlayMovie];
    if (self.isNVR == NO) {
        [[TIoTCoreXP2PBridge sharedInstance] stopService:self.deviceName?:@""];
    }
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
//        [TIoTCoreXP2PBridge recordstream:self.deviceName]; //保存到 document 目录 video.data 文件，需打开writeFile开关

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
        if (self.isNVR == NO) {
            [[TIoTCoreXP2PBridge sharedInstance] startAvRecvService:self.deviceName?:@"" cmd:@"action=live"];
        }
        
    }
}

#pragma mark - lazy loading
- (UIView *)landscapeChangeDefinition {
    if (!_landscapeChangeDefinition) {
        _landscapeChangeDefinition = [[UIView alloc]init];
        _landscapeChangeDefinition.backgroundColor = [UIColor clearColor];
        
        CGFloat kLeftPadding = 40;
        CGFloat kBottomPadding = 30;
        CGFloat kBtnWidth = 80;
        CGFloat kBtnHeight = 74;
        
        //标清
        self.standardDef = [UIButton buttonWithType:UIButtonTypeCustom];
        self.standardDef.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.3];
        [self.standardDef addTarget:self action:@selector(switchStandardDef) forControlEvents:UIControlEventTouchUpInside];
        [_landscapeChangeDefinition addSubview:self.standardDef];
        [self.standardDef mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_landscapeChangeDefinition.mas_bottom).offset(-kBottomPadding);
            make.left.equalTo(_landscapeChangeDefinition.mas_left).offset(kLeftPadding);
            make.width.mas_equalTo(kBtnWidth);
            make.height.mas_equalTo(kBtnHeight);
        }];
        UILabel *standardDefValue = [[UILabel alloc]init];
        [standardDefValue setLabelFormateTitle:@"360P" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
        [self.standardDef addSubview:standardDefValue];
        [standardDefValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.standardDef.mas_centerY);
            make.centerX.equalTo(self.standardDef);
        }];
        UILabel *standardDefTip = [[UILabel alloc]init];
        [standardDefTip setLabelFormateTitle:@"标清" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
        [self.standardDef addSubview:standardDefTip];
        [standardDefTip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.standardDef);
            make.top.equalTo(self.standardDef.mas_centerY);
        }];
        
        //高清
        self.highDef = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.highDef addTarget:self action:@selector(switchHighDef) forControlEvents:UIControlEventTouchUpInside];
        self.highDef.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.3];
        [_landscapeChangeDefinition addSubview:self.highDef];
        [self.highDef mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.standardDef);
            make.left.equalTo(self.standardDef.mas_right).offset(20);
            make.bottom.equalTo(self.standardDef.mas_bottom);
        }];
        UILabel *highDefValue = [[UILabel alloc]init];
        [highDefValue setLabelFormateTitle:@"720P" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
        [self.highDef addSubview:highDefValue];
        [highDefValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.highDef.mas_centerY);
            make.centerX.equalTo(self.highDef);
        }];
        UILabel *highDefTip = [[UILabel alloc]init];
        [highDefTip setLabelFormateTitle:@"高清" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
        [self.highDef addSubview:highDefTip];
        [highDefTip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.highDef);
            make.top.equalTo(self.highDef.mas_centerY);
        }];
        
        
        //超清
        self.supperDef = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.supperDef addTarget:self action:@selector(switchSupperDef) forControlEvents:UIControlEventTouchUpInside];
        self.supperDef.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.3];
        [_landscapeChangeDefinition addSubview:self.supperDef];
        [self.supperDef mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(self.standardDef);
            make.bottom.equalTo(self.standardDef.mas_bottom);
            make.left.equalTo(self.highDef.mas_right).offset(20);
        }];
        UILabel *supperDefValue = [[UILabel alloc]init];
        [supperDefValue setLabelFormateTitle:@"1080P" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
        [self.supperDef addSubview:supperDefValue];
        [supperDefValue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.supperDef.mas_centerY);
            make.centerX.equalTo(self.supperDef);
        }];
        UILabel *supperDefTip = [[UILabel alloc]init];
        [supperDefTip setLabelFormateTitle:@"超清" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
        [self.supperDef addSubview:supperDefTip];
        [supperDefTip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.supperDef);
            make.top.equalTo(self.supperDef.mas_centerY);
        }];
        
        
        //提示tip
        UILabel *definitionTip = [[UILabel alloc]init];
        [definitionTip setLabelFormateTitle:@"画质" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentLeft];
        [_landscapeChangeDefinition addSubview:definitionTip];
        [definitionTip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_landscapeChangeDefinition.mas_left).offset(kLeftPadding);
            make.bottom.equalTo(self.standardDef.mas_top).offset(-10);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideDefinitionView)];
        [_landscapeChangeDefinition addGestureRecognizer:tap];
    }
    return _landscapeChangeDefinition;
}

#pragma mark - respensed event
///MARK: 移除横屏清晰度选择view
- (void)hideDefinitionView {
    [self showSettingVidoParamView];
    
    [self.landscapeChangeDefinition removeFromSuperview];
}

- (void)hideSettingVidoParamView {
    self.definitionBtn.hidden = YES;
    self.voiceBtn.hidden = YES;
    self.rotateBtn.hidden = YES;
}

- (void)showSettingVidoParamView {
    self.definitionBtn.hidden = NO;
    self.voiceBtn.hidden = NO;
    self.rotateBtn.hidden = NO;
}

///MARK: 横屏时候默认选中清晰度
- (void)controlLandScapeDefaultQuality {
    if ([self.qualityString isEqualToString:quality_standard]) {
        [self standarDefUI];
    }else if ([self.qualityString isEqualToString:quality_high]) {
        [self highDefUI];
    }else if ([self.qualityString isEqualToString:quality_super]) {
        [self supperDefUI];
    }
}

- (void)switchStandardDef {
    
    [self standarDefUI];
    [self resetVideoPlayerWithQuality:self.qualityString];
}

- (void)standarDefUI {
    self.qualityString = quality_standard;
    self.standardDef.backgroundColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    self.highDef.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.3];
    self.supperDef.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.3];
    [self.definitionBtn setTitle:@"标清" forState:UIControlStateNormal];
    [self hideDefinitionView];
}

- (void)switchHighDef {
    
    [self highDefUI];
    [self resetVideoPlayerWithQuality:self.qualityString];
}

- (void)highDefUI {
    self.qualityString = quality_high;
    self.standardDef.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.3];
    self.highDef.backgroundColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    self.supperDef.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.3];
    [self.definitionBtn setTitle:@"高清" forState:UIControlStateNormal];
    [self hideDefinitionView];
}

- (void)switchSupperDef {
    
    [self supperDefUI];
    [self resetVideoPlayerWithQuality:self.qualityString];
}

- (void)supperDefUI {
    self.qualityString = quality_super;
    self.standardDef.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.3];
    self.highDef.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.3];
    self.supperDef.backgroundColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    [self.definitionBtn setTitle:@"超清" forState:UIControlStateNormal];
    [self hideDefinitionView];
}

///MARK: 切换live 清晰度
- (void)resetVideoPlayerWithQuality:(NSString *)qualityString {
    
    [self.player stop];
    [self.player shutdown];
    self.player = nil;
    
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
    
    if (self.isNVR == NO) {
//        NSString *deviceName = self.deviceName?:@"";
//        [[TIoTCoreXP2PBridge sharedInstance] startAppWith:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretId
//                                                  sec_key:[TIoTCoreAppEnvironment shareEnvironment].cloudSecretKey
//                                                   pro_id:[TIoTCoreAppEnvironment shareEnvironment].cloudProductId
//                                                 dev_name:deviceName];
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

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
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
