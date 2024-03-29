//
//  WCSmartConfigDisNetViewController.m
//  TenextCloud
//
//

#import "TIoTWIFINetViewController.h"
#import "TIoTConnectViewController.h"
#import "TIoTSoftapConnectViewController.h"

#import <CoreLocation/CoreLocation.h>
#import "TIoTCoreUtil.h"
#import "ReachabilityManager.h"

@interface TIoTWIFINetViewController ()<CLLocationManagerDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITextField *wifiNameTF;
@property (nonatomic, strong) UITextField *wifiPwdTF;
@property (nonatomic, strong) UIButton *sureBtn;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *wifiInfo;

@end

@implementation TIoTWIFINetViewController

#pragma mark lifeCircle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getWifiInfos];
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationwillenterforegound) name:UIApplicationWillEnterForegroundNotification object:nil];

    __weak TIoTWIFINetViewController *weakself = self;
    NetworkReachabilityManager *reachability = [NetworkReachabilityManager sharedManager];
    [reachability setReachabilityStatusChangeBlock:^(NetworkReachabilityStatus status) {
        switch (status) {
            case NetworkReachabilityStatusUnknown:
                DDLogDebug(@"状态不知道");
                weakself.wifiNameTF.text = @"";
                break;
            case NetworkReachabilityStatusNotReachable:
                DDLogWarn(@"没网络");
                weakself.wifiNameTF.text = @"";
                break;
            case NetworkReachabilityStatusReachableViaWiFi:
                DDLogDebug(@"WIFI");
                [weakself.wifiInfo removeAllObjects];
                [weakself.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
                weakself.wifiNameTF.text = weakself.wifiInfo[@"name"];

                break;
            case NetworkReachabilityStatusReachableViaWWAN:
                DDLogDebug(@"移动网络");
                weakself.wifiNameTF.text = @"";
                break;
            default:
                break;
        }
    }];
    
    //开始监控
    [reachability startMonitoring];
    
}

#pragma mark - private
- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"smart_config_second_title", @"连接WI-FI");
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [cancleBtn sizeToFit];
    UIBarButtonItem *cancleItem = [[UIBarButtonItem alloc] initWithCustomView:cancleBtn];
    self.navigationItem.leftBarButtonItems  = @[cancleItem];
    
    
    [self.view addSubview:self.wifiNameTF];
    [self.wifiNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.mas_equalTo(50 + [TIoTUIProxy shareUIProxy].navigationBarHeight);
    }];
    
    UIView *nameLineView = [[UIView alloc] init];
    nameLineView.backgroundColor = kLineColor;
    [self.view addSubview:nameLineView];
    [nameLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kHorEdge);
        make.right.equalTo(self.view).offset(-kHorEdge);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(self.wifiNameTF.mas_bottom).offset(10);
    }];
    
    self.wifiPwdTF = [[UITextField alloc] init];
    self.wifiPwdTF.placeholder = NSLocalizedString(@"import_WiFiPassword", @"请输入WiFi密码");
    self.wifiPwdTF.font = [UIFont wcPfRegularFontOfSize:18];
    self.wifiPwdTF.textColor = kRGBColor(51, 51, 51);
    [self.wifiPwdTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    self.wifiPwdTF.rightViewMode = UITextFieldViewModeAlways;
    self.wifiPwdTF.rightView = [self pwdRightView];
    self.wifiPwdTF.secureTextEntry = YES;
    [self.view addSubview:self.wifiPwdTF];
    [self.wifiPwdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(nameLineView.mas_bottom).offset(41);
    }];
    
    UIView *pwdLineView = [[UIView alloc] init];
    pwdLineView.backgroundColor = kLineColor;
    [self.view addSubview:pwdLineView];
    [pwdLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kHorEdge);
        make.right.equalTo(self.view).offset(-kHorEdge);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(self.wifiPwdTF.mas_bottom).offset(10);
    }];
    
    
    self.sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sureBtn setTitle:NSLocalizedString(@"confirm", @"确定") forState:UIControlStateNormal];
    [self.sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sureBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.sureBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    self.sureBtn.backgroundColor = [UIColor colorWithHexString:kNoSelectedHexColor];
    self.sureBtn.enabled = NO;
    self.sureBtn.layer.cornerRadius = 3;
    [self.view addSubview:self.sureBtn];
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(pwdLineView.mas_bottom).offset(40 * kScreenAllHeightScale);
        make.right.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(48);
    }];
}

- (UIView *)pwdRightView{
    UIView *rightView = [[UIView alloc] init];
    rightView.bounds = CGRectMake(0, 0, 40, 40);
    
    UIButton *seePwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [seePwdBtn setImage:[UIImage imageNamed:@"pwdSecure"] forState:UIControlStateNormal];
    [seePwdBtn setImage:[UIImage imageNamed:@"seePwd"] forState:UIControlStateSelected];
    [seePwdBtn addTarget:self action:@selector(seePwd:) forControlEvents:UIControlEventTouchUpInside];
    seePwdBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightView addSubview:seePwdBtn];
    
    return rightView;
}

- (UIView *)wifiRightView{
    UIView *rightView = [[UIView alloc] init];
    rightView.bounds = CGRectMake(0, 0, 40, 40);
    
    UIButton *seePwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [seePwdBtn setImage:[UIImage imageNamed:@"t_right"] forState:UIControlStateNormal];
    [seePwdBtn addTarget:self action:@selector(toSetting:) forControlEvents:UIControlEventTouchUpInside];
    seePwdBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightView addSubview:seePwdBtn];
    
    return rightView;
}

- (void)showLocationTips
{

    if(![CLLocationManager locationServicesEnabled]){
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Name = [infoDict objectForKey:@"CFBundleDisplayName"];
        if (app_Name == nil) {
            app_Name = [infoDict objectForKey:@"CFBundleName"];
        }
        
//        NSString *messageString = [NSString stringWithFormat:@"[前往：设置 - 隐私 - 定位服务 - %@] 允许应用访问", app_Name];
        NSString *messageString = [NSString stringWithFormat:@"%@%@]%@",NSLocalizedString(@"introduce_wifiInfo", @"[前往：设置 - 隐私 - 定位服务 - "),app_Name,NSLocalizedString(@"allow_app_access", @"允许应用访问")];
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

- (void)applicationwillenterforegound
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self.wifiInfo removeAllObjects];
            [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
            self.wifiNameTF.text = self.wifiInfo[@"name"];
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
    });
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
        self.wifiNameTF.text = self.wifiInfo[@"name"];
    }
}

#pragma mark - event

- (void)sureClick:(id)sender{
    [self.wifiInfo setObject:self.wifiNameTF.text forKey:@"name"];
    [self.wifiInfo setObject:self.wifiPwdTF.text forKey:@"pwd"];
    [self.wifiInfo setObject:self.currentDistributionToken forKey:@"token"];
    switch (self.equipmentType) {
        case SmartConfig:{
            TIoTConnectViewController *vc = [[TIoTConnectViewController alloc] init];
            vc.title = NSLocalizedString(@"smart_config_third_connect_progress",  @"配网进度");
            vc.wifiInfo = self.wifiInfo.copy;
            vc.roomId = self.roomId;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case Softap:{
            TIoTSoftapConnectViewController *vc = [[TIoTSoftapConnectViewController alloc] init];
            vc.wifiInfo = self.wifiInfo.copy;
            vc.roomId = self.roomId;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)cancleClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)changedTextField:(UITextField *)textField{
    if (self.wifiNameTF.text.length > 0 && self.wifiPwdTF.text.length > 0) {
        self.sureBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
        self.sureBtn.enabled = YES;
    }
    else{
        self.sureBtn.backgroundColor = [UIColor colorWithHexString:kNoSelectedHexColor];
        self.sureBtn.enabled = NO;
    }
}

- (void)seePwd:(UIButton *)btn{
    btn.selected = !btn.selected;
    self.wifiPwdTF.secureTextEntry = !btn.selected;
}

- (void)toSetting:(UIButton *)sender
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

#pragma mark - setter or getter

- (NSMutableDictionary *)wifiInfo{
    if (_wifiInfo == nil) {
        _wifiInfo = [NSMutableDictionary dictionary];
    }
    return _wifiInfo;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (UITextField *)wifiNameTF
{
    if (!_wifiNameTF) {
        _wifiNameTF = [[UITextField alloc] init];
        _wifiNameTF.placeholder = @"Wi-Fi名";
        _wifiNameTF.font = [UIFont wcPfRegularFontOfSize:18];
        _wifiNameTF.textColor = kRGBColor(51, 51, 51);
        [_wifiNameTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
        _wifiNameTF.rightViewMode = UITextFieldViewModeAlways;
        _wifiNameTF.rightView = [self wifiRightView];
        _wifiNameTF.delegate = self;
    }
    return _wifiNameTF;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.wifiInfo removeAllObjects];
        [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
        self.wifiNameTF.text = self.wifiInfo[@"name"];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.equipmentType == SmartConfig) {
        return NO;
    }
    return YES;
}

@end
