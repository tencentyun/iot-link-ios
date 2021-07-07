//
//  TIoTPlayMovieVC.m
//  LinkSDKDemo
//
//

#import "TIoTPlayMovieVC.h"
#import "TIoTCoreXP2PBridge.h"
#import <YYModel.h>
#import "TIoTPlayBackListModel.h"
#import "NSString+Extension.h"
#import "TIoTCoreUtil.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "NSDate+TIoTCustomCalendar.h"

static NSString * const kPlaybackCellID = @"kPlaybackCellID";

@interface TIoTPlayMovieVC ()<UITableViewDelegate,UITableViewDataSource> {
}
@property (weak, nonatomic) IBOutlet UIButton *startSpeekButton;

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property(atomic, retain) IJKFFMoviePlayerController *player;
@end

@implementation TIoTPlayMovieVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self installMovieNotificationObservers];

    [self initializedVideo];
    
    [self setupUIViews:self.playType];
    
    if (self.playType ==  TIotPLayTypePlayback) {
        NSDate *date = [NSDate date];
        NSInteger year = [date dateYear];
        NSInteger month = [date dateMonth];
        NSInteger day = [date dateDay];
        NSString *startTime = [NSString stringWithFormat:@"%02ld-%02ld-%02ld 00:00:00",(long)year,(long)month,(long)day];
        NSString *endTime = [NSString stringWithFormat:@"%02ld-%02ld-%02ld 23:59:59",(long)year,(long)month,(long)day];
        
        NSString *startTimestampString = [NSString getTimeStampWithString:startTime withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
        NSString *endTimestampString = [NSString getTimeStampWithString:endTime withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
        
        NSString *cmdString = [NSString stringWithFormat:@"action=inner_define&cmd=get_record_index&channel=0&starttime=%@&endtime=%@",startTimestampString,endTimestampString];
        
        [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:self.deviceName cmd:cmdString?:@"" timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {

            self.dataArray = [NSArray yy_modelArrayWithClass:[TIoTPlayBackListModel class] json:jsonList];
            [self.tableView reloadData];

        }];
    }
}


- (void)initializedVideo {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width * 9 / 16)];
    imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    self.imageView.userInteractionEnabled = YES;
    
//    [self configVideo];
}

- (void)configVideo {
    
    if ([TIoTCoreXP2PBridge sharedInstance].writeFile) {
        UILabel *fileTip = [[UILabel alloc] initWithFrame:self.imageView.bounds];
        fileTip.text = @"数据帧写文件中...";
        fileTip.textAlignment = NSTextAlignmentCenter;
        fileTip.textColor = [UIColor whiteColor];
        [self.imageView addSubview:fileTip];
        
        [[TIoTCoreXP2PBridge sharedInstance] startAvRecvService:self.deviceName cmd:@"action=live"];
    }else {
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
        
        self.view.autoresizesSubviews = YES;
        [self.imageView addSubview:self.player.view];
        
        [self.player setOptionIntValue:10 * 1000 forKey:@"analyzeduration" ofCategory:kIJKFFOptionCategoryFormat];
        [self.player setOptionIntValue:10 * 1024 forKey:@"probesize" ofCategory:kIJKFFOptionCategoryFormat];
        [self.player setOptionIntValue:0 forKey:@"packet-buffering" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:1 forKey:@"start-on-prepared" ofCategory:kIJKFFOptionCategoryPlayer];
        [self.player setOptionIntValue:1 forKey:@"threads" ofCategory:kIJKFFOptionCategoryCodec];
        [self.player setOptionIntValue:0 forKey:@"sync-av-start" ofCategory:kIJKFFOptionCategoryPlayer];
    }
}

- (void)initializedViews  {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(kScreenWidth/2-100, CGRectGetMaxY(self.imageView.frame) + 30, 200, 50);
    [button setTitle:@"自定义信令测试" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.layer.borderColor = [UIColor blueColor].CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 10;
    [button addTarget:self action:@selector(testCustomSignalling) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self.view addSubview:self.tableView];
    
}

- (void)testCustomSignalling {
    [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:self.deviceName cmd:@"action=user_define&cmd=custom_cmd&channel=0" timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
        [MBProgressHUD showMessage:jsonList icon:@""];
    }];
}

- (void)setupUIViews:(TIotPLayType )type {
    switch (type) {
        case TIotPLayTypeLive:
        {
            self.startSpeekButton.hidden = NO;
            [self configVideo];
            break;
        }
        case TIotPLayTypePlayback:
        {
            self.startSpeekButton.hidden = YES;
            [self initializedViews];
            break;
        }
        default:
            break;
    }
}

- (void)refushVideo:(NSNotification *)notify {
    NSString *DeviceName = [notify.userInfo objectForKey:@"id"];
    if (![DeviceName isEqualToString:self.deviceName]) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:self.deviceName]?:@"";
        
        if (self.playType == TIotPLayTypePlayback) {
            self.videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=playback&channel=0",urlString];
        }else if (self.playType == TIotPLayTypeLive) {
            self.videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=live&channel=0",urlString];
        }
        [self configVideo];
        [self.player prepareToPlay];
        [self.player play];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
    [self removeMovieNotificationObservers];
    
    if ([TIoTCoreXP2PBridge sharedInstance].writeFile) {
        [[TIoTCoreXP2PBridge sharedInstance] stopAvRecvService:self.deviceName];
    }
}

- (void)stopPlayMovie {
    [self.player stop];
    self.player = nil;
}

- (IBAction)sendFLV:(UIButton *)sender {
    
    if ([sender.currentTitle isEqualToString:@"开始对讲"]) {
        
        [sender setTitle:@"结束对讲" forState:UIControlStateNormal];
        [[TIoTCoreXP2PBridge sharedInstance] sendVoiceToServer:self.deviceName channel:@"voice?channel=0"];
    
    }else {
        
        [sender setTitle:@"开始对讲" forState:UIControlStateNormal];
        [[TIoTCoreXP2PBridge sharedInstance] stopVoiceToServer];
    }
    
}

- (IBAction)dismiss:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlaybackCellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    TIoTPlayBackListModel *model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.file_name?:@"";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self stopPlayMovie];
    
    NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:self.deviceName];
    
    TIoTPlayBackListModel *model = self.dataArray[indexPath.row];
    
    NSString *startDate = [self transformTimeString:model.start_time];
    NSString *endDate = [self transformTimeString:model.end_time];
    
    NSString *startStamp = [NSString getTimeStampWithString:startDate withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
    NSString *endStamp = [NSString getTimeStampWithString:endDate withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
    
    self.videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=playback&channel=0&start_time=%@&end_time=%@",urlString,startStamp,endStamp];
    
    [self configVideo];
    [self.player prepareToPlay];
    [self.player play];
}

- (NSString *)transformTimeString:(NSString *)timeString {
    
    NSArray *dateFirstTempArray = [timeString componentsSeparatedByString:@"_"];
    NSString *lastTimeString = dateFirstTempArray.lastObject;
    NSArray *lastArray = [lastTimeString componentsSeparatedByString:@"-"];
    NSMutableString *lastString = [NSMutableString string];
    for (NSString *dateString in lastArray) {
        [lastString appendString:[NSString stringWithFormat:@"%@:",dateString]];
    }

    [lastString deleteCharactersInRange:NSMakeRange(lastString.length - 1, 1)];
    NSString *time = [NSString stringWithFormat:@"%@ %@",dateFirstTempArray.firstObject,lastString];
    
    return time;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 400, kScreenWidth, [self isIphoneX]?300:150)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor lightGrayColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kPlaybackCellID];
    }
    return _tableView;
}

- (BOOL)isIphoneX {
    if (@available(iOS 11.0, *)) {
        if ([[UIApplication sharedApplication].delegate window].safeAreaInsets.bottom > 0) {
            return YES;
        }
        return NO;
    } else {
        return NO;
    }
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
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];

    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;

        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;

        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;

        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
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
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refushVideo:)
                                                 name:@"xp2preconnect"
                                               object:nil];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"xp2preconnect" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self stopPlayMovie];
    [[TIoTCoreXP2PBridge sharedInstance] stopService:self.deviceName];
    
    printf("debugdeinit---%s,%s,%d", __FILE__, __FUNCTION__, __LINE__);
}
@end
