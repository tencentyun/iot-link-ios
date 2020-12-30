//
//  TIoTWiredDistributionNetVC.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2020/12/30.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTWiredDistributionNetVC.h"
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

@interface TIoTWiredDistributionNetVC ()<CLLocationManagerDelegate,UITextFieldDelegate,TIoTCoreAddDeviceDelegate>
@property (nonatomic, strong) TIoTCoreSmartConfig   *smartConfig;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic) NSUInteger sendCount;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) UITextField *wifiName;
@property (nonatomic, strong) UITextField *wifiPassword;
@property (nonatomic, strong) UILabel *progressTip;
@property (nonatomic, strong) UITextField *port;

@property (nonatomic, strong) NSString *apSsid;
@property (nonatomic, strong) NSString *wifiNameString;
@property (nonatomic, strong) NSString *wifiPasswordString;
@property (nonatomic, strong) NSString *tokenString;
@property (nonatomic, strong) NSString *portString;
@end

@implementation TIoTWiredDistributionNetVC

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.smartConfig) {
        [self.smartConfig stopAddDevice];
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    [self initInformation];
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
    self.wifiName.placeholder = @"请输入DeviceName";
    self.wifiName.textAlignment = NSTextAlignmentCenter;
    self.wifiName.returnKeyType = UIReturnKeyDone;
    self.wifiName.delegate = self;
    [self.view addSubview:self.wifiName];
    
    self.wifiPassword = [[UITextField alloc]initWithFrame:CGRectMake(kLeftPadding, CGRectGetMaxY(self.wifiName.frame)+kInterval, kWidth, kHeight)];
    self.wifiPassword.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.wifiPassword.font = [UIFont systemFontOfSize:18];
    self.wifiPassword.placeholder = @"请输入ProductID";
    self.wifiPassword.textAlignment = NSTextAlignmentCenter;
    self.wifiPassword.returnKeyType = UIReturnKeyDone;
    self.wifiPassword.delegate = self;
    [self.view addSubview:self.wifiPassword];
    
    self.progressTip = [[UILabel alloc]initWithFrame:CGRectMake(kLeftPadding, CGRectGetMaxY(self.wifiPassword.frame)+kInterval, kWidth, kHeight)];
    [self setLabelFormateTitle:@"progressTip" font:[UIFont systemFontOfSize:18] titleColorHexString:kMainThemeColor textAlignment:NSTextAlignmentCenter label:self.progressTip];
    [self.view addSubview:self.progressTip];
    
    self.port =[[UITextField alloc]initWithFrame:CGRectMake(kLeftPadding, CGRectGetMaxY(self.progressTip.frame)+kInterval, kWidth, kHeight)];
    self.port.textColor = [UIColor colorWithHexString:kMainThemeColor];
    self.port.font = [UIFont systemFontOfSize:18];
    self.port.placeholder = @"请输入port";
    self.port.textAlignment = NSTextAlignmentCenter;
    self.port.returnKeyType = UIReturnKeyDone;
    self.port.delegate = self;
    [self.view addSubview:self.port];
    
    UIButton *startApConfigBuuton = [UIButton buttonWithType:UIButtonTypeCustom];
    startApConfigBuuton.frame = CGRectMake(kLeftPadding, CGRectGetMaxY(self.port.frame)+kInterval, kWidth, kHeight);
    [startApConfigBuuton setTitle:@"获取设备ID" forState:UIControlStateNormal];
    [startApConfigBuuton setTitleColor:[UIColor colorWithHexString:kMainThemeColor] forState:UIControlStateNormal];
    startApConfigBuuton.titleLabel.font = [UIFont systemFontOfSize:18];
    [startApConfigBuuton addTarget:self action:@selector(connectionApSocket) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startApConfigBuuton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
    [self.wifiName becomeFirstResponder];
    
    self.wifiNameString = @"";
    self.wifiPasswordString = @"";
    self.tokenString = @"";
    self.portString = @"8266";
}

- (void)initInformation {
    
    self.wifiName.text = @"";
    self.wifiNameString = self.wifiName.text;
    [self.view reloadInputViews];
}

#pragma mark TIoTCoreAddDeviceDelegate 代理方法 (与TCSocketDelegate一一对应)

- (void)smartConfigOnHandleSocketOpen:(TCSocket *)socket {
    [self connectFaildWith:@"打开成功"];
}

- (void)smartConfigOnHandleSocketClosed:(TCSocket *)socket {
    [self connectFaildWith:@"关闭成功"];
}

- (void)smartConfigOnHandleDataReceived:(TCSocket *)socket data:(NSData *)data {
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (JSONParsingError != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD dismissInView:nil];
                [self connectFaildWith:[NSString stringWithFormat:@"接收设备信息错误：%@",JSONParsingError]];
            });
        } else {

            if ([dictionary[@"cmdType"] integerValue] == 2) {
                //设备已经收到WiFi的ssid/psw/token，正在进行连接WiFi并上报，此时客户端根据token 2秒轮询一次（总时长100s）检测设备状态,然后在绑定设备。
                //如果deviceReply返回的是Current_Error，则配网绑定过程中失败，需要退出配网操作;Previous_Error则为上一次配网的出错日志，只需要上报，不影响当此操作。
                if (![NSObject isNullOrNilWithObject:dictionary[@"deviceReply"]])  {
                    if ([dictionary[@"deviceReply"] isEqualToString:@"Previous_Error"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD dismissInView:nil];
                            [self connectFaildWith:[NSString stringWithFormat:@"接收设备信息成功：%@",dictionary]];
                        });
                    }else {
                        //deviceReplay 为 Cuttent_Error
                        WCLog(@"smaartConfig配网过程中失败，需要重新配网");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MBProgressHUD dismissInView:nil];
                            [self connectFaildWith:@"接收设备信息失败"];
                        });
                    }
                    
                }else {
                    WCLog(@"dictionary==%@----smartConfig链路设备success",dictionary);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD dismissInView:nil];
                        [self connectFaildWith:[NSString stringWithFormat:@"接收设备信息成功：%@",dictionary]];
                    });
                }
                
            }
            
            if ([dictionary[@"cmdType"] integerValue] == 2) {
                //TODO:轮询设备状态进行绑定
                
            }
        }
    });
}

#pragma mark - event

- (void)connectionApSocket {
    [self hideKeyBoard];
    if (self.smartConfig) {
        [self.smartConfig stopAddDevice];
    }
    [self releaseAlloc];
    self.sendCount = 0;
    
    
    self.apSsid = @"";
    NSString *apPwd = self.wifiPassword.text?:@"";
    
    if ([NSString isNullOrNilWithObject:self.wifiName.text] || [NSString isFullSpaceEmpty:self.wifiName.text]) {
        self.apSsid = self.wifiName.placeholder?:@"";
    }else {
        self.apSsid = self.wifiName.text?:@"";
    }
    
    self.smartConfig = [[TIoTCoreSmartConfig alloc] initWithSSID:self.apSsid PWD:apPwd BSSID:@""];
    self.smartConfig.delegate = self;
    
    __weak __typeof(self)weakSelf = self;
    self.smartConfig.updConnectBlock = ^(NSString * _Nonnull ipaAddrData) {
//        [weakSelf createSoftAPWith:ipaAddrData];
    };
    self.smartConfig.connectFaildBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf connectFaildWith:@"Socket链接失败"];
        });
    };
    if ([self judgeIsNumberByRegularExpressionWith:self.portString]) {
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@"配网中"];
        [self.smartConfig startAddDevice];
    }else {
        [self connectFaildWith:@"port端口号非法"];
    }
}

- (BOOL)judgeIsNumberByRegularExpressionWith:(NSString *)str
{
   if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

- (void)connectFaildWith:(NSString *)test {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressTip.text = test;
        [self.view reloadInputViews];
    });
}

- (void)hideKeyBoard {
    [self.wifiPassword resignFirstResponder];
    [self.wifiName resignFirstResponder];
//    [self.token resignFirstResponder];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == self.wifiName) {
        self.wifiNameString = textField.text;
    }
    if (textField == self.wifiPassword) {
        self.wifiPasswordString = textField.text;
    }
    if (textField == self.port) {
        self.portString = textField.text;
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
    if (textField == self.port) {
        self.portString = textField.text;
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
    if (textField == self.port) {
        self.portString = textField.text;
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
