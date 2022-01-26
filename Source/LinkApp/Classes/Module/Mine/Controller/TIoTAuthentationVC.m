//
//  TIoTAuthentationVC.m
//  LinkApp
//  Copyright © 2021 Tencent. All rights reserved.

#import "TIoTAuthentationVC.h"
#import "TIoTUserInfomationTableViewCell.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "TIoTCoreUtil.h"

@interface TIoTAuthentationVC ()<UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate,CLLocationManagerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *dataArr;
@property (nonatomic, strong) CBCentralManager *centralManager; //判断蓝牙是否开启
/// 蓝牙是否可用
@property (nonatomic, assign) BOOL bluetoothAvailable;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL locationAvailable; //地图是否可用
@end

@implementation TIoTAuthentationVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"modify_authentation", @"权限管理");
    
    [self setUpUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationwillenterforegound) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //判断蓝牙是否开启
    if ([[TIoTCoreUserManage shared].isChangeBluetoothAuth isEqualToString:@"1"]) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.bluetoothAvailable = YES;
    }else  {
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].isChangeBluetoothAuth]) {
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        }else {
            self.bluetoothAvailable = NO;
        }
        
    }
}

- (void)applicationwillenterforegound
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
    });
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view);
        }
    }];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 16 * kScreenAllHeightScale)];
    headerView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - tableViewDataSource and tableViewDelegate

//国际化版本
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    //国际化版本
    NSArray *sectionDataArray = self.dataArr[section];
    return sectionDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //国际化版本
    TIoTUserInfomationTableViewCell *cell = [TIoTUserInfomationTableViewCell cellWithTableView:tableView];
    cell.dic = self.dataArr[indexPath.section][indexPath.row];
    cell.arrowSwitch.on = NO;
    
    if (indexPath.section == 0) {
        cell.arrowSwitch.on = [self isSwitchAppNotification];
    }else if (indexPath.section == 1) {
        cell.arrowSwitch.on = [self locationAuthority];
    }else if (indexPath.section == 2) {
        cell.arrowSwitch.on = [self audioAuthority:AVMediaTypeVideo];
    }else if (indexPath.section == 3) {
        cell.arrowSwitch.on = [self audioAuthority:AVMediaTypeAudio];
    }else if (indexPath.section == 4) {
        cell.arrowSwitch.on = self.bluetoothAvailable;
    }
    
    cell.authSwitch = ^(BOOL open,UISwitch *switchControl) {
        
        if (indexPath.section == 0) {
            [self jumpSetting];
            
        }else if (indexPath.section == 1) {
            CLAuthorizationStatus CLstatus = [CLLocationManager authorizationStatus];
            if (CLstatus == kCLAuthorizationStatusNotDetermined) {
                self.locationManager = [[CLLocationManager alloc] init];
                self.locationManager.delegate = self;
            }else {
                [self jumpSetting];
            }
            
        }else if (indexPath.section == 2) {
            if ([self getMediaNotDetermStatusWithType:AVMediaTypeVideo]) {
                
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                         completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            //同意授权
                            switchControl.on = YES;
                        } else {
                            //拒绝授权
                            switchControl.on = NO;
                        }
                    });
                }];
                
            }else {
                [self jumpSetting];
            }
        }else if (indexPath.section == 3) {
            if ([self getMediaNotDetermStatusWithType:AVMediaTypeAudio]) {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                         completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            //同意授权
                            switchControl.on = YES;
                        } else {
                            //拒绝授权
                            switchControl.on = NO;
                        }
                    });
                }];
            }else {
                [self jumpSetting];
            }
        }else if (indexPath.section == 4) {
            if (self.centralManager.state == CBManagerStateUnauthorized) {
                //判断蓝牙是否开启
                self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
                if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].isChangeBluetoothAuth]) {
                    [self jumpSetting];
                }
            }else {
                
                if ([NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].isChangeBluetoothAuth]) {
                    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
                }else {
                    if ([[TIoTCoreUserManage shared].isChangeBluetoothAuth isEqualToString:@"0"]) {
                        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
                    }
                    [self jumpSetting];
                }
            }
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UITableView *)tableView {
    if (!_tableView) {
        //国际化版本
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        _tableView.rowHeight = 48;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TIoTUserInfomationTableViewCell class] forCellReuseIdentifier:ID];
    }
    return _tableView;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {

        _dataArr = [NSMutableArray arrayWithArray:@[
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte1", @"通知推送权限"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte2", @"位置信息"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte3", @"摄像头权限"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte5", @"麦克风权限"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte4", @"蓝牙权限"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
        ]];
    }
    
    return _dataArr;
}

//判断是否麦克风和摄像头请求授权
- (BOOL)getMediaNotDetermStatusWithType:(AVMediaType)mediaType {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        return YES;
    }else {
        return NO;
    }
}

- (void)jumpSetting {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

#pragma mark - 是否开启APP推送
/**是否开启推送*/
- (BOOL)isSwitchAppNotification {
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 10.0) {
        __block BOOL result = NO;
        //异步线程中操作是否完成
        __block BOOL inThreadOperationComplete = NO;
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                result = NO;
            }else if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                result = NO;
            }else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                result = YES;
            }else {
                result = NO;
            }
            inThreadOperationComplete = YES;
        }];
        
        while (!inThreadOperationComplete) {
            [NSThread sleepForTimeInterval:0];
        }
        return result;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    else if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0)
    {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone != setting.types) {
            return YES;
        }else {
            return NO;
        }
        
    }else
    {
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(UIRemoteNotificationTypeNone != type) {
            return YES;
        }else {
            return NO;
        }
    }
}

- (BOOL)locationAuthority {
    BOOL isLocation = [CLLocationManager locationServicesEnabled];
    if (isLocation) {
        
        CLAuthorizationStatus CLstatus = [CLLocationManager authorizationStatus];
        if (CLstatus == kCLAuthorizationStatusDenied || CLstatus == kCLAuthorizationStatusDenied || CLstatus == kCLAuthorizationStatusNotDetermined) {
            return NO;
        }
        
    }else {
        return NO;
    }
    return YES;
}

- (BOOL)audioAuthority:(AVMediaType)type {
//    return [TIoTCoreUtil requestMediaAuthorization:type];
    return [TIoTCoreUtil userAccessMediaAuthorization:type];
}

#pragma mark - 判断蓝牙是否开启代理
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            [TIoTCoreUserManage shared].isChangeBluetoothAuth = @"1";
            self.bluetoothAvailable = true; break; //NSLog(@"蓝牙开启且可用");
        case CBManagerStateUnknown:
            [TIoTCoreUserManage shared].isChangeBluetoothAuth = @"0";
            self.bluetoothAvailable = false; break; //NSLog(@"手机没有识别到蓝牙，请检查手机。");
        case CBManagerStateResetting:
            [TIoTCoreUserManage shared].isChangeBluetoothAuth = @"1";
            self.bluetoothAvailable = false; break; //NSLog(@"手机蓝牙已断开连接，重置中。");
        case CBManagerStateUnsupported:
            self.bluetoothAvailable = false; break; //NSLog(@"手机不支持蓝牙功能，请更换手机。");
        case CBManagerStatePoweredOff:
            [self customAlertOpenBluetooth];
            [TIoTCoreUserManage shared].isChangeBluetoothAuth = @"0";
            self.bluetoothAvailable = false; break; //NSLog(@"手机蓝牙功能关闭，请前往设置打开蓝牙及控制中心打开蓝牙。");
        case CBManagerStateUnauthorized:
            [TIoTCoreUserManage shared].isChangeBluetoothAuth = @"0";
            self.bluetoothAvailable = false; break; //NSLog(@"手机蓝牙功能没有权限，请前往设置。");
        default:  break;
    }
    
    [self.tableView reloadData];
}

- (void)customAlertOpenBluetooth {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDict objectForKey:@"CFBundleDisplayName"];
    if (app_Name == nil) {
        app_Name = [infoDict objectForKey:@"CFBundleName"];
    }
    
    NSString *messageString = [NSString stringWithFormat:NSLocalizedString(@"access_bluetooth_intro", @"如未能成功获取蓝牙状态，请尝试前往【设置】-【蓝牙】中开启，为了便于您访问蓝牙设备，因此腾讯连连需获取蓝牙权限")];
        NSString *titleString = [NSString stringWithFormat:@"\"%@\"%@",app_Name,NSLocalizedString(@"would_lick_access_bluetooth", @"想要使用蓝牙")];
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:titleString message:messageString preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"取消") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertC addAction:alertCancel];
        
        UIAlertAction *alertConfirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", @"确定") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self jumpSetting];
        }];
        [alertC addAction:alertConfirm];
        
        [self presentViewController:alertC animated:YES completion:nil];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager API_AVAILABLE(ios(14.0), macos(11.0), watchos(7.0), tvos(14.0)) {
    CLAuthorizationStatus status = [manager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        self.locationAvailable = YES;
    }else if (status == kCLAuthorizationStatusNotDetermined) {
        self.locationAvailable = NO;
        [manager requestWhenInUseAuthorization];
    }else {
        //提示语弹框
        self.locationAvailable = NO;
    }
    [self.tableView reloadData];
}
@end
