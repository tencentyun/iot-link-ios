//
//  TIoTStartConfigViewController.m
//  LinkApp
//
//  Created by Sun on 2020/7/30.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTStartConfigViewController.h"
#import "TIoTStepTipView.h"
#import "TIoTConnectStepTipView.h"
#import "TIoTConfigResultViewController.h"

//----------------------- soft ap-------------------------
#import "TIoTCoreAddDevice.h"
#import "GCDAsyncUdpSocket.h"

@interface TIoTStartConfigViewController () <TIoTCoreAddDeviceDelegate>

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@property (nonatomic, strong) TIoTConnectStepTipView *connectStepTipView;

@property (nonatomic, strong) NSDictionary *dataDic;

//----------------------- soft ap-------------------------
@property (nonatomic, strong) TIoTCoreSoftAP   *softAP;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic) NSUInteger sendCount;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic) NSUInteger sendCount2;

@property (nonatomic,strong) NSDictionary *signInfo;//签名信息
@property (nonatomic, assign) BOOL isTokenbindedStatus;

//----------------------- smart config-------------------------
@property (nonatomic, strong) TIoTCoreSmartConfig   *smartConfig;

@end

@implementation TIoTStartConfigViewController

- (void)dealloc {
    [self releaseAlloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self performSelector:@selector(clock4Timer:) withObject:@(1) afterDelay:3.0f];
}

- (void)setupUI{
    self.title = [_dataDic objectForKey:@"title"];;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.stepTipView = [[TIoTStepTipView alloc] initWithTitlesArray:[_dataDic objectForKey:@"stepTipArr"]];
    self.stepTipView.step = 3;
    [self.view addSubview:self.stepTipView];
    [self.stepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20 + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(54);
    }];
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"new_distri_connect"];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stepTipView.mas_bottom).offset(103*kScreenAllHeightScale);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(203);
        make.height.mas_equalTo(100);
    }];
    
    self.connectStepTipView = [[TIoTConnectStepTipView alloc] initWithTitlesArray:[_dataDic objectForKey:@"connectStepTipArr"]];
    [self.view addSubview:self.connectStepTipView];
    [self.connectStepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(50);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(166);
        make.height.mas_equalTo(114);
    }];
}

- (void)clock4Timer:(NSNumber *)count {
    if (count.intValue > 4) {
        return;
    } else {
        self.connectStepTipView.step = count.intValue;
        [self performSelector:@selector(clock4Timer:) withObject:@(count.intValue+1) afterDelay:3.0f];
    }
}

#pragma mark SoftAp config

- (void)createSoftAPWith:(NSString *)ip {

    NSString *apSsid = self.wifiInfo[@"name"];
    NSString *apPwd = self.wifiInfo[@"pwd"];
    
    self.softAP = [[TIoTCoreSoftAP alloc] initWithSSID:apSsid PWD:apPwd];
    self.softAP.delegate = self;
    self.softAP.gatewayIpString = ip;
    __weak __typeof(self)weakSelf = self;
    self.softAP.udpFaildBlock = ^{
        [weakSelf connectFaild];
    };
    [self.softAP startAddDevice];
}

//token 2秒轮询查看设备状态
- (void)checkTokenStateWithCirculationWithDeviceData:(NSDictionary *)data {
    dispatch_source_cancel(self.timer);
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
    [[TIoTRequestObject shared] post:AppGetDeviceBindTokenState Param:@{@"Token":self.wifiInfo[@"token"]} success:^(id responseObject) {
        //State:Uint Token 状态，1：初始生产，2：可使用状态
        WCLog(@"AppGetDeviceBindTokenState---responseobject=%@",responseObject);
        if ([responseObject[@"State"] isEqual:@(1)]) {
            self.isTokenbindedStatus = NO;
        }else if ([responseObject[@"State"] isEqual:@(2)]) {
            self.isTokenbindedStatus = YES;
            [self bindingDevidesWithData:deviceData];
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        WCLog(@"AppGetDeviceBindTokenState---reason=%@---error=%@",reason,error);
        
    }];
}

//获取签名，绑定设备
- (void)bindDevice:(NSDictionary *)deviceData{
    
    if (self.connectStepTipView.step < 3) {
        self.connectStepTipView.step = 3;
    }
    if (![NSObject isNullOrNilWithObject:deviceData[@"productId"]]) {

        [[TIoTRequestObject shared] post:AppSigBindDeviceInFamily Param:@{@"ProductId":deviceData[@"productId"],@"DeviceName":deviceData[@"deviceName"],@"TimeStamp":deviceData[@"timestamp"],@"ConnId":deviceData[@"connId"],@"Signature":deviceData[@"signature"],@"DeviceTimestamp":deviceData[@"timestamp"],@"FamilyId":[TIoTCoreUserManage shared].familyId} success:^(id responseObject) {
            [self connectSucess:deviceData];
            [HXYNotice addUpdateDeviceListPost];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [self connectFaild];
        }];
    }
    else
    {
        [self connectFaild];
    }
}

//判断token返回后（设备状态为2），绑定设备
- (void)bindingDevidesWithData:(NSDictionary *)deviceData {
    if (![NSObject isNullOrNilWithObject:deviceData[@"productId"]]) {
        NSString *roomId = self.roomId ?: @"0";
        [[TIoTRequestObject shared] post:AppTokenBindDeviceFamily Param:@{@"ProductId":deviceData[@"productId"],@"DeviceName":deviceData[@"deviceName"],@"Token":self.wifiInfo[@"token"],@"FamilyId":[TIoTCoreUserManage shared].familyId,@"RoomId":roomId} success:^(id responseObject) {
            [self connectSucess:deviceData];
            [HXYNotice addUpdateDeviceListPost];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [self connectFaild];
        }];
    }else {
        [self connectFaild];
    }

}

- (void)releaseAlloc{
    self.timer = nil;
    self.timer2 = nil;
}

#pragma mark SmartConfig

- (void)tapConfirm{

    [self createSmartConfig];
    __weak __typeof(self)weakSelf = self;
    self.smartConfig.updConnectBlock = ^(NSString * _Nonnull ipaAddrData) {
        [weakSelf createSoftAPWith:ipaAddrData];
    };
    self.smartConfig.connectFaildBlock = ^{
        [weakSelf connectFaild];
    };
    [self.smartConfig startAddDevice];
}

- (void)createSmartConfig {
    NSString *apSsid = self.wifiInfo[@"name"];
    NSString *apPwd = self.wifiInfo[@"pwd"];
    NSString *apBssid = self.wifiInfo[@"bssid"];

    self.smartConfig = [[TIoTCoreSmartConfig alloc]initWithSSID:apSsid PWD:apPwd BSSID:apBssid];
    self.smartConfig.delegate = self;
}

#pragma mark TIoTCoreAddDeviceDelegate 代理方法 (与TCSocketDelegate一一对应)

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    WCLog(@"连接成功");
    
    //设备收到WiFi的ssid/pwd/token，正在上报，此时2秒内，客户端没有收到设备回复，如果重复发送5次，都没有收到回复，则认为配网失败，Wi-Fi 设备有异常
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        
        if (self.sendCount >= 5) {
            dispatch_source_cancel(self.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
               [self connectFaild];
            });
            return ;
        }
        
        NSString *Ssid = self.wifiInfo[@"name"];
        NSString *Pwd = self.wifiInfo[@"pwd"];
        NSString *Token = self.wifiInfo[@"token"];
        [sock sendData:[NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(1),@"ssid":Ssid,@"password":Pwd,@"token":Token} options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
        self.sendCount ++;
    });
    dispatch_resume(self.timer);
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    WCLog(@"发送成功");
    //手机与设备连接成功,收到设备的udp数据
    if (self.connectStepTipView.step < 1) {
        self.connectStepTipView.step = 1;
    }
}

- (void)softApuUdpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    WCLog(@"发送失败 %@", error);
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];
    self.signInfo = dictionary;
    WCLog(@"嘟嘟嘟 %@",dictionary);
    //手机与设备连接成功,收到设备的udp数据
    if (self.connectStepTipView.step < 2) {
        self.connectStepTipView.step = 2;
    }
    
    if ([dictionary[@"cmdType"] integerValue] == 2) {
        //设备已经收到WiFi的ssid/psw/token，正在进行连接WiFi并上报，此时客户端根据token 2秒轮询一次（总时长100s）检测设备状态,然后在绑定设备。
        //如果deviceReply返回的是Current_Error，则配网绑定过程中失败，需要退出配网操作;Previous_Error则为上一次配网的出错日志，只需要上报，不影响当此操作。
        if (![NSObject isNullOrNilWithObject:dictionary[@"deviceReply"]])  {
            if ([dictionary[@"deviceReply"] isEqualToString:@"Previous_Error"]) {
                [self checkTokenStateWithCirculationWithDeviceData:dictionary];
            }else {
                //deviceReplay 为 Cuttent_Error
                WCLog(@"soft配网过程中失败，需要重新配网");
                [self connectFaild];
            }
            
        }else {
            WCLog(@"dictionary==%@----soft链路设备success",dictionary);
            [self checkTokenStateWithCirculationWithDeviceData:dictionary];
        }
        
    }
}

#pragma mark private Method

- (void)connectFaild {
    TIoTConfigResultViewController *vc = [[TIoTConfigResultViewController alloc] initWithConfigHardwareStyle:self.configHardwareStyle success:NO];
    [self.navigationController pushViewController:vc animated:YES];
}
//配网成功
- (void)connectSucess:(NSDictionary *)devieceData{
    TIoTConfigResultViewController *vc = [[TIoTConfigResultViewController alloc] initWithConfigHardwareStyle:self.configHardwareStyle success:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark setter or getter

- (void)setConfigHardwareStyle:(TIoTConfigHardwareStyle)configHardwareStyle {
    _configHardwareStyle = configHardwareStyle;
    switch (configHardwareStyle) {
        case TIoTConfigHardwareStyleSoftAP:
        {
            _dataDic = @{@"title": @"热点配网",
                         @"stepTipArr": @[@"配置硬件", @"设置目标WiFi", @"连接设备", @"开始配网"],
                         @"connectStepTipArr": @[@"手机与设备连接成功", @"向设备发送信息成功", @"设备连接云端成功", @"初始化成功"]
            };
            [self setupUI];
            [self createSoftAPWith:[NSString getGateway]];
        }
            break;
            
        case TIoTConfigHardwareStyleSmartConfig:
        {
            _dataDic = @{@"title": @"一键配网",
                         @"stepTipArr": @[@"配置硬件", @"选择目标WiFi", @"开始配网"],
                         @"connectStepTipArr": @[@"手机与设备连接成功", @"向设备发送信息成功", @"设备连接云端成功", @"初始化成功"]
            };
            [self setupUI];
            [self tapConfirm];
        }
            break;
            
        default:
            break;
    }
}

@end
