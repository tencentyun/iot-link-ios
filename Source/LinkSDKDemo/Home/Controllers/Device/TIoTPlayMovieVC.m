//
//  TIoTPlayMovieVC.m
//  LinkSDKDemo
//
//  Created by eagleychen on 2021/1/19.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTPlayMovieVC.h"
#import "LVRTSPPlayer.h"
#import "TIoTCoreXP2PBridge.h"
#import <YYModel.h>
#import "TIoTPlayBackListModel.h"
#import "NSString+Extension.h"

static NSString * const kPlaybackCellID = @"kPlaybackCellID";

@interface TIoTPlayMovieVC ()<UITableViewDelegate,UITableViewDataSource> {
    dispatch_queue_t cfstreamThreadDemuxQueue;
}
@property (weak, nonatomic) IBOutlet UIButton *startSpeekButton;

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic, strong) LVRTSPPlayer *video;
@property (nonatomic, strong) NSTimer *nextFrameTimer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation TIoTPlayMovieVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initializedVideo];
    
    [self setupUIViews:self.playType];
    
    [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:@"action=inner_define&cmd=get_record_index" timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
        
        self.dataArray = [NSArray yy_modelArrayWithClass:[TIoTPlayBackListModel class] json:jsonList];
        [self.tableView reloadData];
        
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    cfstreamThreadDemuxQueue = dispatch_queue_create("LVVideo-CFStreamThreadDemux", DISPATCH_QUEUE_SERIAL);
    
    self.video = [[LVRTSPPlayer alloc] initWithVideo:self.videoUrl usesTcp:YES];
    self.video.outputWidth = self.imageView.frame.size.width;
    self.video.outputHeight = self.imageView.frame.size.height;
    
    self.nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                                           target:self
                                                         selector:@selector(displayNextFrame:)
                                                         userInfo:nil
                                                          repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.nextFrameTimer forMode:NSRunLoopCommonModes];
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
    [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:@"action=user_define&cmd=custom_cmd" timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
        [MBProgressHUD showMessage:jsonList icon:@""];
    }];
}

- (void)setupUIViews:(TIotPLayType )type {
    switch (type) {
        case TIotPLayTypeLive:
        {
            self.startSpeekButton.hidden = NO;
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


- (void)viewDidDisappear:(BOOL)animated {
    [_nextFrameTimer invalidate];
    self.nextFrameTimer = nil;
}

-(void)displayNextFrame:(NSTimer *)timer{    
    dispatch_async(cfstreamThreadDemuxQueue, ^{
        // 耗时的操作
        if (![self.video stepFrame]) {
            [timer invalidate];
            [self.video closeAudio];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
            self.imageView.image = self.video.currentImage;
        });
    });
}

- (void)stopPlayMovie {
    [_nextFrameTimer invalidate];
    self.nextFrameTimer = nil;
    
//    [self.imageView removeFromSuperview];
//    self.imageView = nil;
    
    [self.video closeAudio];
    self.video = nil;
}

- (IBAction)sendFLV:(UIButton *)sender {
    
    if ([sender.currentTitle isEqualToString:@"开始对讲"]) {
        
        [sender setTitle:@"结束对讲" forState:UIControlStateNormal];
        [[TIoTCoreXP2PBridge sharedInstance] sendVoiceToServer];
    
    }else {
        
        [sender setTitle:@"开始对讲" forState:UIControlStateNormal];
        [[TIoTCoreXP2PBridge sharedInstance] stopVoiceToServer];
    }
    
}

- (IBAction)dismiss:(id)sender {
    [[TIoTCoreXP2PBridge sharedInstance] stopService];
    
    [self stopPlayMovie];
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
    
    NSString *urlString = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv];
    
    TIoTPlayBackListModel *model = self.dataArray[indexPath.row];
    
    NSString *startDate = [self transformTimeString:model.start_time];
    NSString *endDate = [self transformTimeString:model.end_time];
    
    NSString *startStamp = [NSString getTimeStampWithString:startDate withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
    NSString *endStamp = [NSString getTimeStampWithString:endDate withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
    
    self.videoUrl = [NSString stringWithFormat:@"%@ipc.flv?action=playback&start_time=%@&end_time=%@",urlString,startStamp,endStamp];
    
    [self configVideo];
    
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

@end
