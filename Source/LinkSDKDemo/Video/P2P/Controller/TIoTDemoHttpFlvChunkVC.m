//
//  TIoTDemoHttpFlvChunkVC.m
//  LinkSDKDemo
//

#import "TIoTDemoHttpFlvChunkVC.h"
#import "TIoTHttpFlvChunkPuller.h"
#import "TIoTCoreXP2PBridge.h"

@interface TIoTDemoHttpFlvChunkVC () <TIoTHttpFlvChunkPullerDelegate>

@property (nonatomic, strong) TIoTHttpFlvChunkPuller *pullerA;
@property (nonatomic, strong) TIoTHttpFlvChunkPuller *pullerB;

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *statusLabelA;
@property (nonatomic, strong) UILabel *statusLabelB;
@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *stopBtn;

@property (nonatomic, strong) NSTimer *refreshTimer;

@property (nonatomic, assign) BOOL sdkReady;

@end

@implementation TIoTDemoHttpFlvChunkVC

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _dumpToFile = YES; // 默认打开 dump，调试用
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dumpToFile = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.channelA.length == 0) { self.channelA = @"0"; }
    if (self.channelB.length == 0) { self.channelB = @"1"; }
    if (self.quality.length  == 0) { self.quality  = @"high"; }

    self.title = @"HTTP-FLV 多通道拉流事例";
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupUI];
    [self registerNotifications];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
    [self.pullerA stop];
    [self.pullerB stop];
}

#pragma mark - UI

- (void)setupUI {
    CGFloat top = [self getTopMaiginWithNavigationBar] + 20;
    CGFloat width = self.view.bounds.size.width - 40;

    self.tipLabel = [self makeLabelWithFrame:CGRectMake(20, top, width, 60)];
    self.tipLabel.text = [NSString stringWithFormat:
                          @"设备: %@/%@\n将同时拉取 channel=%@ 与 channel=%@，quality=%@",
                          self.productId ?: @"-", self.deviceName ?: @"-",
                          self.channelA, self.channelB, self.quality];
    [self.view addSubview:self.tipLabel];

    self.statusLabelA = [self makeLabelWithFrame:CGRectMake(20, top + 80, width, 80)];
    self.statusLabelA.text = [NSString stringWithFormat:@"channel=%@ 等待启动…", self.channelA];
    [self.view addSubview:self.statusLabelA];

    self.statusLabelB = [self makeLabelWithFrame:CGRectMake(20, top + 180, width, 80)];
    self.statusLabelB.text = [NSString stringWithFormat:@"channel=%@ 等待启动…", self.channelB];
    [self.view addSubview:self.statusLabelB];

    self.startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.startBtn.frame = CGRectMake(20, top + 290, 140, 44);
    self.startBtn.layer.borderWidth = 1;
    self.startBtn.layer.borderColor = [UIColor systemBlueColor].CGColor;
    self.startBtn.layer.cornerRadius = 6;
    [self.startBtn setTitle:@"开始拉流(双通道)" forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(onStartTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startBtn];

    self.stopBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.stopBtn.frame = CGRectMake(180, top + 290, 140, 44);
    self.stopBtn.layer.borderWidth = 1;
    self.stopBtn.layer.borderColor = [UIColor systemRedColor].CGColor;
    self.stopBtn.layer.cornerRadius = 6;
    [self.stopBtn setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    [self.stopBtn setTitle:@"停止拉流" forState:UIControlStateNormal];
    [self.stopBtn addTarget:self action:@selector(onStopTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.stopBtn];
}

- (UILabel *)makeLabelWithFrame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor darkTextColor];
    label.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    label.layer.cornerRadius = 4;
    label.layer.masksToBounds = YES;
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

#pragma mark - Notifications

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onXp2pReady:)
                                                 name:TIoTCoreXP2PBridgeNotificationReady
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onXp2pDisconnect:)
                                                 name:TIoTCoreXP2PBridgeNotificationDisconnect
                                               object:nil];
}

- (void)onXp2pReady:(NSNotification *)note {
    NSString *dev = note.userInfo[@"id"];
    if (![dev isEqualToString:self.deviceName]) {
        return;
    }
    self.sdkReady = YES;
    NSLog(@"[HttpFlvDemo] xp2p ready for %@", dev);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tipLabel.text = [self.tipLabel.text stringByAppendingString:@"\nSDK ready ✅"];
    });
}

- (void)onXp2pDisconnect:(NSNotification *)note {
    NSString *dev = note.userInfo[@"id"];
    if (![dev isEqualToString:self.deviceName]) {
        return;
    }
    self.sdkReady = NO;
    NSLog(@"[HttpFlvDemo] xp2p disconnect for %@", dev);
}

#pragma mark - Actions

- (void)onStartTapped {
    if (self.productId.length == 0 || self.deviceName.length == 0) {
        self.tipLabel.text = @"productId / deviceName 为空，无法拉流";
        return;
    }

    // 1. combinedId 使用 "productId/deviceName" 拼接
    NSString *combinedId = [NSString stringWithFormat:@"%@/%@", self.productId, self.deviceName];

    // 2. 通过 SDK 获取本地 http-flv 服务的 base url（形如 http://127.0.0.1:xxxxx/）
    NSString *base = [[TIoTCoreXP2PBridge sharedInstance] getUrlForHttpFlv:combinedId];
    if (base.length == 0) {
        self.tipLabel.text = @"获取 http-flv base url 失败，请等待 SDK ready 后重试";
        return;
    }

    // 3. 拼接两个不同 channel 的完整 URL
    NSString *urlA = [NSString stringWithFormat:@"%@ipc.flv?action=live&channel=%@&quality=%@",
                      base, self.channelA, self.quality];
    NSString *urlB = [NSString stringWithFormat:@"%@ipc.flv?action=live&channel=%@&quality=%@",
                      base, self.channelB, self.quality];

    // 4. dump 到本地文件（可选，调试用）
    NSString *dumpA = nil, *dumpB = nil;
    if (self.dumpToFile) {
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                NSUserDomainMask, YES) firstObject];
        dumpA = [docDir stringByAppendingPathComponent:
                 [NSString stringWithFormat:@"httpflv_channel_%@.flv", self.channelA]];
        dumpB = [docDir stringByAppendingPathComponent:
                 [NSString stringWithFormat:@"httpflv_channel_%@.flv", self.channelB]];
    }

    // 5. 停掉旧的 puller，重新创建
    [self.pullerA stop];
    [self.pullerB stop];

    self.pullerA = [[TIoTHttpFlvChunkPuller alloc]
                    initWithTag:[NSString stringWithFormat:@"ch%@", self.channelA]
                            url:urlA];
    self.pullerA.delegate = self;
    self.pullerA.dumpFilePath = dumpA;
    [self.pullerA start];

    self.pullerB = [[TIoTHttpFlvChunkPuller alloc]
                    initWithTag:[NSString stringWithFormat:@"ch%@", self.channelB]
                            url:urlB];
    self.pullerB.delegate = self;
    self.pullerB.dumpFilePath = dumpB;
    [self.pullerB start];

    // 6. 定时刷新状态显示
    [self.refreshTimer invalidate];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                         target:self
                                                       selector:@selector(refreshStatus)
                                                       userInfo:nil
                                                        repeats:YES];
    [self refreshStatus];
}

- (void)onStopTapped {
    [self.pullerA stop];
    [self.pullerB stop];
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
    [self refreshStatus];
}

- (void)refreshStatus {
    self.statusLabelA.text = [NSString stringWithFormat:
                              @"channel=%@\nrunning=%@  bytes=%llu\nurl=%@",
                              self.channelA,
                              self.pullerA.isRunning ? @"YES" : @"NO",
                              self.pullerA.receivedBytes,
                              self.pullerA.url ?: @"-"];
    self.statusLabelB.text = [NSString stringWithFormat:
                              @"channel=%@\nrunning=%@  bytes=%llu\nurl=%@",
                              self.channelB,
                              self.pullerB.isRunning ? @"YES" : @"NO",
                              self.pullerB.receivedBytes,
                              self.pullerB.url ?: @"-"];
}

#pragma mark - TIoTHttpFlvChunkPullerDelegate

// 回调在非主线程，务必轻量处理
- (void)puller:(TIoTHttpFlvChunkPuller *)puller didReceiveResponse:(NSHTTPURLResponse *)response {
    NSLog(@"[HttpFlvDemo][%@] http status=%ld", puller.tag, (long)response.statusCode);
}

- (void)puller:(TIoTHttpFlvChunkPuller *)puller didReceiveChunk:(NSData *)data {
    // 收到一段 FLV 数据。
    // 真实业务场景下，可在此处将 data 送入 FLV 解封装 / 播放器输入队列。
}

- (void)puller:(TIoTHttpFlvChunkPuller *)puller didFinishWithError:(NSError *)error {
    NSLog(@"[HttpFlvDemo][%@] finished, error=%@", puller.tag, error);
}

@end
