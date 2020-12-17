//
//  TIoTVideoSoftApDistributionNetVC.m
//  TIoTLinkKitDemo
//
//  Created by ccharlesren on 2020/12/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTVideoSoftApDistributionNetVC.h"
#import "UILabel+TIoTExtension.h"
#import <CoreLocation/CoreLocation.h>
#import "TIoTCoreUtil.h"
#import "TIoTCoreRequestObject.h"
#import "NSObject+additions.h"
#import "TIoTCoreRequestAction.h"
#import "UIColor+Color.h"
#import "NSString+Extension.h"

#import "TIoTCoreAddDevice.h"
#import "GCDAsyncUdpSocket.h"

@interface TIoTVideoSoftApDistributionNetVC ()<CLLocationManagerDelegate,UITextFieldDelegate,TIoTCoreAddDeviceDelegate>
@property (nonatomic, strong) TIoTCoreSoftAP   *softAP;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic) NSUInteger sendCount;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic) NSUInteger sendCount2;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *wifiInfo;
@property (nonatomic, strong) UITextField *wifiName;
@property (nonatomic, strong) UITextField *wifiPassword;
@property (nonatomic, strong) UILabel *bssid;

@property (nonatomic, strong) NSString *apSsid;
@property (nonatomic, strong) NSString *wifiNameString;
@property (nonatomic, strong) NSString *wifiPasswordString;
@end

@implementation TIoTVideoSoftApDistributionNetVC

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.softAP) {
        [self.softAP stopAddDevice];
    }
    [self releaseAlloc];
}

- (void)dealloc {
    [self releaseAlloc];
}

- (void)releaseAlloc{
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
    self.timer = nil;
    if (self.timer2) {
        dispatch_source_cancel(self.timer2);
    }
    self.timer2 = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    
    [self getWifiInfos];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationwillenterforegound) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat kTopPadding = 40 + kNavBarAndStatusBarHeight;
    CGFloat kLeftPadding = 30;
    CGFloat kWidth = kScreenWidth - kLeftPadding*2;
    CGFloat kHeight = 40;
    CGFloat kInterval = 10;
    
    self.wifiName = [[UITextField alloc]initWithFrame:CGRectMake(kLeftPadding, kTopPadding, kWidth,kHeight)];
    self.wifiName.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.wifiName.font = [UIFont systemFontOfSize:18];
    self.wifiName.placeholder = @"请输入WiFi名称";
    self.wifiName.textAlignment = NSTextAlignmentCenter;
    self.wifiName.returnKeyType = UIReturnKeyDone;
    self.wifiName.delegate = self;
    [self.view addSubview:self.wifiName];
    
    self.wifiPassword = [[UITextField alloc]initWithFrame:CGRectMake(kLeftPadding, CGRectGetMaxY(self.wifiName.frame)+kInterval, kWidth, kHeight)];
    self.wifiPassword.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.wifiPassword.font = [UIFont systemFontOfSize:18];
    self.wifiPassword.placeholder = @"请输入WiFi密码";
    self.wifiPassword.textAlignment = NSTextAlignmentCenter;
    self.wifiPassword.returnKeyType = UIReturnKeyDone;
    self.wifiPassword.delegate = self;
    [self.view addSubview:self.wifiPassword];
    
    self.bssid = [[UILabel alloc]initWithFrame:CGRectMake(kLeftPadding, CGRectGetMaxY(self.wifiPassword.frame)+kInterval, kWidth, kHeight)];
    [self setLabelFormateTitle:@"bssid" font:[UIFont systemFontOfSize:18] titleColorHexString:kMainThemeColor textAlignment:NSTextAlignmentCenter label:self.bssid];
    [self.view addSubview:self.bssid];
    
    UIButton *startApConfigBuuton = [UIButton buttonWithType:UIButtonTypeCustom];
    startApConfigBuuton.frame = CGRectMake(kLeftPadding, CGRectGetMaxY(self.bssid.frame)+kInterval, kWidth, kHeight);
    [startApConfigBuuton setTitle:@"开始Ap配网" forState:UIControlStateNormal];
    [startApConfigBuuton setTitleColor:[UIColor colorWithHexString:kMainThemeColor] forState:UIControlStateNormal];
    startApConfigBuuton.titleLabel.font = [UIFont systemFontOfSize:18];
    [startApConfigBuuton addTarget:self action:@selector(connectionApSocket) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startApConfigBuuton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
    [self.wifiName becomeFirstResponder];
    
    self.wifiNameString = @"";
    self.wifiPasswordString = @"";
}

- (void)getWifiInfos
{
    float version = [[UIDevice currentDevice].systemVersion floatValue];
    if (version >= 13) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    else
    {
        [self judgeLocationWithInit:YES];
    }
}

- (void)applicationwillenterforegound
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self judgeLocationWithInit:NO];
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
    });
}

- (void)judgeLocationWithInit:(BOOL)isInit {
    [self.wifiInfo removeAllObjects];
    [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
    if (isInit == YES) {
        self.wifiName.text = self.wifiInfo[@"name"];
        self.wifiNameString = self.wifiName.text;
    }else {
        self.wifiName.placeholder = self.wifiInfo[@"name"];
    }
    self.bssid.text = self.wifiInfo[@"bssid"];
    [self.view reloadInputViews];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self judgeLocationWithInit:NO];
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        [manager requestWhenInUseAuthorization];
    }
    else
    {
        
    }
}

#pragma mark TIoTCoreAddDeviceDelegate 代理方法 (与TCSocketDelegate一一对应)

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    WCLog(@"连接成功");
    [self connectFaildWith:@"连接成功，正在上报"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        
        if (self.sendCount >= 5) {
            dispatch_source_cancel(self.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD dismissInView:nil];
               [self connectFaildWith:@"链接设备失败"];
            });
            return ;
        }
        
        NSString *Ssid = self.apSsid;
        NSString *Pwd = self.wifiPasswordString;
#warning token 需通过自建服务器获取
        NSString *Token = @"TestNetworkToken";
        NSDictionary *dic = @{@"cmdType":@(1),@"ssid":Ssid,@"password":Pwd,@"token":Token,@"region":@"ap-guangzhou"};
        [sock sendData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
        self.sendCount ++;
    });
    dispatch_resume(self.timer);
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    WCLog(@"发送成功");
    //手机与设备连接成功,收到设备的udp数据
    [self connectFaildWith:@"发送成功"];
}

- (void)softApuUdpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    WCLog(@"发送失败 %@", error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD dismissInView:nil];
        [self connectFaildWith:@"发动失败"];
    });
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];
    WCLog(@"嘟嘟嘟 %@",dictionary);
    //手机与设备连接成功,收到设备的udp数据
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD dismissInView:nil];
        [self connectFaildWith:@"接收设备信息成功"];
    });
    
    
    if ([dictionary[@"cmdType"] integerValue] == 2) {
        //TODO:轮询设备状态进行绑定
        
    }
}

#pragma mark - event

- (void)connectionApSocket {
    [self hideKeyBoard];
    if (self.softAP) {
        [self.softAP stopAddDevice];
    }
    [self releaseAlloc];
    self.sendCount = 0;
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@"配网中"];
    
    self.apSsid = self.wifiInfo[@"name"];
    NSString *apPwd = self.wifiInfo[@"pwd"];
    
    if ([NSString isNullOrNilWithObject:self.wifiName.text] || [NSString isFullSpaceEmpty:self.wifiName.text]) {
        self.apSsid = self.wifiName.placeholder?:@"";
    }else {
        self.apSsid = self.wifiName.text?:@"";
    }
    
    self.softAP = [[TIoTCoreSoftAP alloc] initWithSSID:self.apSsid PWD:apPwd];
    self.softAP.delegate = self;
    self.softAP.gatewayIpString = [NSString getGateway];
    __weak __typeof(self)weakSelf = self;
    self.softAP.udpFaildBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf connectFaildWith:@"Socket链接失败"];
        });
    };
    [self.softAP startAddDevice];
}

- (void)connectFaildWith:(NSString *)test {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bssid.text = test;
        [self.view reloadInputViews];
    });
}

- (void)hideKeyBoard {
    [self.wifiPassword resignFirstResponder];
    [self.wifiName resignFirstResponder];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == self.wifiName) {
        self.wifiNameString = textField.text;
    }
    if (textField == self.wifiPassword) {
        self.wifiPasswordString = textField.text;
    }
    [self hideKeyBoard];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.wifiName) {
        self.wifiNameString = textField.text;
    }
    if (textField == self.wifiPassword) {
        self.wifiPasswordString = textField.text;
    }
    [self hideKeyBoard];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *inputString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSInteger kMaxLength = 10;
    NSString *toBeString = inputString;
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (toBeString.length > kMaxLength) {
                inputString = [toBeString substringToIndex:kMaxLength];
            }

        }
        else{//有高亮选择的字符串，则暂不对文字进行统计和限制

        }

    }else{//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > kMaxLength) {
            inputString = [toBeString substringToIndex:kMaxLength];
        }

    }
    
    if (textField == self.wifiName) {
        self.wifiNameString = inputString;
    }
    if (textField == self.wifiPassword) {
        self.wifiPasswordString = inputString;
    }
    return YES;
}

#pragma mark - lazy loading
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

- (void)setLabelFormateTitle:(NSString *)title font:(UIFont *)font titleColorHexString:(NSString *)titleColorString textAlignment:(NSTextAlignment)alignment label:(UILabel *)label {
    label.text = title;
    label.textColor = [UIColor colorWithHexString:titleColorString];
    label.font = font;
    label.textAlignment = alignment;
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
