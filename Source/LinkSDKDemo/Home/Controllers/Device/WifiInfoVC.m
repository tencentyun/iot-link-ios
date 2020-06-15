//
//  WifiInfoVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/9.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "WifiInfoVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>

#import <QCDeviceCenter/QCAddDevice.h>


@interface WifiInfoVC ()<CLLocationManagerDelegate,QCAddDeviceDelegate>
@property (weak, nonatomic) IBOutlet UITextField *SSID;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *bssid;
@property (weak, nonatomic) IBOutlet UILabel *res;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *wifiInfo;

@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (nonatomic,strong) QCSmartConfig *sc;
@end

@implementation WifiInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getWifiInfos];
    
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
        [self.wifiInfo setDictionary:[self getWifiSsid]];
        self.SSID.text = self.wifiInfo[@"name"];
        self.bssid.text = self.wifiInfo[@"bssid"];
    }
}

- (NSDictionary *)getWifiSsid{
    
    NSDictionary *wifiDic;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
    
            wifiDic = @{@"name":[networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID],@"bssid":[networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeyBSSID]};
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiDic;
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

#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.wifiInfo removeAllObjects];
        [self.wifiInfo setDictionary:[self getWifiSsid]];
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

- (void)onResult:(QCResult *)result
{
    self.startBtn.enabled = YES;
    if (result.code == 0) {
        
        self.res.text = @"开始绑定";
        NSString *familyId = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstFamilyId"];
        [[QCDeviceSet shared] bindDeviceWithSignatureInfo:result.signatureInfo inFamilyId:familyId roomId:nil success:^(id  _Nonnull responseObject) {
            self.res.text = @"成功";
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
            self.res.text = reason;
        }];
    }
    else
    {
        self.res.text = result.errMsg;
    }
}


- (IBAction)next:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:@"开始配网1"]) {
        
        NSAssert(self.wifiInfo[@"name"] && self.wifiInfo[@"bssid"] && self.password.hasText, @"未获取到必要参数");
        
        sender.enabled = NO;
        
        self.sc = [[QCSmartConfig alloc] initWithSSID:self.wifiInfo[@"name"] PWD:self.password.text BSSID:self.wifiInfo[@"bssid"]];
        _sc.delegate = self;
        [_sc startAddDevice];
        
    }
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.wifiInfo[@"name"] && self.password.hasText) {
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
    [vc setValue:self.wifiInfo[@"name"] forKey:@"wName"];
    [vc setValue:self.password.text forKey:@"wPassword"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
