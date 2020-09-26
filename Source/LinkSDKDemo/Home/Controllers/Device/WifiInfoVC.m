//
//  WifiInfoVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/9.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "WifiInfoVC.h"
#import "TIoTCoreUtil.h"
#import <CoreLocation/CoreLocation.h>

#import "TIoTCoreAddDevice.h"

#import "TIoTCoreRequestObject.h"
#import "NSObject+additions.h"
#import "TIoTCoreRequestAction.h"
#import "GCDAsyncUdpSocket.h"
#import "TIoTCoreUserManage.h"

@interface WifiInfoVC ()<CLLocationManagerDelegate,TIoTCoreAddDeviceDelegate,GCDAsyncUdpSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *SSID;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *bssid;
@property (weak, nonatomic) IBOutlet UILabel *res;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *wifiInfo;

@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (nonatomic,strong) TIoTCoreSmartConfig *sc;
@property (nonatomic, strong) TIoTCoreSoftAP *softAp;
@property (nonatomic, strong) dispatch_source_t tokenTimer;
@property (nonatomic) NSUInteger sendTokenCount;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic) NSUInteger sendCount2;
@property (nonatomic, assign) BOOL isTokenbindedStatus;
@property (nonatomic, copy) NSString *networkToken;

@end

@implementation WifiInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getWifiInfos];
    [self getSoftApAndSmartConfigToken];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationwillenterforegound) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)getWifiInfos
{
    float version = [[UIDevice currentDevice].systemVersion floatValue];
    if (version >= 13) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    else
    {
        [self.wifiInfo removeAllObjects];
        [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
        self.SSID.text = self.wifiInfo[@"name"];
        self.bssid.text = self.wifiInfo[@"bssid"];
    }
}

- (void)applicationwillenterforegound
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self.wifiInfo removeAllObjects];
            [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
            self.SSID.text = self.wifiInfo[@"name"];
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
    });
}

#pragma mark -

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (NSMutableDictionary *)wifiInfo{
    if (_wifiInfo == nil) {
        _wifiInfo = [NSMutableDictionary dictionary];
    }
    return _wifiInfo;
}

- (void)connectFaildResult:(NSString *)message {
    TIoTCoreResult *result = [TIoTCoreResult new];
    result.code = 6000;
    result.errMsg = message;
    [self onResult:result];
}

- (void)compareSuccessResult {
    TIoTCoreResult *result = [TIoTCoreResult new];
    result.code = 0;
    [self onResult:result];
}

#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.wifiInfo removeAllObjects];
        [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
        self.SSID.text = self.wifiInfo[@"name"];
        self.bssid.text = self.wifiInfo[@"bssid"];
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        [manager requestWhenInUseAuthorization];
    }
    else
    {
        
    }
}

#pragma mark - QCAddDeviceDelegate

/// 可选实现
/// @param result 返回的调用结果
- (void)onResult:(TIoTCoreResult *)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.startBtn.enabled = YES;
        [MBProgressHUD dismissInView:nil];
        [self releaseAlloc];
        if (result.code == 0) {
            
            self.res.text = @"开始绑定";
            self.res.text = @"成功";
        }
        else
        {
            self.res.text = result.errMsg;
        }
        
    });
}

- (IBAction)next:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:@"开始配网1"]) {
        
        NSAssert(self.wifiInfo[@"name"] && self.wifiInfo[@"bssid"] && self.password.hasText, @"未获取到必要参数");
        
        sender.enabled = NO;
        
//        self.sc = [[TIoTCoreSmartConfig alloc] initWithSSID:self.wifiInfo[@"name"] PWD:self.password.text BSSID:self.wifiInfo[@"bssid"]];
        
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@"配网中"];
        self.sc = [[TIoTCoreSmartConfig alloc] initWithSSID:self.SSID.text PWD:self.password.text BSSID:self.wifiInfo[@"bssid"]];
        _sc.delegate = self;
        __weak __typeof(self)weakSelf = self;
        self.sc.updConnectBlock = ^(NSString * _Nonnull ipaAddrData) {
            [weakSelf createSoftAPWith:ipaAddrData];
            
        };
        self.sc.connectFaildBlock = ^{
            [weakSelf connectFaildResult:NSLocalizedString(@"connect_fail", @"连接失败")];
        };
        [_sc startAddDevice];
        
    }
    
}

- (void)createSoftAPWith:(NSString *)ip {

    NSString *apSsid = self.SSID.text;
    NSString *apPwd = self.password.text;
    
    self.softAp = [[TIoTCoreSoftAP alloc]initWithSSID:apSsid PWD:apPwd];
    self.softAp.delegate = self;
    self.softAp.gatewayIpString = ip;
    __weak __typeof(self)weakSelf = self;
    self.softAp.udpFaildBlock = ^{
        [weakSelf connectFaildResult:[NSString stringWithFormat:@"udp%@",NSLocalizedString(@"connect_fail", @"连接失败")]];
    };
    [self.softAp startAddDevice];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    //修改
    if (self.SSID.text && self.password.hasText) {
            return YES;
        }
        else
        {
            [MBProgressHUD showMessage:@"未获取到必要参数" icon:nil];
        }
        return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *vc = segue.destinationViewController;
    //修改
    [vc setValue:self.SSID.text forKey:@"wName"];
//    [vc setValue:self.wifiInfo[@"name"] forKey:@"wName"];
    [vc setValue:self.password.text forKey:@"wPassword"];
    [vc setValue:self.networkToken forKey:@"wToken"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - private mathod
- (void)getSoftApAndSmartConfigToken {
    
    [[TIoTCoreRequestObject shared] post:AppCreateDeviceBindToken Param:@{} success:^(id responseObject) {

        NSLog(@"AppCreateDeviceBindToken----responseObject==%@",responseObject);
        
        if (![NSObject isNullOrNilWithObject:responseObject[@"Token"]]) {
            self.networkToken = responseObject[@"Token"];
        }
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

        NSLog(@"AppCreateDeviceBindToken--reason==%@--error=%@",reason,reason);
    }];
}

#pragma mark - TIoTCoreAddDeviceDelegate 代理方法 (与TCSocketDelegate一一对应)
- (void)smartConfigOnHandleSocketOpen:(TCSocket *)socket {
     NSLog(@"%@ did open",socket);
}

- (void)smartConfigOnHandleSocketClosed:(TCSocket *)socket {
    NSLog(@"%@ did close",socket);
}

- (void)smartConfigOnHandleDataReceived:(TCSocket *)socket data:(NSData *)data {
    NSLog(@"%@ did receive data %@",socket,data);
    [self receivedSmartConfigSockedDataWithData:data];
}

- (void)receivedSmartConfigSockedDataWithData:(NSData *)data {
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (JSONParsingError != nil) {
            [self connectFaildResult:@"json解析错误"];
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
                        NSLog(@"smaartConfig配网过程中失败，需要重新配网");
                        [self connectFaildResult:@"模组有问题"];
                    }
                    
                }else {
                    NSLog(@"dictionary==%@----smaartConfig链路设备success",dictionary);
                    [self checkTokenStateWithCirculationWithDeviceData:dictionary];
                }
                
            }
        }
    });
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"连接成功");
        
        //设备收到WiFi的ssid/pwd/token，正在上报，此时2秒内，客户端没有收到设备回复，如果重复发送5次，都没有收到回复，则认为配网失败，Wi-Fi 设备有异常
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.tokenTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.tokenTimer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.tokenTimer, ^{
            
            if (self.sendTokenCount >= 5) {
                dispatch_source_cancel(self.tokenTimer);
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self connectFaildResult:@"模组有问题"];
                });
                return ;
            }
            
    //        [socket sendData: [NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"token":self.wifiInfo[@"token"]} options:NSJSONWritingPrettyPrinted error:nil]];
            
            [sock sendData:[NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"token":self.networkToken} options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
            self.sendTokenCount ++;
        });
        dispatch_resume(self.tokenTimer);

}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"发送成功");
}

- (void)softApuUdpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"发送失败 %@", error);
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];
    NSLog(@"嘟嘟嘟 %@",dictionary);
    
    if ([dictionary[@"cmdType"] integerValue] == 2) {
        //设备已经收到WiFi的ssid/psw/token，正在进行连接WiFi并上报，此时客户端根据token 2秒轮询一次（总时长100s）检测设备状态,然后在绑定设备。
        //如果deviceReply返回的是Current_Error，则配网绑定过程中失败，需要退出配网操作;Previous_Error则为上一次配网的出错日志，只需要上报，不影响当此操作。
        if (![NSObject isNullOrNilWithObject:dictionary[@"deviceReply"]])  {
            if ([dictionary[@"deviceReply"] isEqualToString:@"Previous_Error"]) {
                [self checkTokenStateWithCirculationWithDeviceData:dictionary];
            }else {
                //deviceReplay 为 Cuttent_Error
                NSLog(@"soft配网过程中失败，需要重新配网");
                [self connectFaildResult:@"模组有问题"];
            }
            
        }else {
            NSLog(@"dictionary==%@----soft链路设备success",dictionary);
            [self checkTokenStateWithCirculationWithDeviceData:dictionary];
        }
        
    }

}

//token 2秒轮询查看设备状态
- (void)checkTokenStateWithCirculationWithDeviceData:(NSDictionary *)data {
    if (self.tokenTimer) {
        dispatch_source_cancel(self.tokenTimer);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.timer2, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer2, ^{

            if (self.sendCount2 >= 100) {
                dispatch_source_cancel(self.timer2);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self connectFaildResult:@"模组有问题"];
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
    [[TIoTCoreRequestObject shared] post:AppGetDeviceBindTokenState Param:@{@"Token":self.networkToken} success:^(id responseObject) {
        //State:Uint Token 状态，1：初始生产，2：可使用状态
        NSLog(@"AppGetDeviceBindTokenState---responseobject=%@",responseObject);
        if ([responseObject[@"State"] isEqual:@(1)]) {
            self.isTokenbindedStatus = NO;
        }else if ([responseObject[@"State"] isEqual:@(2)]) {
            self.isTokenbindedStatus = YES;
            [self bindingDevidesWithData:deviceData];
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        NSLog(@"AppGetDeviceBindTokenState---reason=%@---error=%@",reason,error);
        
    }];
}

//判断token返回后（设备状态为2），绑定设备
- (void)bindingDevidesWithData:(NSDictionary *)deviceData {
    if (![NSObject isNullOrNilWithObject:deviceData[@"productId"]]) {
        NSString *roomId = @"0";
        [[TIoTCoreRequestObject shared] post:AppTokenBindDeviceFamily Param:@{@"ProductId":deviceData[@"productId"],@"DeviceName":deviceData[@"deviceName"],@"Token":self.networkToken,@"FamilyId":[TIoTCoreUserManage shared].familyId ? [TIoTCoreUserManage shared].familyId:@"",@"RoomId":roomId} success:^(id responseObject) {

            [self compareSuccessResult];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [self connectFaildResult:@"绑定设备失败"];
        }];
    }else {
        [self connectFaildResult:@"绑定设备失败"];
    }

}

- (void)releaseAlloc{
    self.tokenTimer = nil;
    self.timer2 = nil;
}

@end
