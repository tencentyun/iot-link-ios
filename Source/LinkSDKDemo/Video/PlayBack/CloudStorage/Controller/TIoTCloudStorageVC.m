//
//  TIoTCloudStorageVC.m
//  LinkSDKDemo
//
//

#import "TIoTCloudStorageVC.h"
#import "TIoTCustomCalendar.h"
#import "NSString+Extension.h"
#import "TIoTCustomTimeSlider.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "NSDate+TIoTCustomCalendar.h"
#import "UIImage+TIoTDemoExtension.h"

#import "TIoTCoreAppEnvironment.h"
#import <YYModel.h>
#import "TIoTCloudStorageDateModel.h"
#import "TIoTCloudStorageDayTimeListModel.h"

#import "TIoTDemoCustomChoiceDateView.h"
#import "TIoTDemoCalendarCustomView.h"
#import "TIoTDemoPlaybackCustomCell.h"
#import "TIoTExploreDeviceListModel.h"
#import "TIoTDemoCloudEventListModel.h"
#import "TIoTDemoCloudStoreDateListModel.h"
#import "TIoTDemoCloudStoreFullVideoUrl.h"

#import "AppDelegate.h"
#import "UIDevice+TIoTDemoRotateScreen.h"

static CGFloat const kPadding = 16;
static NSString *const kPlaybackCustomCellID = @"kPlaybackCustomCellID";
static NSInteger const kLimit = 999;
static CGFloat const kScreenScale = 0.5625; //9/16 高宽比

@interface TIoTCloudStorageVC ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) CGRect screenRect;
@property (nonatomic, strong) NSString *dayDateString; //选择天日期
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (atomic, retain) IJKFFMoviePlayerController *player;

@property (nonatomic, strong) UIView *playView; //player 开始播放按钮背景遮罩
@property (nonatomic, strong) UIView *pauseTipView; //暂停提示View
@property (nonatomic, strong) UIButton *playPauseBtn; //video 等尺寸Btn
@property (nonatomic, strong) UIButton *videoPlayBtn; //player 开始时中间的播放按钮
@property (nonatomic, strong) UIButton *rotateBtn; //控制栏中旋转按钮
@property (nonatomic, strong) UIButton *playBtn; //控制栏中播放按钮
@property (nonatomic, strong) UIView *customControlVidwoView; //video 自定义控制栏
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *currentLabel; //当期时间
@property (nonatomic, strong) UILabel *totalLabel; //总时间
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSArray *timeList; //原始时间
@property (nonatomic, strong) NSMutableArray *modelArray; //重组后存放时间数组

@property (nonatomic, assign) CGFloat kTopPadding; //距离日历间距
@property (nonatomic, assign) CGFloat kLeftPadding; //左边距
@property (nonatomic, assign) CGFloat kItemWith; //每一天长度
@property (nonatomic, assign) CGFloat kScrollContentWidth; // 总长度
@property (nonatomic, assign) CGFloat kSliderHeight; //自定义slider高度

@property (nonatomic, strong) TIoTDemoCustomChoiceDateView *choiceDateView; //自定义滚动条
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray; //云存事件列表数组
@property (nonatomic, strong) NSArray *cloudStoreDateList;

@property (nonatomic, copy) NSString *currentDayTime; //当天时间 2020-1-1
@property (nonatomic, strong) TIoTDemoCloudStoreFullVideoUrl *fullVideoURl;
@property (nonatomic, strong) TIoTDemoCloudEventListModel *listModel;

@property (nonatomic, strong) TIoTDemoCloudEventModel *videoTimeModel;
@property (nonatomic, assign) NSInteger currentTime;
@property (nonatomic, strong) dispatch_source_t timer; //进度条计时器
@property (nonatomic, strong) dispatch_source_t controlTimer; //控制栏隐藏计时器

@property (nonatomic, assign) BOOL isHidePlayBtn; //播放按钮
@property (nonatomic, assign) BOOL isTimerSuspend;
@property (nonatomic, assign) NSInteger scrollDuraionTime;
@property (nonatomic, assign) NSInteger startStamp;
@property (nonatomic, assign) BOOL isInnerScroll;
@property (nonatomic, assign) BOOL isPause; //是否暂停
@end

@implementation TIoTCloudStorageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isHidePlayBtn = NO;
    self.isTimerSuspend = NO;
    self.screenRect = [UIApplication sharedApplication].delegate.window.frame;
    
    [self addRotateNotification];
    
    [self installMovieNotificationObservers];
    
    [self initializaVariable];
    
    [self setupUIViews];
    
    //获取具有云存日期
    [self requestCloudStorageDateList];
    
    //获取某一天云存时间轴
    [self requestCloudStorageDayDate];
    
    //云存事件列表
    [self requestCloudStoreVideoList];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [self recoverNavigationBar];
    
    [self ratetePortrait];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    if (self.playerReloadBlock) {
        self.playerReloadBlock();
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
    [self removeMovieNotificationObservers];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    
    [self stopPlayMovie];
    
    [self closeTime];
    printf("debugdeinit---%s,%s,%d", __FILE__, __FUNCTION__, __LINE__);
}

///MARK: 关闭定时器
- (void)closeTime {
    
    if (self.timer) {
        if (self.isTimerSuspend == YES) {
            dispatch_resume(self.timer);
            self.isTimerSuspend = NO;
        }
    }
    
    if (self.timer != nil) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
    
    if (self.controlTimer != nil) {
        dispatch_source_cancel(self.controlTimer);
        self.controlTimer = nil;
    }
}

- (void)addRotateNotification {
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleOrientationChange:)
                                                name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)setEventItemModel:(TIoTDemoCloudEventModel *)eventItemModel {
    _eventItemModel = eventItemModel;
}

- (void)initializaVariable {
    self.dayDateString = @"";
    self.kTopPadding = 15; //距离日历间距
    self.kLeftPadding = 65; //左边距
    self.kItemWith = 60; //每一小时长度
    self.kScrollContentWidth = self.kItemWith * 24 + self.kLeftPadding*2; // 总长度
    self.kSliderHeight = 30; //自定义slider高度
    self.videoUrl = @"";
    
    NSDate *date = [NSDate date];
    NSInteger year = [date dateYear];
    NSInteger month = [date dateMonth];
    NSInteger day = [date dateDay];
    self.currentDayTime = [NSString stringWithFormat:@"%02ld-%02ld-%02ld",(long)year,(long)month,(long)day];
}

- (void)setupUIViews {
    
    [self initializedVideo];
    
    self.title = @"回放";
    
    self.view.backgroundColor = [UIColor colorWithHexString:KActionSheetBackgroundColor];
    
    __weak typeof(self) weakSelf = self;
    self.choiceDateView = [[TIoTDemoCustomChoiceDateView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.width * 9 / 16, kScreenWidth, 116)];
    //从日历中选日期
    self.choiceDateView.chooseDateBlock = ^(UIButton * _Nonnull button) {
        
        TIoTDemoCalendarCustomView *calendarView = [[TIoTDemoCalendarCustomView alloc]init];
        //获取云存时间传给日历
        calendarView.calendarDateArray = weakSelf.cloudStoreDateList;
        
        calendarView.choickDayDateBlock = ^(NSString * _Nonnull dayDateString) {
            //更新选择日期时间，并重新请求云存列表刷新UI
            [weakSelf.choiceDateView resetSelectedDate:dayDateString];
            weakSelf.currentDayTime = dayDateString?:weakSelf.currentDayTime;
            //刷新云存事件列表和一天时间抽
            weakSelf.currentTime = 0;
            weakSelf.scrollDuraionTime = weakSelf.currentTime;
            weakSelf.isInnerScroll = NO;
            weakSelf.isHidePlayBtn = YES;
            weakSelf.isPause = NO;
            [weakSelf requestCloudStorageDayDate];
            [weakSelf requestCloudStoreVideoList];
            
            
        };
        [[UIApplication sharedApplication].delegate.window addSubview:calendarView];
        [calendarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
        }];
        
    };
    //选择之前事件，获取开始/结束时间戳
    self.choiceDateView.previousDateBlcok = ^(TIoTTimeModel * _Nonnull preTimeModel) {
        if (preTimeModel != nil) {
            //关闭定时器
            [weakSelf closeTime];
            
            TIoTDemoCloudEventModel *previousModel = [[TIoTDemoCloudEventModel alloc]init];
            
            NSString *startString = [NSString stringWithFormat:@"%@ 00:00:00",weakSelf.currentDayTime?:@""];
            NSString *startTimestampString = [NSString getTimeStampWithString:startString withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
            CGFloat startStamp = startTimestampString.floatValue + preTimeModel.startTime;
            CGFloat endStamp = startTimestampString.floatValue + preTimeModel.endTime;
            previousModel.StartTime = [NSString stringWithFormat:@"%f",startStamp];
            previousModel.EndTime = [NSString stringWithFormat:@"%f",endStamp];
            weakSelf.currentTime = 0;
            weakSelf.scrollDuraionTime = weakSelf.currentTime;
            weakSelf.isInnerScroll = NO;
            weakSelf.isHidePlayBtn = YES;
            weakSelf.isPause = NO;
            [weakSelf getFullVideoURLWithPartURL:weakSelf.listModel.VideoURL withTime:previousModel isChangeModel:YES];
            
            [weakSelf setScrollOffsetWith:previousModel];
        }
        
    };
    //选择下一个事件，获取开始/结束时间戳
    self.choiceDateView.nextDateBlcok = ^(TIoTTimeModel * _Nonnull nextTimeModel) {
        if (nextTimeModel!= nil) {
            //关闭定时器
            [weakSelf closeTime];
            
            TIoTDemoCloudEventModel *nextModel = [[TIoTDemoCloudEventModel alloc]init];
            
            NSString *startString = [NSString stringWithFormat:@"%@ 00:00:00",weakSelf.currentDayTime?:@""];
            NSString *startTimestampString = [NSString getTimeStampWithString:startString withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
            CGFloat startStamp = startTimestampString.floatValue + nextTimeModel.startTime;
            CGFloat endStamp = startTimestampString.floatValue + nextTimeModel.endTime;
            nextModel.StartTime = [NSString stringWithFormat:@"%f",startStamp];
            nextModel.EndTime = [NSString stringWithFormat:@"%f",endStamp];
            weakSelf.currentTime = 0;
            weakSelf.scrollDuraionTime = weakSelf.currentTime;
            weakSelf.isInnerScroll = NO;
            weakSelf.isHidePlayBtn = YES;
            weakSelf.isPause = NO;
            [weakSelf getFullVideoURLWithPartURL:weakSelf.listModel.VideoURL withTime:nextModel isChangeModel:YES];
            
            [weakSelf setScrollOffsetWith:nextModel];
        }
    };
    //滑动停止后，获取当前值所在事件开始/结束时间戳
    self.choiceDateView.timeModelBlock = ^(TIoTTimeModel * _Nonnull selectedTimeModel, CGFloat startTimestamp) {
        NSLog(@"startStamp--%f----%f",startTimestamp,selectedTimeModel.startTime);
        
        //关闭定时器
        [weakSelf closeTime];

        TIoTDemoCloudEventModel *currentModel = [[TIoTDemoCloudEventModel alloc]init];

        NSString *startString = [NSString stringWithFormat:@"%@ 00:00:00",weakSelf.currentDayTime?:@""];
        NSString *startTimestampString = [NSString getTimeStampWithString:startString withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];

        NSInteger startValue = startTimestampString.integerValue + selectedTimeModel.startTime;
        NSInteger startDurationValue = startTimestamp - startValue;

        NSInteger endStamp = startTimestampString.integerValue + selectedTimeModel.endTime ;
        currentModel.StartTime = [NSString stringWithFormat:@"%ld",(long)startValue];
        currentModel.EndTime = [NSString stringWithFormat:@"%ld",(long)endStamp];
        weakSelf.currentTime = startDurationValue;
        weakSelf.slider.value = startDurationValue;
        weakSelf.player.currentPlaybackTime = startDurationValue;
        weakSelf.scrollDuraionTime = weakSelf.currentTime;
        weakSelf.startStamp = startValue;
        weakSelf.isInnerScroll = YES;
        weakSelf.isHidePlayBtn = YES;
        weakSelf.isPause = NO;
        
        if (weakSelf.videoTimeModel.StartTime.integerValue <= startTimestamp && weakSelf.videoTimeModel.EndTime.integerValue >=startTimestamp ) {
            if (weakSelf.isTimerSuspend == YES) {
                if (weakSelf.timer) {
                    if (weakSelf.isTimerSuspend == YES) {
                        dispatch_resume(weakSelf.timer);
                        weakSelf.isTimerSuspend = NO;
                    }
                }
                
                //关闭定时器
                if (weakSelf.timer != nil) {
                    dispatch_source_cancel(weakSelf.timer);
                    weakSelf.timer = nil;
                }
            }
            if (weakSelf.player.isPlaying == NO) {
                [weakSelf tapVideoView:weakSelf.playPauseBtn];
            }
            [weakSelf startPlayVideoWithStartTime:currentModel.StartTime.integerValue endTime:currentModel.EndTime.integerValue sliderValue:weakSelf.currentTime];
        }else {
            [weakSelf getFullVideoURLWithPartURL:weakSelf.listModel.VideoURL withTime:currentModel isChangeModel:YES];
        }
        
        TIoTDemoCloudEventModel *scorllCurrentModel = [[TIoTDemoCloudEventModel alloc]init];
        scorllCurrentModel.StartTime = [NSString stringWithFormat:@"%f",startTimestamp];
        [weakSelf setScrollOffsetWith:scorllCurrentModel];
        
    };
    [self.view addSubview:self.choiceDateView];
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.backgroundColor = [UIColor colorWithHexString:KActionSheetBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 84;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TIoTDemoPlaybackCustomCell class] forCellReuseIdentifier:kPlaybackCustomCellID];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.choiceDateView.mas_bottom).offset(kPadding);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - network request

//MARK: 获取具有云存日期
- (void)requestCloudStorageDateList {
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"DeviceName"] = self.deviceModel.DeviceName?:@"";
    paramDic[@"Version"] = @"2020-12-15";
    
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeCloudStorageDate vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTDemoCloudStoreDateListModel *dateList = [TIoTDemoCloudStoreDateListModel yy_modelWithJSON:responseObject];
        if (dateList.Data.count != 0) {
            self.cloudStoreDateList = [NSArray arrayWithArray:dateList.Data];
        }
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
    }];
}

//MARK:获取某一天云存时间轴
- (void)requestCloudStorageDayDate {
  
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"DeviceName"] = self.deviceModel.DeviceName?:@"";
    paramDic[@"Date"] = self.currentDayTime?:@"";
    paramDic[@"Version"] = @"2020-12-15";
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeCloudStorageTime vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTCloudStorageDayTimeListModel *data = [TIoTCloudStorageDayTimeListModel yy_modelWithJSON:responseObject[@"Data"]];
        
        //data.VideoURL 需要拼接
        self.timeList = [NSArray arrayWithArray:data.TimeList?:@[]];
        
        [self recombineTimeSegmentWithTimeArray:self.timeList];
        
        self.choiceDateView.videoTimeSegmentArray = self.modelArray;
        
        if (self.eventItemModel != nil) {
            self.currentTime = 0;
            self.scrollDuraionTime = self.currentTime;
            self.isInnerScroll = NO;
            self.isPause = NO;
            [self getFullVideoURLWithPartURL:data.VideoURL?:@"" withTime:self.eventItemModel isChangeModel:YES];
        }else {
            if (self.modelArray.count != 0) {
                TIoTTimeModel *timeModel = self.modelArray[0]?:[[TIoTTimeModel alloc]init];
                TIoTDemoCloudEventModel *model = [[TIoTDemoCloudEventModel alloc]init];

                NSString *startString = [self getDeytimeFormat:round(timeModel.startTime?:0)];
                NSString *endString = [self getDeytimeFormat:round(timeModel.endTime?:0)];
                model.StartTime = [NSString getTimeStampWithString:startString?:@"" withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
                model.EndTime = [NSString getTimeStampWithString:endString?:@"" withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
                
                self.currentTime = 0;
                self.scrollDuraionTime = self.currentTime;
                self.isInnerScroll = NO;
                self.isPause = NO;
                [self getFullVideoURLWithPartURL:data.VideoURL?:@"" withTime:model isChangeModel:YES];
        //        [self setScrollOffsetWith:timeModel];
            }
        }
        
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
    }];
}

- (NSString *)getDeytimeFormat:(NSInteger)timestamp {
    NSInteger hour = timestamp / (60*60);
    NSInteger mintue = timestamp % (60*60) / 60;
    NSInteger second = timestamp % (60*60) % 60;
    
    NSString *partTime = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hour,(long)mintue,(long)second];
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",self.currentDayTime,partTime];
    return dateString;
}
///MARK: 获取视频防盗链播放URL
- (void)getFullVideoURLWithPartURL:(NSString *)videoPartURL withTime:(TIoTDemoCloudEventModel *)timeModel isChangeModel:(BOOL)isChange
{
    NSString *currentStamp = [NSString getNowTimeString];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"Version"] = @"2020-12-15";
    paramDic[@"VideoURL"] = [NSString stringWithFormat:@"%@?starttime_epoch=%ld&endtime_epoch=%ld",videoPartURL,(long)timeModel.StartTime.integerValue,(long)timeModel.EndTime.integerValue]?:@"";
    paramDic[@"ExpireTime"] = [NSNumber numberWithInteger:currentStamp.integerValue + 3600];
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:GenerateSignedVideoURL vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTDemoCloudStoreFullVideoUrl *fullVideoURl = [TIoTDemoCloudStoreFullVideoUrl yy_modelWithJSON:responseObject];
        NSLog(@"--fullVideoURL--%@",fullVideoURl.SignedVideoURL);
 
        if (isChange == YES) {
            self.videoTimeModel = [[TIoTDemoCloudEventModel alloc]init];
            self.videoTimeModel.StartTime = timeModel.StartTime;
            self.videoTimeModel.EndTime = timeModel.EndTime;
        }
        
        //视频播放
        self.videoUrl = fullVideoURl.SignedVideoURL?:@"";
        if (self.isHidePlayBtn == YES) {
            [self stopPlayMovie];
            [self configVideo];
            [self.player prepareToPlay];
            [self.player play];
            [self autoHideControlView];
        }
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
    }];
}

///MARK: 云存事件列表
- (void)requestCloudStoreVideoList {
    
    NSString *startString = [NSString stringWithFormat:@"%@ 00:00:00",self.currentDayTime?:@""];
    NSString *endString = [NSString stringWithFormat:@"%@ 23:59:59",self.currentDayTime?:@""];
    NSString *startTimestampString = [NSString getTimeStampWithString:startString withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
    NSString *endTimesstampString = [NSString getTimeStampWithString:endString withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"Version"] = @"2020-12-15";
    paramDic[@"Size"] = [NSNumber numberWithInteger:kLimit];
    paramDic[@"DeviceName"] = self.deviceModel.DeviceName?:@"";
    paramDic[@"StartTime"] = [NSNumber numberWithInteger:startTimestampString.integerValue];
    paramDic[@"EndTime"] = [NSNumber numberWithInteger:endTimesstampString.integerValue];
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeCloudStorageEvents vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        
        self.listModel = [TIoTDemoCloudEventListModel yy_modelWithJSON:responseObject];
        
        if (self.listModel.Events.count != 0) {
            self.dataArray = [NSMutableArray arrayWithArray:self.listModel.Events?:@[]];
            self.dataArray = (NSMutableArray *)[[self.dataArray reverseObjectEnumerator] allObjects];
            self.currentTime = 0;
            self.scrollDuraionTime = self.currentTime;
            self.isInnerScroll = NO;
            self.isPause = NO;
//            [self getFullVideoURLWithPartURL:self.listModel.VideoURL?:@"" withTime:self.dataArray[0] isChangeModel:YES];
            [self setScrollOffsetWith:self.dataArray[0]];
            
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
    paramDic[@"DeviceName"] = self.deviceModel.DeviceName?:@"";
    paramDic[@"Thumbnail"] = eventModel.Thumbnail?:@"";
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeCloudStorageThumbnail vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTDemoCloudEventModel *tuumbnailModel = [TIoTDemoCloudEventModel yy_modelWithJSON:responseObject];
        eventModel.ThumbnailURL = tuumbnailModel.ThumbnailURL;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
    }];
    
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTDemoPlaybackCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlaybackCustomCellID forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentTime = 0;
    self.isHidePlayBtn = YES;
    self.scrollDuraionTime = self.currentTime;
    self.isInnerScroll = NO;
    self.isPause = NO;
    TIoTDemoCloudEventModel *selectedModel = self.dataArray[indexPath.row];
    [self getFullVideoURLWithPartURL:self.listModel.VideoURL withTime:selectedModel isChangeModel:YES];
    [self setScrollOffsetWith:selectedModel];
}

#pragma mark - handler orientation event
- (void)handleOrientationChange:(NSNotification *)notification {
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
        self.choiceDateView.hidden = YES;
        self.tableView.hidden = YES;
        self.screenRect = [UIApplication sharedApplication].delegate.window.frame;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.screenRect.size.width);
            make.top.bottom.equalTo(self.view);
        }];
    }else { //竖屏
        self.choiceDateView.hidden = NO;
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
        
        [self.choiceDateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(116);
        }];
        
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.choiceDateView.mas_bottom).offset(kPadding);
            make.left.right.bottom.equalTo(self.view);
        }];
    }
}

///MARK:横屏
- (void)rotateLandscapeRight {
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

#pragma mark - responsed method

- (void)initializedVideo {
    
//    CGFloat kTopPadding = [self getTopMaiginWithNavigationBar];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.userInteractionEnabled = YES;
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
    
    self.playView = [[UIView alloc]init];
    [self.imageView addSubview:self.playView];
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.imageView);
    }];
    
    self.videoPlayBtn = [[UIButton alloc]init];
    [self.videoPlayBtn setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    [self.videoPlayBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.playView addSubview:self.videoPlayBtn];
    [self.videoPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playView);
        make.width.height.mas_equalTo(60);
    }];
    
}

///MARK: 控制栏隐藏状态下tap Video时响应
- (void)tapVideoView:(UIButton *)button {
    
    if (self.customControlVidwoView.hidden == YES ) {
        
        if (!button.selected) {
            [self pauseVideo];
        }
        button.selected = !button.selected;
        
    }else if (self.customControlVidwoView.hidden == NO) {
        
        if (!button.selected) {
            [self pauseVideo];
        }else {
            
            [self resumeVideo];
        }
        
        button.selected = !button.selected;
    }
}

- (void)pauseVideo {
    if (self.controlTimer != nil) {
        dispatch_source_cancel(self.controlTimer);
        self.controlTimer = nil;
    }
    self.customControlVidwoView.hidden = NO;
    self.playPauseBtn.hidden = NO;
    self.pauseTipView.hidden = NO;
    [self.playBtn setImage:[UIImage imageNamed:@"play_pause"] forState:UIControlStateNormal];
    [self.player pause];
    if (self.timer) {
        dispatch_suspend(self.timer);
        self.isTimerSuspend = YES;
    }
    self.currentTime = self.slider.value;
    self.isPause = NO;
}

- (void)resumeVideo {
    [self autoHideControlView];
    self.playPauseBtn.hidden = YES;
    self.pauseTipView.hidden = YES;
    [self.playBtn setImage:[UIImage imageNamed:@"play_control"] forState:UIControlStateNormal];
    [self.player play];
    if (self.timer) {
        dispatch_resume(self.timer);
        self.isTimerSuspend = NO;
    }
    self.isPause = YES;
}
///MARK:播放视频按钮方法
- (void)playVideo:(UIButton *)button {
    self.currentTime = 0;
    self.isPause = NO;
    self.scrollDuraionTime = self.currentTime;
    
    self.videoPlayBtn.hidden = YES;
    if (self.isHidePlayBtn == NO) {
        [self stopPlayMovie];
        [self configVideo];
        [self.player prepareToPlay];
        [self.player play];
        [self autoHideControlView];
        
        self.isHidePlayBtn = YES;
        
    }else {
        [self stopPlayMovie];
        [self configVideo];
        [self.player prepareToPlay];
        [self.player play];
        [self autoHideControlView];
    }
}

///MARK: 设置播放器样式
- (void)setupPlayerCustomControlView {
    
    if (self.customControlVidwoView != nil) {
        [self.customControlVidwoView removeFromSuperview];
    }
    if (self.playPauseBtn != nil) {
        [self.playPauseBtn removeFromSuperview];
    }
    
    //播放时长 时间戳差值
//    NSInteger durationValue = self.videoTimeModel.EndTime.integerValue - self.videoTimeModel.StartTime.integerValue;
    NSInteger durationValue = self.player.duration; //+ self.scrollDuraionTime;
    NSInteger minuteValue = durationValue / 60;
    NSInteger secondValue = durationValue % 60;
    
    self.customControlVidwoView = [[UIView alloc]init];
    self.customControlVidwoView.backgroundColor = [UIColor clearColor];
    [self.imageView addSubview:self.customControlVidwoView];
    [self.customControlVidwoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.imageView);
    }];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"play_control"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(controlVidePlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.customControlVidwoView addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(16);
        make.bottom.equalTo(self.imageView.mas_bottom).offset(-14);
        make.left.equalTo(self.customControlVidwoView.mas_left).offset(16);
    }];
    
    self.rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rotateBtn setImage:[UIImage imageNamed:@"play_rotate_icon"] forState:UIControlStateNormal];
    [self.rotateBtn addTarget:self action:@selector(rotateScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.customControlVidwoView addSubview:self.rotateBtn];
    [self.rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.customControlVidwoView.mas_right).offset(-kPadding);
        make.width.height.mas_equalTo(16);
        make.bottom.equalTo(self.customControlVidwoView.mas_bottom).offset(-14);
    }];
    
    self.currentLabel = [[UILabel alloc]init];
    [self.currentLabel setLabelFormateTitle:@"00:00" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
    [self.customControlVidwoView addSubview:self.currentLabel];
    [self.currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.centerY.equalTo(self.playBtn.mas_centerY);
        make.left.equalTo(self.playBtn.mas_right).offset(10);
    }];
    
    self.totalLabel = [[UILabel alloc]init];
    [self.totalLabel setLabelFormateTitle:[NSString stringWithFormat:@"%02ld:%02ld",(long)minuteValue,(long)secondValue] font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentCenter];
    [self.customControlVidwoView addSubview:self.totalLabel];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.centerY.equalTo(self.rotateBtn.mas_centerY);
        make.right.equalTo(self.rotateBtn.mas_left).offset(-10);
    }];
    
    
    self.slider = [[UISlider alloc]init];
    self.slider.minimumTrackTintColor = [UIColor colorWithHexString:kVideoDemoSignGreenColor];
    UIImage *thumbImage = [UIImage imageWithColor:[UIColor colorWithHexString:kVideoDemoSignGreenColor] size:CGSizeMake(12, 12)];
    [self.slider setThumbImage:[UIImage makeRoundCornersWithRadius:6 withImage:thumbImage] forState:UIControlStateNormal];
//    self.slider.minimumValue = self.videoTimeModel.StartTime.floatValue;
//    self.slider.maximumValue = self.videoTimeModel.EndTime.floatValue;
//    self.slider.minimumValue = 0;
//    self.slider.maximumValue = durationValue;
    
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.customControlVidwoView addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentLabel.mas_right).offset(10);
        make.right.equalTo(self.totalLabel.mas_left).offset(-10);
        make.height.mas_equalTo(20);
        make.centerY.equalTo(self.rotateBtn);
    }];
    
    if (self.isHidePlayBtn == NO) {
        [self.imageView bringSubviewToFront:self.playView];

    }else {
        self.playPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playPauseBtn.backgroundColor = [UIColor clearColor];
        [self.playPauseBtn addTarget:self action:@selector(tapVideoView:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:self.playPauseBtn];
        [self.playPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.imageView);
            make.bottom.equalTo(self.imageView.mas_bottom).offset(-50);
        }];
        
        [self.playPauseBtn addSubview:self.pauseTipView];
        [self.pauseTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(102);
            make.height.mas_equalTo(42);
            make.centerX.equalTo(self.playPauseBtn);
            make.centerY.equalTo(self.playPauseBtn.mas_centerY);
        }];
        self.pauseTipView.hidden = YES;
        
        UIImageView *pauseTipImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play_control"]];
        [self.pauseTipView addSubview:pauseTipImage];
        [pauseTipImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.pauseTipView.mas_left).offset(16);
            make.centerY.equalTo(self.pauseTipView);
            make.width.height.mas_equalTo(16);
        }];
        
        UILabel *pauseTipLabel = [[UILabel alloc]init];
        [pauseTipLabel setLabelFormateTitle:@"已暂停" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentLeft];
        [self.pauseTipView addSubview:pauseTipLabel];
        [pauseTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(pauseTipImage.mas_right).offset(12);
            make.centerY.equalTo(pauseTipImage.mas_centerY);
        }];
    }
    
}

///MARK: 进度条滚动响应方法
- (void)sliderValueChanged:(id)sender {
    
    [self autoHideControlView];
    
    UISlider *slider = (UISlider *)sender;
    self.currentTime = round(slider.value);
    NSLog(@"-!!!!!!!~~~~~~--%f \n---start:%f----\n ent:%f\n",round(self.player.currentPlaybackTime),round(self.player.playableDuration) ,round(self.player.duration));
    
    TIoTDemoCloudEventModel *currentTimeModel = [[TIoTDemoCloudEventModel alloc]init];
    if (self.isInnerScroll == YES) {
        currentTimeModel.StartTime = [NSString stringWithFormat:@"%ld",self.startStamp + self.currentTime];
    }else {
        currentTimeModel.StartTime = [NSString stringWithFormat:@"%ld",self.videoTimeModel.StartTime.integerValue + self.currentTime];
    }
    
    currentTimeModel.EndTime = self.videoTimeModel.EndTime;
    
    if (self.isTimerSuspend == YES) {
        if (self.timer) {
            if (self.isTimerSuspend == YES) {
                dispatch_resume(self.timer);
                self.isTimerSuspend = NO;
            }
        }
        
        //关闭定时器
        if (self.timer != nil) {
            dispatch_source_cancel(self.timer);
            self.timer = nil;
        }
    }
    self.scrollDuraionTime = self.currentTime;
    self.isHidePlayBtn = YES;
    if (self.player.isPlaying == NO) {
        [self tapVideoView:self.playPauseBtn];
    }
    self.isPause = NO;
    self.player.currentPlaybackTime = self.currentTime;
    [self startPlayVideoWithStartTime:self.videoTimeModel.StartTime.integerValue endTime:self.videoTimeModel.EndTime.integerValue sliderValue:self.player.currentPlaybackTime];
//    [self getFullVideoURLWithPartURL:self.listModel.VideoURL withTime:currentTimeModel isChangeModel:NO];
    [self setScrollOffsetWith:currentTimeModel];
    
}

///MARK: 控制栏播放按钮响应方法
- (void)controlVidePlay:(UIButton *)button {
    
    [self tapVideoView:self.playPauseBtn];
}

- (void)rotateScreen {
    
    [self autoHideControlView];
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.isRotation == YES) {
        appDelegate.isRotation = NO;
        [self ratetePortrait];
    }else {
        appDelegate.isRotation = YES;
        [self rotateLandscapeRight];
    }
    [self resetScreenSubviewsWithLandscape:appDelegate.isRotation];
}

- (NSString *)getStampDateStringWithSecond:(NSInteger )secondTime {
    NSString *secondString = [NSString getDayFormatTimeFromSecond:[NSString stringWithFormat:@"%ld",secondTime]];
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@",self.dayDateString,secondString];
    NSString *stampDate = [NSString getTimeStampWithString:dateStr withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""]?:@"";
    NSLog(@"%@",stampDate);
    self.timeLabel.text = secondString;
    return stampDate;
}

/// MARK: video控制栏自动隐藏
- (void)autoHideControlView {
    
    if (self.controlTimer != nil) {
        dispatch_source_cancel(self.controlTimer);
        self.controlTimer = nil;
    }
    
    __weak typeof(self) weakSelf = self;
    
    __block NSInteger time = 3; //计时开始
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    weakSelf.controlTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(weakSelf.controlTimer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(weakSelf.controlTimer, ^{
        
        if(time <= 0){ //计时结束，关闭
            weakSelf.videoPlayBtn.hidden = NO;
            
            dispatch_source_cancel(weakSelf.controlTimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.playPauseBtn.hidden = NO;
                weakSelf.customControlVidwoView.hidden = YES;
            });
            
        }else{
            weakSelf.videoPlayBtn.hidden = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.customControlVidwoView.hidden = NO;
                weakSelf.playPauseBtn.hidden = NO;
            });
            time--;
            
        }
    });
    dispatch_resume(weakSelf.controlTimer);
}

- (void)recombineTimeSegmentWithTimeArray:(NSArray *)timeArray {
    
    if (self.modelArray.count != 0) {
        [self.modelArray removeAllObjects];
    }
    
    [timeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TIoTCloudStorageTimeDataModel *model = obj;
        
        if (idx == 0) {
            TIoTTimeModel *timeModel = [[TIoTTimeModel alloc]init];
            timeModel.startTime = model.StartTime.doubleValue;
            timeModel.endTime = model.EndTime.doubleValue;
            
            [self.modelArray addObject:timeModel];
            
        }else {
            TIoTTimeModel *timeModel = [[TIoTTimeModel alloc]init];
            timeModel.startTime = model.StartTime.doubleValue;
            timeModel.endTime = model.EndTime.doubleValue;
            
            NSMutableArray *tempModelArray = [[NSMutableArray alloc]initWithArray:self.modelArray];
            TIoTTimeModel *lastModel = tempModelArray.lastObject;
            if (timeModel.startTime - lastModel.endTime <= 60) {
                
                lastModel.endTime = timeModel.endTime;
                
                [self.modelArray replaceObjectAtIndex:(tempModelArray.count - 1) withObject:lastModel];
            }else {
                [self.modelArray addObject:timeModel];
            }
            
        }
    }];
    
    [self convertTimeArrayItemParam];
}

- (void)convertTimeArrayItemParam{
    if (self.modelArray.count != 0) {
        [self.modelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TIoTTimeModel *itemModel = obj;
            
            TIoTTimeModel *timeModel = [[TIoTTimeModel alloc]init];
            timeModel.startTime = [self captureTimestampWithOutDaySecound:itemModel.startTime];
            timeModel.endTime = [self captureTimestampWithOutDaySecound:itemModel.endTime];
            
            [self.modelArray replaceObjectAtIndex:idx withObject:timeModel];
        }];
    }
}

- (NSInteger )captureTimestampWithOutDaySecound:(CGFloat)stamp {
    
    CGFloat timeStamp = stamp;
    NSString *dateString = [NSString convertTimestampToTime:@(timeStamp) byDateFormat:@"YYYY-MM-dd HH:mm:ss"]?:@"";
    
    NSArray *dateTempArray = [dateString componentsSeparatedByString:@" "];
    NSString *dayTime = dateTempArray.lastObject;
    NSArray *dayTempTime = [dayTime componentsSeparatedByString:@":"];
    NSString *hourString = dayTempTime.firstObject;
    NSString *mitString = dayTempTime[1];
    NSString *secString = dayTempTime.lastObject;
        
    NSInteger hour = hourString.intValue;
    NSInteger minute = mitString.intValue;
    NSInteger second = secString.intValue;
    
    NSInteger totalSecond = second + minute*60 + hour*3600;
    
    return totalSecond;
}

#pragma mark - 滚动条偏移
- (void)setScrollOffsetWith:(TIoTDemoCloudEventModel *)timeModel {
    //滚动条移动对应位置
    NSInteger secondsNumber = 86400;
    NSInteger kItemWith = 60;
    NSInteger startSecondNum = [self captureTimestampWithOutDaySecound:timeModel.StartTime.floatValue];
    CGFloat scrollOffsetX = (startSecondNum)/(secondsNumber/(kItemWith*24));
    [self.choiceDateView  setScrollViewContentOffsetX:scrollOffsetX currtentSecond:startSecondNum];
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
        ///设置播放器样式
        [self setupPlayerCustomControlView];
        
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
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
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            if (self.isPause == NO) {
                self.player.currentPlaybackTime = self.currentTime;
            }
            [self startPlayVideoWithStartTime:self.videoTimeModel.StartTime.integerValue endTime:self.videoTimeModel.EndTime.integerValue sliderValue:self.currentTime];
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            self.isPause = YES;
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

//计时器
- (void)startPlayVideoWithStartTime:(NSInteger )startTime endTime:(NSInteger )endTime sliderValue:(NSInteger)sliderValue{
    
    if (self.timer) {
        if (self.isTimerSuspend == YES) {
            dispatch_resume(self.timer);
            self.isTimerSuspend = NO;
        }
    }
    
    if (self.timer != nil) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
    //播放时长 时间戳差值
    
    __weak typeof(self) weakSelf = self;
    
    __block NSInteger time = sliderValue; //计时开始
    
    NSInteger durationValue = self.player.duration;
    NSInteger minuteValue = durationValue / 60;
    NSInteger secondValue = durationValue % 60;
    
    self.slider.minimumValue = 0;
    self.slider.maximumValue = durationValue;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    weakSelf.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(weakSelf.timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(weakSelf.timer, ^{
        
        if(time >= durationValue){ //计时结束，关闭
            
            dispatch_source_cancel(weakSelf.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf stopPlayMovie];
                //起始时间等于duration
                weakSelf.totalLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",minuteValue,secondValue];
                weakSelf.currentLabel.text = weakSelf.totalLabel.text;
                NSLog(@"over:-----sliderValue:%f---currentTime:%f----totalTime:%f----playduratio:%f",self.slider.value,self.player.currentPlaybackTime,self.player.duration,self.player.playableDuration);
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.currentLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)self.player.currentPlaybackTime/60,(NSInteger)self.player.currentPlaybackTime%60];
                weakSelf.totalLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",minuteValue,secondValue];;
                weakSelf.slider.value = time;
                NSLog(@"duration:-----sliderValue:%f---currentTime:%f----totalTime:%f----playduratio:%f",self.slider.value,self.player.currentPlaybackTime,self.player.duration,self.player.playableDuration);
            });
            time++;
            
        }
    });
    dispatch_resume(weakSelf.timer);
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];

    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            [self.imageView bringSubviewToFront:self.playView];
            self.videoPlayBtn.hidden = NO;
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

#pragma mark Install Movie Notifications
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
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
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - lazy loading
- (NSMutableArray *)modelArray {
    if (!_modelArray) {
        _modelArray = [[NSMutableArray alloc]init];
    }
    return _modelArray;
}

- (NSArray *)cloudStoreDateList {
    if (!_cloudStoreDateList) {
        _cloudStoreDateList = [[NSArray alloc]init];
    }
    return _cloudStoreDateList;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (UIView *)pauseTipView {
    if (!_pauseTipView) {
        _pauseTipView = [[UIView alloc]init];
        _pauseTipView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
        _pauseTipView.layer.cornerRadius = 8;
    }
    return _pauseTipView;
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
