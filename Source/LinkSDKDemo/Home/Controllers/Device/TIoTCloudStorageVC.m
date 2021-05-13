//
//  TIoTCloudStorageVC.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCloudStorageVC.h"
#import "TIoTCustomCalendar.h"
#import "NSString+Extension.h"
#import "TIoTCustomTimeSlider.h"
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface TIoTCloudStorageVC ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIButton *calendarBtn;
@property (nonatomic, strong) UIView *sliderBottomView;
@property (nonatomic, strong) NSString *dayDateString; //选择天日期
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (atomic, retain) IJKFFMoviePlayerController *player;
@property (nonatomic, strong) NSString *videoUrl;

@property (nonatomic, assign) CGFloat kTopPadding; //距离日历间距
@property (nonatomic, assign) CGFloat kLeftPadding; //左边距
@property (nonatomic, assign) CGFloat kItemWith; //每一天长度
@property (nonatomic, assign) CGFloat kScrollContentWidth; // 总长度
@property (nonatomic, assign) CGFloat kSliderHeight; //自定义slider高度
@end

@implementation TIoTCloudStorageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //添加通知
//    [self installMovieNotificationObservers];
    
    [self initializaVariable];
    
    [self setupUIViews];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
    [self removeMovieNotificationObservers];
}

- (void)initializaVariable {
    self.dayDateString = @"";
    self.kTopPadding = 15; //距离日历间距
    self.kLeftPadding = 50; //左边距
    self.kItemWith = kScreenWidth/2; //每一天长度
    self.kScrollContentWidth = self.kItemWith * 24 + self.kLeftPadding*2; // 总长度
    self.kSliderHeight = 30; //自定义slider高度
    self.videoUrl = @"";
}

- (void)setupUIViews {
    
    [self initializedVideo];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat kTopSpace = CGRectGetMaxY(self.imageView.frame) + 10;
    CGFloat kTimeLabelWidth = 230;
    
    self.calendarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.calendarBtn.frame = CGRectMake(10, kTopSpace,100, 40);
    [self.calendarBtn setTitle:@"日历" forState:UIControlStateNormal];
    self.calendarBtn.layer.borderColor = [UIColor blueColor].CGColor;
    self.calendarBtn.layer.borderWidth = 1;
    self.calendarBtn.layer.cornerRadius = 10;
    [self.calendarBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.calendarBtn addTarget:self action:@selector(chooseDate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.calendarBtn];
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - kTimeLabelWidth - 10, kTopSpace, kTimeLabelWidth, 40)];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.text = @"00:00:00";
    [self.view addSubview:self.timeLabel];
    
    //滑动控件底层view
    self.sliderBottomView = [[UIView alloc]initWithFrame:CGRectMake(self.kLeftPadding, CGRectGetMaxY(self.calendarBtn.frame)+self.kTopPadding, self.kScrollContentWidth - self.kLeftPadding*2, self.kSliderHeight)];
    self.sliderBottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.sliderBottomView];
    
    //自定义slider
    TIoTCustomTimeSlider *customTimeSlider = [[TIoTCustomTimeSlider alloc]initWithFrame:CGRectMake(0, 0, self.kScrollContentWidth - self.kLeftPadding*2, self.kSliderHeight)];
    TIoTTimeModel *timeModel = [[TIoTTimeModel alloc]init];
    timeModel.startTime = 0;
    timeModel.endTime = 0;
    customTimeSlider.timeSegmentArray = @[timeModel];
    [self.sliderBottomView addSubview:customTimeSlider];
    [customTimeSlider addObserver:self forKeyPath:@"currentValue" options:NSKeyValueObservingOptionNew context:nil];
    
    //刻度scrollview
    UIScrollView *dateScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.sliderBottomView.frame), kScreenWidth, 50)];
    [self.view addSubview:dateScrollView];
    dateScrollView.delegate = self;
    dateScrollView.contentSize = CGSizeMake(self.kScrollContentWidth, 50);
    
    for (int i = 0; i < 25; i++) {
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(i*self.kItemWith + self.kLeftPadding, 0, 1, 20)];
        lineView.backgroundColor = [UIColor blackColor];
        [dateScrollView addSubview:lineView];
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame), 0, 25, 20)];
        timeLabel.text = [NSString stringWithFormat:@"%d",i];
        [dateScrollView addSubview:timeLabel];
    }
}

#pragma mark - responsed method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        NSLog(@"----%f",[[change objectForKey:NSKeyValueChangeNewKey] floatValue]);
        CGFloat sliderValue= [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        NSInteger secondTime = roundf(sliderValue);
        NSString *timeStr = [self getStampDateStringWithSecond:secondTime];
        
        //选择时间
//        [self stopPlayMovie];
//        self.videoUrl = @"";
//        [self configVideo];
//        [self.player prepareToPlay];
//        [self.player play];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)initializedVideo {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64+40, self.view.frame.size.width, self.view.frame.size.width * 9 / 16)];
    imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    self.imageView.userInteractionEnabled = YES;
}

- (void)chooseDate {
    TIoTCustomCalendar *view = [[TIoTCustomCalendar alloc] initCalendarFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 470)];
    [self.view addSubview:view];
    view.selectedDateBlock = ^(NSString *dateString) {
        NSLog(@"%@",dateString);
        self.dayDateString = dateString;
    };
}

- (NSString *)getStampDateStringWithSecond:(NSInteger )secondTime {
    NSString *secondString = [NSString getDayFormatTimeFromSecond:[NSString stringWithFormat:@"%ld",secondTime]];
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@",self.dayDateString,secondString];
    NSString *stampDate = [NSString getTimeStampWithString:dateStr withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""]?:@"";
    NSLog(@"%@",stampDate);
    self.timeLabel.text = secondString;
    return stampDate;
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
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self stopPlayMovie];
    
    printf("debugdeinit---%s,%s,%d", __FILE__, __FUNCTION__, __LINE__);
}

- (void)configVideo {
    
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

- (void)stopPlayMovie {
    [self.player stop];
    self.player = nil;
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.sliderBottomView.frame = CGRectMake(-scrollView.contentOffset.x + self.kLeftPadding, CGRectGetMaxY(self.calendarBtn.frame)+self.kTopPadding, self.kScrollContentWidth - self.kLeftPadding*2, self.kSliderHeight);
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
