//
//  WCSoftapWaitVC.m
//  TenextCloud
//
//  Created by Wp on 2019/11/11.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCSoftapWaitVC.h"
#import "GCDAsyncUdpSocket.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>
#import "CHDWaveView.h"

#define APIP @"192.168.4.1"
#define APPort 8266

@interface WCSoftapWaitVC ()<GCDAsyncUdpSocketDelegate>
@property (strong, nonatomic) GCDAsyncUdpSocket *socket;
@property (strong, nonatomic) dispatch_queue_t delegateQueue;

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic) NSUInteger sendCount;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic) NSUInteger sendCount2;

@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CHDWaveView *pan;
@property (nonatomic, strong) UILabel *progressLab;
@property (nonatomic, strong) UILabel *tipLab;

@property (nonatomic,strong) NSDictionary *signInfo;//签名信息

@end

@implementation WCSoftapWaitVC

- (void)dealloc
{
    WCLog(@"释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    [self createudpConnect:[NSString getGateway]];
    
}

//创建udp连接
- (void)createudpConnect:(NSString *)ip{
    
    
    self.delegateQueue = dispatch_queue_create("socket.comDDD", DISPATCH_QUEUE_CONCURRENT);
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
    if (![self.socket connectToHost:ip onPort:8266 error:&error]) {   // 连接服务器
        WCLog(@"连接失败：%@", error);
        [self connectFaild];
        return ;
    }
}

#pragma mark - TCSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    WCLog(@"连接成功");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        
        if (self.sendCount >= 3) {
            dispatch_source_cancel(self.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
               [self connectFaild];
            });
            return ;
        }
        
        NSString *Ssid = self.wifiInfo[@"name"];
        NSString *Pwd = self.wifiInfo[@"pwd"];
        [sock sendData:[NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(1),@"ssid":Ssid,@"password":Pwd} options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
        self.sendCount ++;
    });
    dispatch_resume(self.timer);
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
    self.signInfo = dictionary;
    WCLog(@"嘟嘟嘟 %@",dictionary);
    
    if ([dictionary[@"cmdType"] integerValue] == 2) {
        //模组已经收到WiFi路由器的SSID/PSW，正在进行连接。这个时候app/小程序需要等待3秒钟，然后发送时间戳信息给模组
        if (![NSObject isNullOrNilWithObject:dictionary[@"deviceReply"]]) {
            if ([dictionary[@"deviceReply"] isEqualToString:@"dataRecived"]) {
                
                dispatch_source_cancel(self.timer);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    self.timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
                    dispatch_source_set_timer(self.timer2, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
                    dispatch_source_set_event_handler(self.timer2, ^{
                        
                        if (self.sendCount2 >= 3) {
                            dispatch_source_cancel(self.timer2);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self connectFaild];
                            });
                            return ;
                        }
                        
                        [sock sendData:[NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"timestamp":@((long)[[NSDate date] timeIntervalSince1970])} options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
                        
                        self.sendCount2 ++;
                    });
                    dispatch_resume(self.timer2);
                    
                });
            }
            
            return;
        }
        
        
        if (![NSObject isNullOrNilWithObject:dictionary[@"signature"]] && [@"connected" isEqualToString:dictionary[@"wifiState"]]) {
            dispatch_source_cancel(self.timer2);
            
            
            if (@available(iOS 11.0, *)) {
                NEHotspotConfiguration *config = [[NEHotspotConfiguration alloc] initWithSSID:self.wifiInfo[@"name"] passphrase:self.wifiInfo[@"pwd"] isWEP:NO];
                [[NEHotspotConfigurationManager sharedManager] applyConfiguration:config completionHandler:^(NSError * _Nullable error) {
                    [self bindDevice:dictionary];
                }];
            } else {
                //ios 10切换WiFi
                
                UIButton *tryAgainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [tryAgainBtn setTitle:[NSString stringWithFormat:@"已将WiFi切换为'%@'",self.wifiInfo[@"name"]] forState:UIControlStateNormal];
                [tryAgainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                tryAgainBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
                [tryAgainBtn addTarget:self action:@selector(toBind) forControlEvents:UIControlEventTouchUpInside];
                tryAgainBtn.backgroundColor = kMainColor;
                tryAgainBtn.layer.cornerRadius = 3;
                [self.view addSubview:tryAgainBtn];
                [tryAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.view).offset(30);
                    make.top.equalTo(self.progressLab.mas_bottom).offset(149 * kScreenAllHeightScale);
                    make.width.mas_equalTo(kScreenWidth - 60);
                    make.height.mas_equalTo(48);
                    make.bottom.equalTo(self.contentView).offset(-30);
                }];
                
                // Fallback on earlier versions
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"请将手机WiFi切换为'%@'",self.wifiInfo[@"name"]] message:@"" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self connectFaild];
                }];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([[UIApplication sharedApplication] canOpenURL:url]){
                        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                    }
                }];
                [alert addAction:action];
                [alert addAction:action2];
                [self presentViewController:alert animated:NO completion:^{
                    
                }];
            }
            
        }
        else
        {
            [self connectFaild];
        }
        
    }
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

#pragma mark - UI

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
    
    self.pan = [[CHDWaveView alloc] initWithFrame: CGRectMake(0, 64, kScreenWidth, 220)];
    self.pan.backgroundColor = kRGBColor(204, 204, 204);
    self.pan.progress = 0;
    self.pan.speed = 0.8;
    [self.contentView addSubview:self.pan];
    
    
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self progress];
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
    
    self.progressLab = [[UILabel alloc] init];
    self.progressLab.text = @"连接中";
    self.progressLab.textColor = kRGBColor(51, 51, 51);
    self.progressLab.font = [UIFont wcPfSemiboldFontOfSize:24];
    [self.contentView addSubview:self.progressLab];
    [self.progressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.pan.mas_bottom).offset(40);
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
//    [self.pan sucess];
    self.pan.progress = 1;
    
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self releaseAlloc];
        self.tipLab.hidden = YES;
        self.progressLab.text = @"连接失败";
//        [self.pan faild];
        self.pan.progress = 0;
        
        UILabel *errorResultLab = [[UILabel alloc] init];
        errorResultLab.numberOfLines = 0;
        errorResultLab.textColor = kRGBColor(153, 153, 153);
        errorResultLab.font = [UIFont wcPfRegularFontOfSize:14];
        errorResultLab.text = @"1、检查设备是否通电，并按照指引进入配网模式\n2、检查WIFI是否正常（暂时只支持2.4G路由器）\n3、检查WIFI密码是否错误";
        errorResultLab.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:errorResultLab];
        [errorResultLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(30);
            make.right.equalTo(self.contentView).offset(-30);
            make.top.equalTo(self.progressLab.mas_bottom).offset(10);
        }];
        
        UIButton *moreResultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreResultBtn setTitle:@"查看更多失败原因" forState:UIControlStateNormal];
        [moreResultBtn addTarget:self action:@selector(moreErrorResult:) forControlEvents:UIControlEventTouchUpInside];
        moreResultBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [moreResultBtn setTitleColor:kRGBColor(235, 61, 61) forState:UIControlStateNormal];
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
    });
}

- (void)releaseAlloc{
    self.timer = nil;
    self.timer2 = nil;
    
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [self.socket close];
    self.socket = nil;
}

#pragma mark - event

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
    [self dismissViewControllerAnimated:YES completion:nil];
//    for (UIViewController * controller in self.navigationController.viewControllers) {
//        if ([controller isKindOfClass:[WCDistributionNetworkViewController class]]) {
//            [self.navigationController popToViewController:controller animated:YES];
//        }
//    }
}

- (void)moreErrorResult:(id)sender{
    
}

- (void)backHome:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    [HXYNotice addUpdateDeviceListPost];
}

- (void)toBind
{
    [self bindDevice:self.signInfo];
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
@end
