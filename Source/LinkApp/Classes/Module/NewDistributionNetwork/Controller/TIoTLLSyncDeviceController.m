//
//  TIoTLLSyncDeviceController.m
//  LinkApp
//
//

#import "TIoTLLSyncDeviceController.h"
#import "TIoTStepTipView.h"
#import "TIoTLLSyncDeviceCell.h"
#import "TIoTLLSyncViewController.h"

@interface TIoTLLSyncDeviceController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,BluetoothCentralManagerDelegate>

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *WiFiName; //获取设备WiFi名称
@property (nonatomic, strong) UICollectionView *collectionView; //推荐房间列表
@property (nonatomic, copy) NSArray<CBPeripheral *> *blueDevices; //推荐房间列表

@property (nonatomic, strong) NSString *currentProductId; //当前连接的产品id
@property (nonatomic, strong) NSString *currentDevicename; //当前连接的设备名称
@property (nonatomic, strong) CBPeripheral *currentConnectedPerpheral; //当前连接的设备
@property (nonatomic, weak)BluetoothCentralManager *blueManager;

@property (nonatomic, strong) TIoTStartConfigViewController *resultvc; //当前连接的设备
@property (nonatomic, assign) BOOL isFromHome; //表示从产品页的蓝牙模块来的
@end

@implementation TIoTLLSyncDeviceController

- (void)dealloc {
    DDLogDebug(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    self.blueManager = [BluetoothCentralManager shareBluetooth];
    self.blueManager.delegate = self;
    [self.blueManager scanNearLLSyncService];
}

- (void)changeContentArea {
    self.isFromHome = YES;
    self.scrollView.scrollEnabled = NO;
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(20);
        make.width.mas_equalTo(kScreenWidth - 40);
        make.top.equalTo(self.scrollView).offset(0);
//        make.bottom.equalTo(nextBtn.mas_top).offset(-20);
        make.height.mas_equalTo(300);
    }];
}

- (void)setupUI{
    self.title = [self.dataDic objectForKey:@"title"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64);
        }
    }];

    
    self.stepTipView = [[TIoTStepTipView alloc] initWithTitlesArray:[self.dataDic objectForKey:@"stepTipArr"]];
    self.stepTipView.showAnimate = NO;
    self.stepTipView.step = 3;
    [self.scrollView addSubview:self.stepTipView];
    [self.stepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView).offset(20);
//        make.width.equalTo(self.scrollView);
        make.left.equalTo(self.scrollView.mas_left).offset(10);
        make.right.equalTo(self.scrollView.mas_right).offset(-10);
        make.height.mas_equalTo(54+8);
    }];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = [UIColor colorWithHexString:kTemperatureHexColor];
    topicLabel.font = [UIFont wcPfMediumFontOfSize:16];
    topicLabel.text = [self.dataDic objectForKey:@"topic"];
    [self.scrollView addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.stepTipView.mas_bottom).offset(20);
//        make.height.mas_equalTo(24);
    }];

    CGFloat kPadding = 20; //image 边距
    
    self.stepLabel = [[UILabel alloc] init];
    NSString *stepLabelText = [self.dataDic objectForKey:@"stepDiscribe"];
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.lineSpacing = 6.0;
    // 字体: 大小 颜色 行间距
    NSAttributedString * attributedStr = [[NSAttributedString alloc]initWithString:stepLabelText attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:kRGBColor(51, 51, 51),NSParagraphStyleAttributeName:paragraph}];
    self.stepLabel.attributedText = attributedStr;
    self.stepLabel.numberOfLines = 0;
    [self.scrollView addSubview:self.stepLabel];
    [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topicLabel.mas_bottom).offset(20);
        make.left.equalTo(self.scrollView).offset(kPadding);
        make.right.equalTo(self.scrollView).offset(-kPadding);
    }];
    
    [self.scrollView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(20);
        make.width.mas_equalTo(kScreenWidth - 40);
        make.top.equalTo(self.stepLabel.mas_bottom).offset(20);
//        make.bottom.equalTo(nextBtn.mas_top).offset(-20);
        make.height.mas_equalTo(300);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGFloat contentHeight = 120 + 54 + 24 + CGRectGetHeight(self.imageView.frame)+ CGRectGetHeight(self.stepLabel.frame) + 45 + [TIoTUIProxy shareUIProxy].navigationBarHeight;
    if (contentHeight > kScreenHeight) {
        self.scrollView.scrollEnabled = YES;
    }else {
        self.scrollView.scrollEnabled = NO;
    }
    self.scrollView.contentSize = CGSizeMake(kScreenWidth,contentHeight);
}

- (void)nextClick:(UIButton *)sender {
    if (self.isFromHome) {
        //从首页上方蓝牙模块进入的
        TIoTLLSyncViewController *vc = [[TIoTLLSyncViewController alloc] init];
        vc.llsyncDeviceVC = self;
        vc.configurationData = self.configdata;
        vc.roomId = self.roomId?:@"";
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    self.resultvc = [[TIoTStartConfigViewController alloc] init];
    self.resultvc.wifiInfo = [self.wifiInfo copy];
    self.resultvc.roomId = self.roomId;
    self.resultvc.configHardwareStyle = self.configHardwareStyle;
    self.resultvc.connectGuideData = self.configdata;
    [self.navigationController pushViewController:self.resultvc animated:YES];
    
}

#pragma mark setter or getter

- (NSDictionary *)dataDic {
    if (!_dataDic) {
        
        NSString *guideDiscirbe = self.connectGuideData[@"message"] ? : @"点击选择需要连接的设备";
        _dataDic = @{@"title": NSLocalizedString(@"llsync_network_title", @"蓝牙辅助配网"),
                     @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"setupTargetWiFi", @"设置目标WiFi"), NSLocalizedString(@"connected_device", @"连接设备"), NSLocalizedString(@"start_distributionNetwork", @"开始配网")],
                     @"topic": NSLocalizedString(@"llsync_network_tips", @"设备蓝牙"),
                     @"stepDiscribe": guideDiscirbe
        };
    }
    return _dataDic;
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat itemWidth = 100;
        CGFloat itemHeight = 130;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(6, 12, 15, 12);
        flowLayout.minimumLineSpacing = 30;
//        flowLayout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithHexString:kBackgroundHexColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[TIoTLLSyncDeviceCell class] forCellWithReuseIdentifier:@"TIoTLLSyncDeviceCell"];
    }
    return _collectionView;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return 5;
    return self.blueDevices.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TIoTLLSyncDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TIoTLLSyncDeviceCell" forIndexPath:indexPath];
    CBPeripheral *device = self.blueDevices[indexPath.row];
    cell.itemString = device.name;
    cell.isSelected = NO;
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    self.nameField.text = self.dataArray[indexPath.row];
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:NSLocalizedString(@"llsync_network_hud", @"连接蓝牙中")];

    [TIoTDataTracking logEvent:@"wifi-configuration" params:@{@"[WifiConfStepCode.BLE_CONNECTIONING]":@"BLE配网连接蓝牙中"}];
    
    CBPeripheral *device = self.blueDevices[indexPath.row];
    NSDictionary<NSString *,id> *advertisementData = self.originBlueDevices[device];
    if ([advertisementData.allKeys containsObject:@"kCBAdvDataManufacturerData"]) {
        NSData *manufacturerData = advertisementData[@"kCBAdvDataManufacturerData"];
        NSString *hexstr = [NSString transformStringWithData:manufacturerData];
        NSString *producthex = [hexstr substringWithRange:NSMakeRange(18, hexstr.length-18)];
        NSString *productstr = [NSString stringFromHexString:producthex];
        self.currentProductId = productstr;
        
        [self.blueManager connectBluetoothPeripheral:device];

    }
}




#pragma mark - BluetoothCentralManagerDelegate
//实时扫描外设（目前扫描10s）
- (void)scanPerpheralsUpdatePerpherals:(NSDictionary<CBPeripheral *,NSDictionary<NSString *,id> *> *)perphersArr {
    self.originBlueDevices = perphersArr;
    [TIoTDataTracking logEvent:@"wifi-configuration" params:@{@"[WifiConfStepCode.BLE_SCAN]":@"BLE配网扫描外设"}];
    self.blueDevices = perphersArr.allKeys;
    [self.collectionView reloadData];
}
//连接外设成功
- (void)connectBluetoothDeviceSucessWithPerpheral:(CBPeripheral *)connectedPerpheral withConnectedDevArray:(NSArray <CBPeripheral *>*)connectedDevArray {
    self.currentConnectedPerpheral = connectedPerpheral;
    [TIoTDataTracking logEvent:@"wifi-configuration" params:@{@"[WifiConfStepCode.BLE_CONNECTION_SUCCESS]":@"BLE配网链接外设成功"}];
}
//断开外设
- (void)disconnectBluetoothDeviceWithPerpheral:(CBPeripheral *)disconnectedPerpheral {
    self.currentConnectedPerpheral = nil;
    [TIoTDataTracking logEvent:@"wifi-configuration" params:@{@"[WifiConfStepCode.BLE_DISCONNECTION]":@"BLE配网断开外设"}];
}

- (void)didDiscoverCharacteristicsWithperipheral:(CBPeripheral *)peripheral ForService:(CBService *)service {
    [MBProgressHUD dismissInView:nil];
    if (self.currentConnectedPerpheral) {
        
        [self nextClick:nil];
        
        if (!self.isFromHome) {
            ///如果不是首页蓝牙部分进入的，自动触发指令发送，否则从首页蓝牙进入的话需要等wifi信息后在走下一步
            [self nextUIStep:nil];
        }
    }
}

- (void)nextUIStep:(TIoTStartConfigViewController *)startconfigVC {
    if (self.resultvc == nil) {
        self.resultvc = startconfigVC;
    }
    ///设置UI进度
    self.resultvc.connectStepTipView.step = 1;
    
    [self.blueManager sendLLSyncWithPeripheral:self.currentConnectedPerpheral LLDeviceInfo:@"E0"];
}

//发送数据后，蓝牙回调
- (void)updateData:(NSArray *)dataHexArray withCharacteristic:(CBCharacteristic *)characteristic pheropheralUUID:(NSString *)pheropheralUUID serviceUUID:(NSString *)serviceString {
    if (self.currentConnectedPerpheral) {
        NSString *hexstr = [NSString transformStringWithData:characteristic.value];
        if (hexstr.length < 2) {
            DDLogWarn(@"不支持的蓝牙设备，服务的回调数据不属于llsync --%@",self.currentConnectedPerpheral.name);
            [TIoTDataTracking logEvent:@"wifi-configuration" params:@{@"[WifiConfStepCode.BLE_NOTLLSYNC]":@"不支持的蓝牙设备，服务的回调数据不属于llsync"}];
            return;
        }
        NSString *cmdtype = [hexstr substringWithRange:NSMakeRange(0, 2)];
        if ([cmdtype isEqualToString:@"08"]) {
            //设备信息返回了，此时需要下一步设置wifi模式
            NSString *devicenamehex = [hexstr substringWithRange:NSMakeRange(14, hexstr.length-14)];
            NSString *devicenamestr = [NSString stringFromHexString:devicenamehex];
            self.currentDevicename = devicenamestr;
            
            [self.blueManager sendLLSyncWithPeripheral:self.currentConnectedPerpheral LLDeviceInfo:@"E101"];
        }else if ([cmdtype isEqualToString:@"E0"] || [cmdtype isEqualToString:@"e0"]) {
            //设备WIFI设置模式成功了，此时需要下一步设置wifi pass下发给设备
            NSString *wifiname = self.wifiInfo[@"name"];
            NSString *wifipass = self.wifiInfo[@"pwd"];
            
            NSString *wifinamehex = [NSString hexStringFromString:wifiname];
            NSString *wifipasshex = [NSString hexStringFromString:wifipass];
            
            NSString *wifinamelength = [NSString getHexByDecimal:wifinamehex.length/2];
            while ([wifinamelength length]<2) {
                wifinamelength = [NSString stringWithFormat:@"0%@",wifinamelength];
            }
            NSString *wifipasslength = [NSString getHexByDecimal:wifipasshex.length/2];
            while ([wifipasslength length]<2) {
                wifipasslength = [NSString stringWithFormat:@"0%@",wifipasslength];
            }
            NSString *totallength = [NSString getHexByDecimal:wifinamehex.length/2 + wifipasshex.length/2 + 2];
            while ([totallength length]<4) {
                totallength = [NSString stringWithFormat:@"0%@",totallength];
            }
            
            [TIoTDataTracking logEvent:@"wifi-configuration" params:@{@"[WifiConfStepCode.PROTOCOL_START]":@"开始进行配网协议传输"}];
            
            NSString *cmdtype = [NSString stringWithFormat:@"E2%@%@%@%@%@",totallength, wifinamelength, wifinamehex, wifipasslength, wifipasshex];
            [self.blueManager sendLLSyncWithPeripheral:self.currentConnectedPerpheral LLDeviceInfo:cmdtype];
            
            [TIoTDataTracking logEvent:@"wifi-configuration" params:@{@"[WifiConfStepCode.PROTOCOL_DETAIL]":[NSString stringWithFormat:@"wifiname:%@ wifipass:%@ cmdtype:%@",wifiname,wifipass,cmdtype]}];
            
            ///设置UI进度
            self.resultvc.connectStepTipView.step = 2;
            
        }else if ([cmdtype isEqualToString:@"E1"] || [cmdtype isEqualToString:@"e1"]) {
            
            [TIoTDataTracking logEvent:@"wifi-configuration" params:@{@"[WifiConfStepCode.PROTOCOL_SUCCESS]":@"配网协议传输成功"}];
            
            //已发送给设备WIFI密钥了，此时需要下一步让设备连接Wi-Fi
            [self.blueManager sendLLSyncWithPeripheral:self.currentConnectedPerpheral LLDeviceInfo:@"E3"];
            
        }else if ([cmdtype isEqualToString:@"E2"] || [cmdtype isEqualToString:@"e2"]) {
            //设备连好wifi了，此时需要下一步给设备下发Token
            
            NSString *bingwifitoken = self.wifiInfo[@"token"];
            NSString *bingwifitokenhex = [NSString hexStringFromString:bingwifitoken];
            NSString *totallength = [NSString getHexByDecimal:bingwifitokenhex.length/2];
            while ([totallength length]<4) {
                totallength = [NSString stringWithFormat:@"0%@",totallength];
            }
            NSString *cmdtype = [NSString stringWithFormat:@"E4%@%@",totallength, bingwifitokenhex];
            [self.blueManager sendLLSyncWithPeripheral:self.currentConnectedPerpheral LLDeviceInfo:cmdtype];
            
        }else if ([cmdtype isEqualToString:@"E3"] || [cmdtype isEqualToString:@"e3"]) {
            //设备通过token已经绑定，app开始轮训结果
            
            NSDictionary *deviceData = @{@"productId": self.currentProductId, @"deviceName": self.currentDevicename};
            [self.resultvc checkTokenStateWithCirculationWithDeviceData:deviceData];
            
        }else {
            //如果有失败的话，获取设备配网日志
//            [self.blueManager sendLLSyncWithPeripheral:self.currentConnectedPerpheral LLDeviceInfo:@"E3"];
        }
    }
}

@end
