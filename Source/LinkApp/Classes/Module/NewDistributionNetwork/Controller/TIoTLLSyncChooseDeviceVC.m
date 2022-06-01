//
//  TIoTLLSyncChooseDeviceVC.m
//  LinkApp
//

#import "TIoTLLSyncChooseDeviceVC.h"
#import "TIoTStepTipView.h"
#import "TIoTDiscoverProductView.h"
#import "TIoTLLSyncDeviceController.h"

@interface TIoTLLSyncChooseDeviceVC ()
@property (nonatomic, strong) TIoTStepTipView *stepTipView;
@property (nonatomic, strong) NSDictionary *dataDic;
//@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *stepLabel;

@property (nonatomic, strong) TIoTDiscoverProductView *discoverView;
@property (nonatomic, strong) TIoTLLSyncDeviceController *pureBleVC;
@end

@implementation TIoTLLSyncChooseDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    
}

- (void)setupUI{
    self.title = [self.dataDic objectForKey:@"title"];
    self.view.backgroundColor = [UIColor whiteColor];

    self.stepTipView = [[TIoTStepTipView alloc] initWithTitlesArray:[self.dataDic objectForKey:@"stepTipArr"]];
    self.stepTipView.step = 2;
    [self.view addSubview:self.stepTipView];
    [self.stepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64 + 20);
        }
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(54+8);
    }];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = [UIColor colorWithHexString:kTemperatureHexColor];
    topicLabel.numberOfLines = 0;
    topicLabel.font = [UIFont wcPfMediumFontOfSize:16];
    topicLabel.text = [self.dataDic objectForKey:@"topic"];
    [self.view addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.stepTipView.mas_bottom).offset(20);
    }];
    
    //发现纯蓝牙设备view
    self.discoverView = [[TIoTDiscoverProductView alloc] init];
    //初始状态隐藏
    [self.discoverView hideHelpAction];
    [self.discoverView hideScanAction];
    WeakObj(self)
    self.discoverView.retryAction = ^{
        
        [[BluetoothCentralManager shareBluetooth] scanNearLLSyncService];
        selfWeak.discoverView.status = DiscoverDeviceStatusDiscovering;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (selfWeak.pureBleVC.originBlueDevices) {
                selfWeak.discoverView.status = DiscoverDeviceStatusDiscovered;
                
                CGFloat discoverHeight = ((selfWeak.pureBleVC.originBlueDevices.allKeys.count - 1)/3 + 1) * 80 + 100;
                [selfWeak.discoverView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(discoverHeight);
                }];
            }else {
                selfWeak.discoverView.status = DiscoverDeviceStatusNotFound;
            }
        });
    };
    [self.view addSubview:self.discoverView];
    [self.discoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topicLabel.mas_bottom).offset(20);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(kScreenHeight/2);
    }];
    
    //需要先停止扫描
    [[BluetoothCentralManager shareBluetooth] stopScan];
    
    self.pureBleVC = [[TIoTLLSyncDeviceController alloc] init];
    self.pureBleVC.configHardwareStyle = TIoTConfigHardwareStylePureBleLLsync;
    self.pureBleVC.roomId = self.roomId;
    self.pureBleVC.configdata = self.configdata;
    self.pureBleVC.isFromProductList = self.isFromProductsList;
    self.pureBleVC.currentDistributionToken = self.currentDistributionToken;
    
    //后面的流程需要给 currentDistributionToken、wifiInfo、connectGuideData、configdata赋值
    [self addChildViewController:self.pureBleVC];
    [self.pureBleVC.view setFrame:CGRectMake(0, 0, kScreenWidth, 300)];
    [self.discoverView changeTableFooterView:self.pureBleVC.view];
    [self.pureBleVC changeContentArea];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.pureBleVC.originBlueDevices) {
            self.discoverView.status = DiscoverDeviceStatusDiscovered;
            
            CGFloat discoverHeight = ((self.pureBleVC.originBlueDevices.allKeys.count - 1)/3 + 1) * 80 + 100;
            [self.discoverView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(discoverHeight);
            }];
        }else {
            self.discoverView.status = DiscoverDeviceStatusNotFound;
        }
        //扫描结果后隐藏
        [self.discoverView hideHelpAction];
        [self.discoverView hideScanAction];
    });
    
}

#pragma mark setter or getter

- (NSDictionary *)dataDic {
    if (!_dataDic) {
        _dataDic = @{@"title":NSLocalizedString(@"standard_ble_binding", @"标准蓝牙设备绑定"),
                     @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"selected_Device",  @"选择设备"), NSLocalizedString(@"start_binding", @"开始绑定")],
                     @"topic": NSLocalizedString(@"click_binding_devcie", @"点击需要绑定的设备"),
                     @"stepDiscribe": @""
        };
    }
    return _dataDic;
}

@end
