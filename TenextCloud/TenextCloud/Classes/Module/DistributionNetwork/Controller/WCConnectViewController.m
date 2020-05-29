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

#import "GCDAsyncUdpSocket.h"

#define SmartConfigPort 8266

@interface WCConnectViewController ()<TCSocketDelegate,GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CHDWaveView *pan;
@property (nonatomic, strong) UIImageView *imageTip;//成功失败的图片
@property (nonatomic, strong) UILabel *progressLab;
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) NSTimer* timer;

@property (nonatomic, strong) dispatch_source_t tokenTimer;
@property (nonatomic) NSUInteger sendTokenCount;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic) NSUInteger sendCount2;
@property (nonatomic, assign) BOOL isTokenbindedStatus;
@property (strong, nonatomic) dispatch_queue_t delegateQueue;


// to cancel ESPTouchTask when
@property (atomic, strong) ESPTouchTask *_esptouchTask;

// without the condition, if the user tap confirm/cancel quickly enough,
// the bug will arise. the reason is follows:
// 0. task is starting created, but not finished
// 1. the task is cancel for the task hasn't been created, it do nothing
// 2. task is created
// 3. Oops, the task should be cancelled, but it is running
@property (nonatomic, strong) NSCondition *condition;

//@property (nonatomic, strong) TCSocket *socket;
@property (strong, nonatomic) GCDAsyncUdpSocket *socket;

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
//    self.socket = [[TCSocket alloc] init];
//    [self.socket setDeleagte:self];
//    [self.socket openWithIP:ip port:SmartConfigPort];
    
    
    self.delegateQueue = dispatch_queue_create("socketSmart.comDDD", DISPATCH_QUEUE_CONCURRENT);
    self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
    
    NSError *error = nil;
    
    if (![self.socket bindToPort:55551 error:&error]) {     // 端口绑定
        WCLog(@"bindToPort: %@", error);
        [self connectFaild];
        return ;
    }
    if (![self.socket beginReceiving:&error]) {     // 开始监听
        WCLog(@"beginReceiving: %@", error);
        [self connectFaild];
        return ;
    }
    
    // 服务端
    if (![self.socket connectToHost:ip onPort:SmartConfigPort error:&error]) {   // 连接服务器
        WCLog(@"连接失败：%@", error);
        [self connectFaild];
        return ;
    }
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
//    [socket sendData: [NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"timestamp":@((long)[[NSDate date] timeIntervalSince1970])} options:NSJSONWritingPrettyPrinted error:nil]];

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
            //            [self bindDevice:dictionary];
            if ([dictionary[@"cmdType"] integerValue] == 2) {
                //设备已经收到WiFi的ssid/psw/token，正在进行连接WiFi并上报，此时客户端根据token 2秒轮询一次（总时长100s）检测设备状态,然后在绑定设备。
                //如果deviceReply返回的是Current_Error，则配网绑定过程中失败，需要退出配网操作;Previous_Error则为上一次配网的出错日志，只需要上报，不影响当此操作。
                if (![NSObject isNullOrNilWithObject:dictionary[@"deviceReply"]])  {
                    if ([dictionary[@"deviceReply"] isEqualToString:@"Previous_Error"]) {
                        [self checkTokenStateWithCirculationWithDeviceData:dictionary];
                    }else {
                        //deviceReplay 为 Cuttent_Error
                        WCLog(@"smaartConfig配网过程中失败，需要重新配网");
                        [self connectFaild];
                    }
                    
                }else {
                    WCLog(@"dictionary==%@----smaartConfig链路设备success",dictionary);
                    [self checkTokenStateWithCirculationWithDeviceData:dictionary];
                }
                
            }
        }
    });
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    WCLog(@"连接成功");
    
    //设备收到WiFi的ssid/pwd/token，正在上报，此时2秒内，客户端没有收到设备回复，如果重复发送5次，都没有收到回复，则认为配网失败，Wi-Fi 设备有异常
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.tokenTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.tokenTimer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.tokenTimer, ^{
        
        if (self.sendTokenCount >= 5) {
            dispatch_source_cancel(self.tokenTimer);
            dispatch_async(dispatch_get_main_queue(), ^{
               [self connectFaild];
            });
            return ;
        }
        
//        [socket sendData: [NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"token":self.wifiInfo[@"token"]} options:NSJSONWritingPrettyPrinted error:nil]];
        
        [sock sendData:[NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"token":self.wifiInfo[@"token"]} options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
        self.sendTokenCount ++;
    });
    dispatch_resume(self.tokenTimer);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    WCLog(@"发送成功");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    WCLog(@"发送失败 %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];
    WCLog(@"嘟嘟嘟 %@",dictionary);
    
//    if ([dictionary[@"cmdType"] integerValue] == 2) {
//        //设备已经收到WiFi的ssid/psw/token，正在进行连接WiFi并上报，此时客户端根据token 2秒轮询一次（总时长100s）检测设备状态,然后在绑定设备。
//        //如果deviceReply返回的是Current_Error，则配网绑定过程中失败，需要退出配网操作;Previous_Error则为上一次配网的出错日志，只需要上报，不影响当此操作。
//        if (![NSObject isNullOrNilWithObject:dictionary[@"deviceReply"]])  {
//            if ([dictionary[@"deviceReply"] isEqualToString:@"Previous_Error"]) {
//                [self checkTokenStateWithCirculationWithDeviceData:dictionary];
//            }else {
//                //deviceReplay 为 Cuttent_Error
//                WCLog(@"soft配网过程中失败，需要重新配网");
//                [self connectFaild];
//            }
//
//        }else {
//            WCLog(@"dictionary==%@----soft链路设备success",dictionary);
//            [self checkTokenStateWithCirculationWithDeviceData:dictionary];
//        }
//
//    }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (JSONParsingError != nil) {
                [self connectFaild];
            } else {
                //            [self bindDevice:dictionary];
                if ([dictionary[@"cmdType"] integerValue] == 2) {
                    //设备已经收到WiFi的ssid/psw/token，正在进行连接WiFi并上报，此时客户端根据token 2秒轮询一次（总时长100s）检测设备状态,然后在绑定设备。
                    //如果deviceReply返回的是Current_Error，则配网绑定过程中失败，需要退出配网操作;Previous_Error则为上一次配网的出错日志，只需要上报，不影响当此操作。
                    if (![NSObject isNullOrNilWithObject:dictionary[@"deviceReply"]])  {
                        if ([dictionary[@"deviceReply"] isEqualToString:@"Previous_Error"]) {
                            [self checkTokenStateWithCirculationWithDeviceData:dictionary];
                        }else {
                            //deviceReplay 为 Cuttent_Error
                            WCLog(@"smaartConfig配网过程中失败，需要重新配网");
                            [self connectFaild];
                        }
                        
                    }else {
                        WCLog(@"dictionary==%@----smaartConfig链路设备success",dictionary);
                        [self checkTokenStateWithCirculationWithDeviceData:dictionary];
                    }
                    
                }
            }
        });
}



//token 2秒轮询查看设备状态
- (void)checkTokenStateWithCirculationWithDeviceData:(NSDictionary *)data {
    dispatch_source_cancel(self.tokenTimer);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.timer2, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer2, ^{

            if (self.sendCount2 >= 100) {
                dispatch_source_cancel(self.timer2);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self connectFaild];
                });
                return ;
            }
            if (self.isTokenbindedStatus == NO) {
                [self getDevideBindTokenStateWithData:data];
            }
            
            self.sendCount2 ++;
        });
        dispatch_resume(self.timer2);

    });
}

//获取设备绑定token状态
- (void)getDevideBindTokenStateWithData:(NSDictionary *)deviceData {
    [[WCRequestObject shared] post:AppGetDeviceBindTokenState Param:@{@"Token":self.wifiInfo[@"token"]} success:^(id responseObject) {
        //State:Uint Token 状态，1：初始生产，2：可使用状态
        WCLog(@"AppGetDeviceBindTokenState--smaartConfig-responseobject=%@",responseObject);
        if ([responseObject[@"State"] isEqual:@(1)]) {
            self.isTokenbindedStatus = NO;
        }else if ([responseObject[@"State"] isEqual:@(2)]) {
            self.isTokenbindedStatus = YES;
            [self bindingDevidesWithData:deviceData];
        }
    } failure:^(NSString *reason, NSError *error) {
        WCLog(@"AppGetDeviceBindTokenState--smaartConfig-reason=%@---error=%@",reason,error);
        
    }];
}

//判断token返回后（设备状态为2），绑定设备
- (void)bindingDevidesWithData:(NSDictionary *)deviceData {
    if (![NSObject isNullOrNilWithObject:deviceData[@"productId"]]) {
        [[WCRequestObject shared] post:AppTokenBindDeviceFamily Param:@{@"ProductId":deviceData[@"productId"],@"DeviceName":deviceData[@"deviceName"],@"Token":self.wifiInfo[@"token"],@"FamilyId":[WCUserManage shared].familyId,@"RoomId":@"0"} success:^(id responseObject) {
            [self connectSucess:deviceData];
            [HXYNotice addUpdateDeviceListPost];
        } failure:^(NSString *reason, NSError *error) {
            [self connectFaild];
        }];
    }else {
        [self connectFaild];
    }

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
    self.tokenTimer = nil;
    self.timer2 = nil;
    
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
