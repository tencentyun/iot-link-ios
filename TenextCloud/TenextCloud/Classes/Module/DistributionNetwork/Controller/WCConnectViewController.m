//
//  WCSmartConfigConnectViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/17.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCConnectViewController.h"
#import "WCDistributionNetworkViewController.h"
#import "CHDWaveView.h"

#import "ESP_NetUtil.h"
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import "ESPAES.h"
#import "TCSocket.h"

#define SmartConfigPort 8266

@interface WCConnectViewController ()<TCSocketDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CHDWaveView *pan;
@property (nonatomic, strong) UIImageView *imageTip;//成功失败的图片
@property (nonatomic, strong) UILabel *progressLab;
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) NSTimer* timer;

// to cancel ESPTouchTask when
@property (atomic, strong) ESPTouchTask *_esptouchTask;

// without the condition, if the user tap confirm/cancel quickly enough,
// the bug will arise. the reason is follows:
// 0. task is starting created, but not finished
// 1. the task is cancel for the task hasn't been created, it do nothing
// 2. task is created
// 3. Oops, the task should be cancelled, but it is running
@property (nonatomic, strong) NSCondition *condition;

@property (nonatomic, strong) TCSocket *socket;

@property (nonatomic,strong) MASConstraint *topLayout;

@end

@implementation WCConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    [self tapConfirmForResults];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self cancel];
}

- (void)dealloc{
    [self releaseAlloc];
}

#pragma mark -

- (void)setupUI{
    self.view.backgroundColor = kRGBColor(247, 249, 250);
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [cancleBtn sizeToFit];
    UIBarButtonItem *cancleItem = [[UIBarButtonItem alloc] initWithCustomView:cancleBtn];
    self.navigationItem.leftBarButtonItems  = @[cancleItem];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    [self.scrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
        make.height.greaterThanOrEqualTo(@0.f);
    }];
    
    
    self.imageTip = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 220)];
    self.imageTip.hidden = YES;
    self.imageTip.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.imageTip];
    
    self.pan = [[CHDWaveView alloc] initWithFrame: CGRectMake(0, 64, kScreenWidth, 220)];
    self.pan.backgroundColor = kRGBColor(204, 204, 204);
    self.pan.progress = 0;
    self.pan.speed = 0.8;
    [self.contentView addSubview:self.pan];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self progress];
    }];
    
    self.progressLab = [[UILabel alloc] init];
    self.progressLab.text = @"连接中";
    self.progressLab.textColor = kRGBColor(51, 51, 51);
    self.progressLab.font = [UIFont boldSystemFontOfSize:20];
    [self.contentView addSubview:self.progressLab];
    [self.progressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        self.topLayout = make.top.equalTo(self.pan.mas_bottom).offset(40);
    }];
    
    self.tipLab = [[UILabel alloc] init];
    self.tipLab.text = @"请将设备与手机尽量靠近";
    self.tipLab.textColor = kRGBColor(51, 51, 51);
    self.tipLab.font = [UIFont wcPfRegularFontOfSize:16];
    [self.view addSubview:self.tipLab];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.progressLab.mas_bottom).offset(10);
    }];
}

//假的进度条
- (void)progress{
    self.pan.progress += 0.01;
    if (self.pan.progress >= 0.99){
        self.pan.progress = 0.99;
    }
}

//配网成功
- (void)connectSucess:(NSDictionary *)devieceData{
    [self releaseAlloc];
    self.tipLab.hidden = YES;
    self.progressLab.text = @"连接成功";
    self.progressLab.textColor = kRGBColor(26, 173, 25);
    [self.topLayout setOffset:0];
    self.pan.progress = 1;
    self.pan.hidden = YES;
    self.imageTip.hidden = NO;
    self.imageTip.image = [UIImage imageNamed:@"c_suc"];
    
    UIButton *tryAgainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tryAgainBtn setTitle:@"继续添加新设备" forState:UIControlStateNormal];
    [tryAgainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tryAgainBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [tryAgainBtn addTarget:self action:@selector(changeTypeClick:) forControlEvents:UIControlEventTouchUpInside];
    tryAgainBtn.backgroundColor = kMainColor;
    tryAgainBtn.layer.cornerRadius = 3;
    [self.view addSubview:tryAgainBtn];
    [tryAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(self.progressLab.mas_bottom).offset(149 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 60);
        make.height.mas_equalTo(48);
    }];
    
    
    UIButton *changeTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeTypeBtn setTitle:@"返回首页" forState:UIControlStateNormal];
    [changeTypeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    changeTypeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [changeTypeBtn addTarget:self action:@selector(backHome:) forControlEvents:UIControlEventTouchUpInside];
    changeTypeBtn.backgroundColor = kMainColor;
    changeTypeBtn.layer.cornerRadius = 3;
    [self.view addSubview:changeTypeBtn];
    [changeTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(tryAgainBtn.mas_bottom).offset(30 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 60);
        make.height.mas_equalTo(48);
        make.bottom.equalTo(self.contentView).offset(-30);
    }];
}

//配网失败
- (void)connectFaild{
    [self releaseAlloc];
    self.tipLab.hidden = YES;
    self.progressLab.text = @"连接失败";
    self.progressLab.textColor = kRGBColor(229, 69, 69);
    [self.topLayout setOffset:0];
    self.pan.progress = 0;
    self.pan.hidden = YES;
    self.imageTip.hidden = NO;
    self.imageTip.image = [UIImage imageNamed:@"c_fail"];
    
    
    UILabel *errorResultLab = [[UILabel alloc] init];
    errorResultLab.numberOfLines = 0;
    errorResultLab.textColor = kFontColor;
    errorResultLab.font = [UIFont wcPfRegularFontOfSize:14];
    errorResultLab.text = @"1、检查设备是否通电，并按照指引进入配网模式\n2、检查WIFI是否正常（暂时只支持2.4G路由器）\n3、检查WIFI密码是否错误";
    errorResultLab.textAlignment = NSTextAlignmentLeft;
    
    [self.contentView addSubview:errorResultLab];
    [errorResultLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-30);
        make.top.equalTo(self.progressLab.mas_bottom).offset(20);
    }];
    
    UIButton *moreResultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreResultBtn setTitle:@"查看更多失败原因" forState:UIControlStateNormal];
    [moreResultBtn addTarget:self action:@selector(moreErrorResult:) forControlEvents:UIControlEventTouchUpInside];
    moreResultBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [moreResultBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    [self.contentView addSubview:moreResultBtn];
    [moreResultBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30);
        make.top.equalTo(errorResultLab.mas_bottom).offset(5);
    }];
    
    UIButton *tryAgainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tryAgainBtn setTitle:@"按步骤重试" forState:UIControlStateNormal];
    [tryAgainBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    tryAgainBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [tryAgainBtn addTarget:self action:@selector(tryAgainClick:) forControlEvents:UIControlEventTouchUpInside];
    tryAgainBtn.backgroundColor = [UIColor whiteColor];
    tryAgainBtn.layer.cornerRadius = 3;
    [self.view addSubview:tryAgainBtn];
    [tryAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(moreResultBtn.mas_bottom).offset(40 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 60);
        make.height.mas_equalTo(48);
    }];
    
    
    UIButton *changeTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeTypeBtn setTitle:@"切换配网方式" forState:UIControlStateNormal];
    [changeTypeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    changeTypeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [changeTypeBtn addTarget:self action:@selector(changeTypeClick:) forControlEvents:UIControlEventTouchUpInside];
    changeTypeBtn.backgroundColor = kMainColor;
    changeTypeBtn.layer.cornerRadius = 3;
    [self.view addSubview:changeTypeBtn];
    [changeTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(tryAgainBtn.mas_bottom).offset(30 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 60);
        make.height.mas_equalTo(48);
        make.bottom.equalTo(self.contentView).offset(-30);
    }];
}

//创建udp连接，进行广播
- (void)createudpConnect:(NSString *)ip{
    self.socket = [[TCSocket alloc] init];
    [self.socket setDeleagte:self];
    [self.socket openWithIP:ip port:SmartConfigPort];
}


- (void)tapConfirmForResults{

    NSString *apSsid = self.wifiInfo[@"name"];
    NSString *apPwd = self.wifiInfo[@"pwd"];
    NSString *apBssid = self.wifiInfo[@"bssid"];


    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        // execute the task
        NSArray *esptouchResultArray = [self executeForResultsWithSsid:apSsid bssid:apBssid password:apPwd taskCount:1 broadcast:YES];
        // show the result to the user in UI Main Thread
        dispatch_async(dispatch_get_main_queue(), ^{


            ESPTouchResult *firstResult = [esptouchResultArray objectAtIndex:0];
            // check whether the task is cancelled and no results received
            if (!firstResult.isCancelled)
            {
                NSMutableString *mutableStr = [[NSMutableString alloc]init];
                NSUInteger count = 0;
                // max results to be displayed, if it is more than maxDisplayCount,
                // just show the count of redundant ones
                const int maxDisplayCount = 5;
                if ([firstResult isSuc])
                {

                    for (int i = 0; i < [esptouchResultArray count]; ++i)
                    {
                        ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                        [mutableStr appendString:[resultInArray description]];
                        [mutableStr appendString:@"\n"];
                        count++;
                        NSString *ipAddrDataStr = [ESP_NetUtil descriptionInetAddr4ByData:resultInArray.ipAddrData];
                        if (ipAddrDataStr==nil) {
                            ipAddrDataStr = [ESP_NetUtil descriptionInetAddr6ByData:resultInArray.ipAddrData];
                        }
                        [self createudpConnect:ipAddrDataStr];

                        if (count >= maxDisplayCount)
                        {
                            break;
                        }


                    }

                    if (count < [esptouchResultArray count])
                    {
                        [mutableStr appendString:[NSString stringWithFormat:@"\nthere's %lu more result(s) without showing\n",(unsigned long)([esptouchResultArray count] - count)]];
                    }


                }

                else
                {
                    [self connectFaild];
                }
            }

        });
    });
}

//获取签名，绑定设备
- (void)bindDevice:(NSDictionary *)deviceData{
    
    if (![NSObject isNullOrNilWithObject:deviceData[@"productId"]]) {
        
        [[WCRequestObject shared] post:AppSigBindDeviceInFamily Param:@{@"ProductId":deviceData[@"productId"],@"DeviceName":deviceData[@"deviceName"],@"TimeStamp":deviceData[@"timestamp"],@"ConnId":deviceData[@"connId"],@"Signature":deviceData[@"signature"],@"DeviceTimestamp":deviceData[@"timestamp"],@"FamilyId":[WCUserManage shared].familyId} success:^(id responseObject) {
            [self connectSucess:deviceData];
            [HXYNotice addUpdateDeviceListPost];
        } failure:^(NSString *reason, NSError *error) {
            [self connectFaild];
        }];
        
    }
    else
    {
        [self connectFaild];
    }
}

#pragma mark eventResponse
- (void)cancleClick:(id)sender{
    
    WCAlertView *av = [[WCAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleText];
    [av alertWithTitle:@"退出添加设备" message:@"当前正在添加设备，是否确认退出" cancleTitlt:@"取消" doneTitle:@"确定"];
    av.doneAction = ^(NSString * _Nonnull text) {
        [self releaseAlloc];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [av showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)changeTypeClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tryAgainClick:(id)sender{
    
    for (UIViewController * controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[WCDistributionNetworkViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

- (void)moreErrorResult:(id)sender{
    
}

- (void)backHome:(id)sender{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    [HXYNotice addUpdateDeviceListPost];
}

#pragma mark - TCSocketDelegate
- (void)onHandleSocketOpen:(TCSocket *)socket {
    NSLog(@"%@ did open",socket);
    [socket sendData: [NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"timestamp":@((long)[[NSDate date] timeIntervalSince1970])} options:NSJSONWritingPrettyPrinted error:nil]];
}

- (void)onHandleSocketClosed:(TCSocket *)socket {
    NSLog(@"%@ did close",socket);
}
- (void)onHandleDataReceived:(TCSocket *)socket data:(NSData *)data {
    NSLog(@"%@ did receive data %@",socket,data);
    //TCIotDevice *result;
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (JSONParsingError != nil) {
            [self connectFaild];
        } else {
            [self bindDevice:dictionary];
        }
    });
}

#pragma mark - the example of how to cancel the executing task

- (void)cancel{
    [self.condition lock];
    if (self._esptouchTask != nil)
    {
        [self._esptouchTask interrupt];
    }
    [self.condition unlock];
}

- (void)releaseAlloc{
    [self.timer invalidate];
    self.timer = nil;
    [self.socket close];
    self.socket = nil;
}

#pragma mark - the example of how to use executeForResults
- (NSArray *) executeForResultsWithSsid:(NSString *)apSsid bssid:(NSString *)apBssid password:(NSString *)apPwd taskCount:(int)taskCount broadcast:(BOOL)broadcast
{
    [self.condition lock];
    self._esptouchTask = [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd andTimeoutMillisecond:30000];
    
    // set delegate
    //[self._esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    [self._esptouchTask setPackageBroadcast:broadcast];
    [self.condition unlock];
    NSArray * esptouchResults = [self._esptouchTask executeForResults:taskCount];
    WCLog(@"ESPViewController executeForResult() result is: %@",esptouchResults);
    return esptouchResults;
}

#pragma mark setter or getter
- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = kRGBColor(247, 249, 250);
    }
    return _scrollView;
}

- (UIView *)contentView{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = kRGBColor(247, 249, 250);
    }
    return _contentView;
}

- (NSCondition *)condition
{
    if (!_condition) {
        _condition = [[NSCondition alloc]init];
    }
    return _condition;
}

@end
