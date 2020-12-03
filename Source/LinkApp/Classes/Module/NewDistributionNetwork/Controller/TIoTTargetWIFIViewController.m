//
//  TIoTTargetWIFIViewController.m
//  LinkApp
//
//  Created by Sun on 2020/7/29.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTTargetWIFIViewController.h"
#import "TIoTStepTipView.h"
#import "TIoTConfigInputView.h"
#import "TIoTWIFIListView.h"

#import "TIoTCoreUtil.h" 
#import "TIoTWIFITipViewController.h"
#import "TIoTStartConfigViewController.h"
#import "TIoTDeviceWIFITipViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <NetworkExtension/NetworkExtension.h>

@interface TIoTTargetWIFIViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@property (nonatomic, strong) TIoTConfigInputView *wifiInputView;

@property (nonatomic, strong) TIoTConfigInputView *pwdInputView;

@property (nonatomic, strong) TIoTWIFIListView *wifiListView;

@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) UIImageView *tipImageView;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *wifiInfo;

@end

@implementation TIoTTargetWIFIViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupUI{
    self.title = [_dataDic objectForKey:@"title"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.stepTipView = [[TIoTStepTipView alloc] initWithTitlesArray:[_dataDic objectForKey:@"stepTipArr"]];
    self.stepTipView.step = self.step;
    [self.view addSubview:self.stepTipView];
    [self.stepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20 + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(54);
    }];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = kRGBColor(51, 51, 51);
    topicLabel.font = [UIFont wcPfMediumFontOfSize:17];
    topicLabel.text = (self.step == 3 ? NSLocalizedString(@"soft_ap_hotspot_set", @"将手机WiFi连接设备热点") : [_dataDic objectForKey:@"topic"]);
    [self.view addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.top.equalTo(self.stepTipView.mas_bottom).offset(20);
        make.height.mas_equalTo(24);
    }];
    
    self.wifiInputView = [[TIoTConfigInputView alloc] initWithTitle:[_dataDic objectForKey:@"wifiInputTitle"] placeholder:[_dataDic objectForKey:@"wifiInputPlaceholder"] haveButton:[[_dataDic objectForKey:@"wifiInputHaveButton"] boolValue]];
    WeakObj(self)
    self.wifiInputView.buttonAction = ^{
//        if (selfWeak.tipImageView) {
//            [selfWeak.tipImageView removeFromSuperview];
//        }

        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]){
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
//        selfWeak.wifiListView.hidden = NO;
//        [[UIApplication sharedApplication].keyWindow addSubview:selfWeak.wifiListView];
//        [selfWeak.wifiListView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo([UIApplication sharedApplication].keyWindow);
//        }];
    };
    [self.view addSubview:self.wifiInputView];
    [self.wifiInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topicLabel.mas_bottom).offset(20);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(56);
    }];
    
    if (self.configHardwareStyle == TIoTConfigHardwareStyleSoftAP && self.step == 3) {
//        UIImageView *imageView = [[UIImageView alloc] init];
//        imageView.image = [UIImage imageNamed:@"new_distri_rectangle"];
//        [self.view addSubview:imageView];
//        self.tipImageView = imageView;
//        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.wifiInputView.mas_top).offset(36);
//            make.right.equalTo(self.view);
//            make.width.mas_equalTo(224);
//            make.height.mas_equalTo(82);
//        }];
//        
//        UILabel *tipLabel = [[UILabel alloc] init];
//        tipLabel.textColor = [UIColor whiteColor];
//        tipLabel.font = [UIFont wcPfRegularFontOfSize:14];
//        tipLabel.text = @"点击这里选择热点";
//        [imageView addSubview:tipLabel];
//        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(imageView).offset(25);
//            make.centerX.equalTo(imageView);
//        }];
    }
    
    self.pwdInputView = [[TIoTConfigInputView alloc] initWithTitle:[_dataDic objectForKey:@"pwdInputTitle"] placeholder:(self.step == 3 ? NSLocalizedString(@"inportPassword_unnecessary", @"请输入密码（非必填）"): [_dataDic objectForKey:@"pwdInputPlaceholder"]) haveButton:[[_dataDic objectForKey:@"pwdInputHaveButton"] boolValue]];
    self.pwdInputView.textChangedAction = ^(NSString * _Nonnull changedText) {
        if (selfWeak.step == 2) {
            if (selfWeak.wifiInputView.inputText.length > 0 && selfWeak.pwdInputView.inputText.length > 0) {
                selfWeak.nextBtn.backgroundColor = kMainColor;
                selfWeak.nextBtn.enabled = YES;
            }
            else{
                selfWeak.nextBtn.backgroundColor = kMainColorDisable;
                selfWeak.nextBtn.enabled = NO;
            }
        }
    };
    [self.view addSubview:self.pwdInputView];
    [self.pwdInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.wifiInputView);
        make.top.equalTo(self.wifiInputView.mas_bottom);
    }];
    
    NSString *makeText = [_dataDic objectForKey:@"make"];
    
    if (makeText && makeText.length && self.step == 3) {
        UILabel *makeLabel = [[UILabel alloc] init];
        makeLabel.textColor = kRGBColor(51, 51, 51);
        makeLabel.font = [UIFont wcPfMediumFontOfSize:14];
        makeLabel.text = makeText;
        [self.view addSubview:makeLabel];
        [makeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.pwdInputView.mas_bottom).offset(20);
            make.left.equalTo(self.view).offset(16);
            make.right.equalTo(self.view).offset(-16);
            make.height.mas_equalTo(24);
        }];
        
        NSString *stepText = [_dataDic objectForKey:@"stepDiscribe"];
        
        if (stepText && stepText.length && self.step == 3) {
            UILabel *stepLabel = [[UILabel alloc] init];
            NSString *stepLabelText = stepText;
            NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc]init];
            paragraph.lineSpacing = 6.0;
            // 字体: 大小 颜色 行间距
            NSAttributedString * attributedStr = [[NSAttributedString alloc]initWithString:stepLabelText attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:kRGBColor(51, 51, 51),NSParagraphStyleAttributeName:paragraph}];
            stepLabel.attributedText = attributedStr;
            stepLabel.numberOfLines = 0;
            [self.view addSubview:stepLabel];
            [stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(makeLabel);
                make.top.equalTo(makeLabel.mas_bottom).offset(4);
            }];
            
        }
    }
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:NSLocalizedString(@"next", @"下一步") forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.layer.cornerRadius = 2;
    if (self.step == 2) {
        nextBtn.backgroundColor = kMainColorDisable;
        nextBtn.enabled = NO;
    } else {
        nextBtn.backgroundColor = kMainColor;
    }
    [self.view addSubview:nextBtn];
    self.nextBtn = nextBtn;
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(40);
        make.top.equalTo(self.pwdInputView.mas_bottom).offset(264 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 80);
        make.height.mas_equalTo(45);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationwillenterforegound) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)showLocationTips
{

    if(![CLLocationManager locationServicesEnabled]){
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Name = [infoDict objectForKey:@"CFBundleDisplayName"];
        if (app_Name == nil) {
            app_Name = [infoDict objectForKey:@"CFBundleName"];
        }
        
        NSString *messageString = [NSString stringWithFormat:@"[前往：设置 - 隐私 - 定位服务 - %@] 允许应用访问", app_Name];
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"APPacquireLocation", @"App需要访问您的位置用于获取Wi-Fi信息") message:messageString preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", @"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSString *messageString = [NSString stringWithFormat:NSLocalizedString(@"turnon_LocationService", @"前往：设置开启定位服务")];
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"APPacquireLocation", @"App需要访问您的位置用于获取Wi-Fi信息") message:messageString preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", @"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"成功");
                }
                else
                {
                    NSLog(@"失败");
                }
            }];
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
        
    }
}

#pragma mark private Method

- (void)getWifiInfos {
    if (@available(iOS 13.0, *)) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self.wifiInfo removeAllObjects];
        [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
        self.wifiInputView.inputText = self.wifiInfo[@"name"];
    }
}

- (void)scanWifiInfos{

    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
    [options setObject:@"" forKey: kNEHotspotHelperOptionDisplayName];
    dispatch_queue_t queue = dispatch_queue_create("EFNEHotspotHelperDemo", NULL);

    NSLog(@"2.Try");
    BOOL returnType = [NEHotspotHelper registerWithOptions: options queue: queue handler: ^(NEHotspotHelperCommand * cmd) {

        NSLog(@"4.Finish");
        NEHotspotNetwork* network;
        if (cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList) {
            // 遍历 WiFi 列表，打印基本信息
            for (network in cmd.networkList) {
                NSString* wifiInfoString = [[NSString alloc] initWithFormat: @"---------------------------\nSSID: %@\nMac地址: %@\n信号强度: %f\nCommandType:%ld\n---------------------------\n\n", network.SSID, network.BSSID, network.signalStrength, (long)cmd.commandType];
                NSLog(@"%@", wifiInfoString);

                // 检测到指定 WiFi 可设定密码直接连接
                if ([network.SSID isEqualToString: @"测试 WiFi"]) {
                    [network setConfidence: kNEHotspotHelperConfidenceHigh];
                    [network setPassword: @"123456789"];
                    NEHotspotHelperResponse *response = [cmd createResponse: kNEHotspotHelperResultSuccess];
                    NSLog(@"Response CMD: %@", response);
                    [response setNetworkList: @[network]];
                    [response setNetwork: network];
                    [response deliver];
                }
            }
        }
    }];

    // 注册成功 returnType 会返回一个 Yes 值，否则 No
    NSLog(@"3.Result: %@", returnType == YES ? @"Yes" : @"No");
    
#warning TODU - modify if judge condition
    if (!returnType) {
        self.wifiListView.wifiListArray = [NSArray array];
    }
}

#pragma mark public Method

- (void)showWiFiListView {
    if (self.wifiListView) {
        self.wifiListView.hidden = NO;
    }
}

#pragma mark eventResponse

- (void)nextClick:(UIButton *)sender {
    [self.wifiInfo setObject:self.wifiInputView.inputText forKey:@"name"];
    [self.wifiInfo setObject:self.pwdInputView.inputText forKey:@"pwd"];
    [self.wifiInfo setObject:self.currentDistributionToken forKey:@"token"];
    
    if (self.configHardwareStyle == TIoTConfigHardwareStyleSoftAP) {
        if (self.step == 2) {
            TIoTDeviceWIFITipViewController *vc = [[TIoTDeviceWIFITipViewController alloc] init];
            vc.configHardwareStyle = _configHardwareStyle;
            vc.roomId = self.roomId;
            vc.currentDistributionToken = self.currentDistributionToken;
            vc.wifiInfo = [self.wifiInfo copy];
            vc.connectGuideData = self.configConnentData[@"WifiSoftAP"][@"connectApGuide"];
            vc.configdata = self.configConnentData;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            TIoTStartConfigViewController *vc = [[TIoTStartConfigViewController alloc] init];
            vc.wifiInfo = [self.softApWifiInfo copy];
            vc.roomId = self.roomId;
            vc.configHardwareStyle = self.configHardwareStyle;
            vc.connectGuideData = self.configConnentData;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        TIoTStartConfigViewController *vc = [[TIoTStartConfigViewController alloc] init];
        vc.wifiInfo = [self.wifiInfo copy];
        vc.roomId = self.roomId;
        vc.configHardwareStyle = self.configHardwareStyle;
        vc.connectGuideData = self.configConnentData;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)applicationwillenterforegound
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self.wifiInfo removeAllObjects];
            [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
            self.wifiInputView.inputText = self.wifiInfo[@"name"];
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
    });
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.wifiInfo removeAllObjects];
        [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
        self.wifiInputView.inputText = self.wifiInfo[@"name"];
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        [manager requestWhenInUseAuthorization];
    }
    else
    {
        [self showLocationTips];
    }
}

#pragma mark setter or getter

- (void)setConfigHardwareStyle:(TIoTConfigHardwareStyle)configHardwareStyle {
    _configHardwareStyle = configHardwareStyle;
    switch (configHardwareStyle) {
        case TIoTConfigHardwareStyleSoftAP:
        {
            _dataDic = @{@"title": NSLocalizedString(@"softAP_distributionNetwork", @"热点配网"),
                         @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"setupTargetWiFi", @"设置目标WiFi"), NSLocalizedString(@"connected_device", @"连接设备"), NSLocalizedString(@"start_distributionNetwork", @"开始配网")],
                         @"topic": NSLocalizedString(@"import_WiFiPassword", @"请输入WiFi密码"),
                         @"wifiInputTitle": @"WIFI",
                         @"wifiInputPlaceholder": NSLocalizedString(@"clickArrow_choiceWIFI", @"请点击箭头按钮选择WIFI"),
                         @"wifiInputHaveButton": @(YES),
                         @"pwdInputTitle": NSLocalizedString(@"password", @"密码"),
                         @"pwdInputPlaceholder":NSLocalizedString(@"smart_config_second_hint", @"请输入密码"),
                         @"pwdInputHaveButton": @(NO),
                         @"make": NSLocalizedString(@"operationMethod", @"操作方式:"),
                         @"stepDiscribe": @"1.点击WiFi名称右侧的下拉按钮，前往手机WiFi设置界面选择设备热点后，返回APP。\n2.填写设备密码，若设备热点无密码则无需填写。\n3.点击下一步，开始配网。"
            };
        }
            break;
            
        case TIoTConfigHardwareStyleSmartConfig:
        {
            _dataDic = @{@"title": NSLocalizedString(@"smartConf_distributionNetwork", @"一键配网"),
                         @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"chooseTargetWiFi", @"选择目标WiFi"), NSLocalizedString(@"start_distributionNetwork", @"开始配网")],
                         @"topic": NSLocalizedString(@"import_WiFiPassword", @"请输入WiFi密码"),
                         @"wifiInputTitle": @"WIFI",
                         @"wifiInputPlaceholder": NSLocalizedString(@"clickArrow_choiceWIFI", @"请点击箭头按钮选择WIFI"),
                         @"wifiInputHaveButton": @(YES),
                         @"pwdInputTitle": NSLocalizedString(@"password", @"密码"),
                         @"pwdInputPlaceholder": NSLocalizedString(@"smart_config_second_hint", @"请输入密码"),
                         @"pwdInputHaveButton": @(NO),
                         @"make": @"",
                         @"stepDiscribe": @""
            };
        }
            break;
            
        default:
            break;
    }
    [self setupUI];
    [self getWifiInfos];
}

- (CLLocationManager *)locationManager {
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

- (TIoTWIFIListView *)wifiListView {
    if (!_wifiListView) {
        _wifiListView = [[TIoTWIFIListView alloc] init];

        WeakObj(self)
        _wifiListView.refreshAction = ^{
            [selfWeak scanWifiInfos];
        };
        
        _wifiListView.accessWifiAction = ^{
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSInteger known = [defaults integerForKey:@"wifi_tip_konwn"];
            if (known) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]){
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                }
            } else {
                selfWeak.wifiListView.hidden = YES;
                TIoTWIFITipViewController *vc = [[TIoTWIFITipViewController alloc] init];
                vc.title = selfWeak.title;
                [selfWeak.navigationController pushViewController:vc animated:YES];
            }
        };
    }
    return _wifiListView;
}

@end
