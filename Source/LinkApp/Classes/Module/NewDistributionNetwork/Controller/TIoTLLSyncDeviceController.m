//
//  TIoTLLSyncDeviceController.m
//  LinkApp
//
//  Created by eagleychen on 2021/7/19.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTLLSyncDeviceController.h"
#import "TIoTStepTipView.h"
#import "TIoTStartConfigViewController.h"
#import "TIoTLLSyncDeviceCell.h"

@interface TIoTLLSyncDeviceController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,BluetoothCentralManagerDelegate>

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *WiFiName; //获取设备WiFi名称
@property (nonatomic, strong) UICollectionView *collectionView; //推荐房间列表
@property (nonatomic, copy) NSArray<CBPeripheral *> *blueDevices; //推荐房间列表
@property (nonatomic, copy) NSDictionary<CBPeripheral *,NSDictionary<NSString *,id> *> *originBlueDevices;
@property (nonatomic, weak)BluetoothCentralManager *blueManager;
@end

@implementation TIoTLLSyncDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    self.blueManager = [BluetoothCentralManager shareBluetooth];
    self.blueManager.delegate = self;
    [self.blueManager scanNearLLSyncService];
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

    CGFloat kImageScale = 0.866667; //高/宽
    CGFloat kPadding = 20; //image 边距
    /*self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"wifieg"];
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topicLabel.mas_bottom).offset(20);
        make.left.equalTo(self.scrollView).offset(kPadding);
        make.right.equalTo(self.scrollView).offset(-kPadding);
        make.height.mas_equalTo(self.imageView.mas_width).multipliedBy(kImageScale);
    }];
    
    CGFloat kWiFiNameHeithtScale =  0.5;//0.487179;//380/780   WiFi 距离顶部高度比例
    CGFloat kWiFiNameWidthtScale = 0.1;//90/900  WiFi 距离左边距比例
    CGFloat kWiFiNameHeitht = 0.0769230;//60/780 WiFi 高度比例
    CGFloat kWiFiNameWidth = 0.6666;//200/900; WiFi 宽度比例
    CGFloat kImageViewWidth = kScreenWidth - kPadding*2;  //imageview 宽度
    CGFloat kImageViewheight = kImageViewWidth * kImageScale; //image 高度
    
    CGFloat kLeftPadding = kWiFiNameWidthtScale * kImageViewWidth; // 转换到image view的左边距
    CGFloat kTopPadding = kWiFiNameHeithtScale * kImageViewheight; //转换到image view的顶部距离
    CGFloat kWiFiHeitht =  kWiFiNameHeitht * kImageViewheight; //转换到image view的高度
    CGFloat kWiFiWidth = kWiFiNameWidth * kImageViewWidth; //转换到image view的宽度
    
    self.WiFiName = [[UILabel alloc]init];
    self.WiFiName.backgroundColor = [UIColor whiteColor];
    if (![NSString isNullOrNilWithObject:self.connectGuideData[@"apName"]]) {
        self.WiFiName.text = self.connectGuideData[@"apName"];
    }else {
        self.WiFiName.text = @"tcloud_XXX";
    }
    
    self.WiFiName.font = [UIFont systemFontOfSize:18];
    [self.imageView addSubview:self.WiFiName];
    [self.WiFiName mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_left).offset(kLeftPadding);
        make.top.equalTo(self.imageView.mas_top).offset(kTopPadding);
        make.height.mas_equalTo(kWiFiHeitht);
        make.width.mas_equalTo(kWiFiWidth);
    }];
     */
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
    
    /*UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:NSLocalizedString(@"next", @"下一步") forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.layer.cornerRadius = 20;
    nextBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(16);
        make.bottom.equalTo(self.view).offset(-60);
        make.width.mas_equalTo(kScreenWidth - 32);
        make.height.mas_equalTo(40);
    }];*/
    
    
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
    
//    TIoTTargetWIFIViewController *vc = [[TIoTTargetWIFIViewController alloc] init];
//    vc.step = 3;
//    vc.configHardwareStyle = _configHardwareStyle;
//    vc.roomId = self.roomId;
//    vc.currentDistributionToken = self.currentDistributionToken;
//    vc.softApWifiInfo = [self.wifiInfo copy];
//    vc.configConnentData = self.configdata;
//    [self.navigationController pushViewController:vc animated:YES];
    
    TIoTStartConfigViewController *vc = [[TIoTStartConfigViewController alloc] init];
    vc.wifiInfo = [self.wifiInfo copy];
    vc.roomId = self.roomId;
    vc.configHardwareStyle = self.configHardwareStyle;
    vc.connectGuideData = self.configdata;
    [self.navigationController pushViewController:vc animated:YES];
    
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
    CBPeripheral *device = self.blueDevices[indexPath.row];
    NSDictionary<NSString *,id> *advertisementData = self.originBlueDevices[device];
    if ([advertisementData.allKeys containsObject:@"kCBAdvDataManufacturerData"]) {
        NSData *manufacturerData = advertisementData[@"kCBAdvDataManufacturerData"];
        NSString *hexstr = [NSString transformStringWithData:manufacturerData];
        NSString *producthex = [hexstr substringWithRange:NSMakeRange(18, hexstr.length-18)];
        NSString *productstr = [NSString stringFromHexString:producthex];
        
        [self.blueManager connectBluetoothPeripheral:device];
        
        [self nextClick:nil];
    }
}




#pragma mark - BluetoothCentralManagerDelegate
//实时扫描外设（目前扫描10s）
//- (void)scanPerpheralsUpdatePerpherals:(NSArray<CBPeripheral *> *)perphersArr peripheralInfo:(NSMutableArray *)peripheralInfoArray {
//    self.blueDevices = perphersArr;
//    [self.collectionView reloadData];
//}

- (void)scanPerpheralsUpdatePerpherals:(NSDictionary<CBPeripheral *,NSDictionary<NSString *,id> *> *)perphersArr {
    self.originBlueDevices = perphersArr;
    
    self.blueDevices = perphersArr.allKeys;
    [self.collectionView reloadData];
}
//连接外设成功
- (void)connectBluetoothDeviceSucessWithPerpheral:(CBPeripheral *)connectedPerpheral withConnectedDevArray:(NSArray <CBPeripheral *>*)connectedDevArray {
    
}
//断开外设
- (void)disconnectBluetoothDeviceWithPerpheral:(CBPeripheral *)disconnectedPerpheral {
    
}

//发送数据后，蓝牙回调
- (void)updateData:(NSArray *)dataHexArray withCharacteristic:(CBCharacteristic *)characteristic pheropheralUUID:(NSString *)pheropheralUUID serviceUUID:(NSString *)serviceString {
    
}

@end
