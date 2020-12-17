//
//  TIoTVideoConfigNetVC.m
//  TIoTLinkKitDemo
//
//  Created by ccharlesren on 2020/12/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTVideoConfigNetVC.h"
#import "UILabel+TIoTExtension.h"
#import <CoreLocation/CoreLocation.h>
#import "TIoTCoreUtil.h"
#import "TIoTCoreRequestObject.h"
#import "NSObject+additions.h"
#import "TIoTCoreRequestAction.h"
#import "UIColor+Color.h"
#import "NSString+Extension.h"
//#import "TIoTVideoDistributionNetModel.h"

@interface TIoTVideoConfigNetVC ()<CLLocationManagerDelegate,UITextFieldDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *wifiInfo;
@property (nonatomic, strong) UILabel *wifiName;
@property (nonatomic, strong) UITextField *wifiPassword;
@property (nonatomic, strong) UILabel *bssid;
@property (nonatomic, strong) UIImageView *qrImageView;
@end

@implementation TIoTVideoConfigNetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self setupUIViews];
    
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
        self.wifiName.text = self.wifiInfo[@"name"];
        self.bssid.text = self.wifiInfo[@"bssid"];
        [self.view reloadInputViews];
    }
}

- (void)applicationwillenterforegound
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self.wifiInfo removeAllObjects];
            [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
            self.wifiName.text = self.wifiInfo[@"name"];
            self.bssid.text = self.wifiInfo[@"bssid"];
            [self.view reloadInputViews];
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
    });
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.wifiInfo removeAllObjects];
        [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
        self.wifiName.text = self.wifiInfo[@"name"];
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

#pragma mark - private mathod
- (void)getSoftApAndSmartConfigToken {
}

- (void)setupUIViews {
    
    CGFloat kTopPadding = 40 + kNavBarAndStatusBarHeight;
    CGFloat kLeftPadding = 30;
    CGFloat kWidth = kScreenWidth - kLeftPadding*2;
    CGFloat kHeight = 40;
    CGFloat kInterval = 10;
    
    self.wifiName = [[UILabel alloc]initWithFrame:CGRectMake(kLeftPadding, kTopPadding, kWidth,kHeight)];
    [self setLabelFormateTitle:@"name" font:[UIFont systemFontOfSize:18] titleColorHexString:kMainThemeColor textAlignment:NSTextAlignmentCenter label:self.wifiName];
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
    
    UIButton *generateQRcode = [UIButton buttonWithType:UIButtonTypeCustom];
    generateQRcode.frame = CGRectMake(kLeftPadding, CGRectGetMaxY(self.bssid.frame)+kInterval, kWidth, kHeight);
    [generateQRcode setTitle:@"生成二维码" forState:UIControlStateNormal];
    [generateQRcode setTitleColor:[UIColor colorWithHexString:kMainThemeColor] forState:UIControlStateNormal];
    generateQRcode.titleLabel.font = [UIFont systemFontOfSize:18];
    [generateQRcode addTarget:self action:@selector(generateQRImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:generateQRcode];
    
    CGFloat kWidthHeight = 200;
    self.qrImageView = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth - kWidthHeight)/2, CGRectGetMaxY(generateQRcode.frame)+kInterval, kWidthHeight, kWidthHeight)];
    [self.view addSubview:self.qrImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - event

- (void)generateQRImage {
    
    TIoTVideoDistributionNetModel *model = [[TIoTVideoDistributionNetModel alloc]init];
    model.bssid = self.wifiInfo[@"bssid"]?:@"";
    model.name = self.wifiInfo[@"name"]?:@"";
    model.pwd = self.wifiPassword.text?:@"";
#warning token 需通过自建服务器获取
    model.token = @"TestNetworkToken";
    
    UIImage *qrimage = [TIoTCoreUtil qrCodeScanDistributionNetWorkWithInfo:model imageSize:CGSizeMake(200, 200)];
    self.qrImageView.image = qrimage;
    [self.view reloadInputViews];

}

- (void)hideKeyBoard {
    [self.wifiPassword resignFirstResponder];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.wifiPassword resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.wifiPassword resignFirstResponder];
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
