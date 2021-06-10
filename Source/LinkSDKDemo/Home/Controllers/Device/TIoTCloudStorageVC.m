//
//  TIoTCloudStorageVC.m
//  LinkSDKDemo
//
//

#import "TIoTCloudStorageVC.h"
#import "TIoTCustomCalendar.h"
#import "NSString+Extension.h"
#import "TIoTCustomTimeSlider.h"
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#import <AVFoundation/AVFoundation.h>
#import "NSDate+TIoTCustomCalendar.h"

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
//@property (atomic, retain) IJKFFMoviePlayerController *player;
//@property (strong, nonatomic)AVPlayer *avPlayer;
//@property (strong, nonatomic)AVPlayerItem *avItem;
//@property (strong, nonatomic)AVPlayerLayer *avPlayerLayer;

@property (nonatomic, strong) UIButton *rotateBtn;
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
@end

@implementation TIoTCloudStorageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.screenRect = [UIApplication sharedApplication].delegate.window.frame;
    
    [self addRotateNotification];
    
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
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    [self.player shutdown];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
}

- (void)addRotateNotification {
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleOrientationChange:)
                                                name:UIDeviceOrientationDidChangeNotification object:nil];
    
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
        
    };
    //选择下一个事件，获取开始/结束时间戳
    self.choiceDateView.nextDateBlcok = ^(TIoTTimeModel * _Nonnull nextTimeModel) {
        
    };
    //滑动停止后，获取当前值所在事件开始/结束时间戳
    self.choiceDateView.timeModelBlock = ^(TIoTTimeModel * _Nonnull selectedTimeModel, CGFloat startTimestamp) {
        NSLog(@"--%f--%f",startTimestamp,selectedTimeModel.startTime);
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
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
    }];
}

///MARK: 获取视频防盗链播放URL
- (void)getFullVideoURLWithPartURL:(NSString *)videoPartURL withTime:(TIoTDemoCloudEventModel *)timeModel
{
    NSString *currentStamp = [NSString getNowTimeString];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"Version"] = @"2020-12-15";
    paramDic[@"VideoURL"] = [NSString stringWithFormat:@"%@?starttime_epoch=%ld&endtime_epoch=%ld",videoPartURL,(long)timeModel.StartTime.integerValue,(long)timeModel.EndTime.integerValue]?:@"";
    paramDic[@"ExpireTime"] = [NSNumber numberWithInteger:currentStamp.integerValue + 3600];
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:GenerateSignedVideoURL vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTDemoCloudStoreFullVideoUrl *fullVideoURl = [TIoTDemoCloudStoreFullVideoUrl yy_modelWithJSON:responseObject];
        NSLog(@"--fullVideoURL--%@",fullVideoURl.SignedVideoURL);
        
        //播放
//        [self stopPlayMovie];
//        self.videoUrl = fullVideoURl.SignedVideoURL?:@"";
//        [self configVideo];
//        [self.player prepareToPlay];
//        [self.player play];
        
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
            [self getFullVideoURLWithPartURL:self.listModel.VideoURL?:@"" withTime:self.dataArray[0]];
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
    TIoTDemoCloudEventModel *selectedModel = self.dataArray[indexPath.row];
    [self getFullVideoURLWithPartURL:self.listModel.VideoURL withTime:selectedModel];
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
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.screenRect.size.width/kScreenScale);
            make.top.bottom.equalTo(self.view);
        }];
    }else { //竖屏
        self.choiceDateView.hidden = NO;
        self.tableView.hidden = NO;
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
    
    UIImageView *videoPlayImage = [[UIImageView alloc]init];
    videoPlayImage.image = [UIImage imageNamed:@"video_play"];
    [self.imageView addSubview:videoPlayImage];
    [videoPlayImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.imageView);
        make.width.height.mas_equalTo(60);
    }];
    
    self.rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rotateBtn setImage:[UIImage imageNamed:@"play_rotate_icon"] forState:UIControlStateNormal];
    [self.rotateBtn addTarget:self action:@selector(rotateScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:self.rotateBtn];
    [self.rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.imageView.mas_right).offset(-kPadding);
        make.width.height.mas_equalTo(16);
        make.bottom.equalTo(self.imageView.mas_bottom).offset(-14);
    }];
    

//    NSURL *mediaURL = [NSURL URLWithString:self.videoUrl];
//    self.avItem = [AVPlayerItem playerItemWithURL:mediaURL];
//    self.avPlayer = [AVPlayer playerWithPlayerItem:self.avItem];
//    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
//    self.avPlayerLayer.frame = self.imageView.bounds;
//    [self.imageView.layer addSublayer:self.avPlayerLayer];
//    [self.avPlayer play];
}

- (void)rotateScreen {
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

//- (void)dealloc
//{
//    [self stopPlayMovie];
//
//    printf("debugdeinit---%s,%s,%d", __FILE__, __FUNCTION__, __LINE__);
//}
//
//- (void)configVideo {
//
//        [self stopPlayMovie];
//#ifdef DEBUG
//        [IJKFFMoviePlayerController setLogReport:YES];
//        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
//#else
//        [IJKFFMoviePlayerController setLogReport:NO];
//        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
//#endif
//
//        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
//        // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];
//
//        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
//
//        self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.videoUrl] withOptions:options];
//        self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        self.player.view.frame = self.imageView.bounds;
//        self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
//        self.player.shouldAutoplay = YES;
//
//        self.view.autoresizesSubviews = YES;
//        [self.imageView addSubview:self.player.view];
//
//        [self.player setOptionIntValue:10 * 1000 forKey:@"analyzeduration" ofCategory:kIJKFFOptionCategoryFormat];
//        [self.player setOptionIntValue:10 * 1024 forKey:@"probesize" ofCategory:kIJKFFOptionCategoryFormat];
//        [self.player setOptionIntValue:0 forKey:@"packet-buffering" ofCategory:kIJKFFOptionCategoryPlayer];
//        [self.player setOptionIntValue:1 forKey:@"start-on-prepared" ofCategory:kIJKFFOptionCategoryPlayer];
//        [self.player setOptionIntValue:1 forKey:@"threads" ofCategory:kIJKFFOptionCategoryCodec];
//        [self.player setOptionIntValue:0 forKey:@"sync-av-start" ofCategory:kIJKFFOptionCategoryPlayer];
//
//}
//
//- (void)stopPlayMovie {
//    [self.player stop];
//    self.player = nil;
//}

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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
