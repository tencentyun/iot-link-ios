//
//  TIoTAuthentationVC.m
//  LinkApp
//  Copyright © 2021 Tencent. All rights reserved.

#import "TIoTAuthentationVC.h"
#import "TIoTUserInfomationTableViewCell.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

@interface TIoTAuthentationVC ()<UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *dataArr;
@property (nonatomic, strong) CBCentralManager *centralManager; //判断蓝牙是否开启
/// 蓝牙是否可用
@property (nonatomic, assign) BOOL bluetoothAvailable;
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
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
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
        cell.arrowSwitch.on = [self audioAuthority];
    }else if (indexPath.section == 3) {
        cell.arrowSwitch.on = self.bluetoothAvailable;
    }
    
    cell.authSwitch = ^(BOOL open) {

        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]){
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
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
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte1", @"推送权限"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte2", @"位置信息"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte3", @"摄像头/麦克风权限"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
            @[@{@"title":NSLocalizedString(@"authentation_privacy_conte4", @"蓝牙权限"),@"value":@"",@"vc":@"",@"haveArrow":@"2"}],
        ]];
    }
    
    return _dataArr;
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
        if (CLstatus == kCLAuthorizationStatusDenied || CLstatus == kCLAuthorizationStatusDenied) {
            return NO;
        }
        
    }else {
        return NO;
    }
    return YES;
}

- (BOOL)audioAuthority {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        return NO;
    }
    return YES;
}

#pragma mark - 判断蓝牙是否开启代理
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            self.bluetoothAvailable = true; break; //NSLog(@"蓝牙开启且可用");
        case CBManagerStateUnknown:
            self.bluetoothAvailable = false; break; //NSLog(@"手机没有识别到蓝牙，请检查手机。");
        case CBManagerStateResetting:
            self.bluetoothAvailable = false; break; //NSLog(@"手机蓝牙已断开连接，重置中。");
        case CBManagerStateUnsupported:
            self.bluetoothAvailable = false; break; //NSLog(@"手机不支持蓝牙功能，请更换手机。");
        case CBManagerStatePoweredOff:
            
            [self customAlertOpenBluetooth];
            self.bluetoothAvailable = false; break; //NSLog(@"手机蓝牙功能关闭，请前往设置打开蓝牙及控制中心打开蓝牙。");
        case CBManagerStateUnauthorized:
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
        }];
        [alertC addAction:alertConfirm];
        
        [self presentViewController:alertC animated:YES completion:nil];
}

@end
