//
//  TIoTLLSyncViewController.m
//  LinkApp
//
//

#import "TIoTLLSyncViewController.h"
#import "TIoTStepTipView.h"
#import "TIoTTargetWIFIViewController.h"
#import "UIImageView+WebCache.h"



@interface TIoTLLSyncViewController ()

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, strong) NSString *networkToken;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *stepLabel;

@end

@implementation TIoTLLSyncViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _networkToken = @"";
    self.title = NSLocalizedString(@"llsync_network_title", @"蓝牙辅助配网");
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setConfigHardwareStyle:TIoTConfigHardwareStyleLLsync];
}


- (void)setupUI{
//    self.title = [_dataDic objectForKey:@"title"];
    self.title = NSLocalizedString(@"llsync_network_title", @"蓝牙辅助配网");
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64);
        }
        make.width.mas_equalTo(kScreenWidth);
    }];

    self.stepTipView = [[TIoTStepTipView alloc] initWithTitlesArray:[_dataDic objectForKey:@"stepTipArr"]];
    self.stepTipView.step = 1;
    [self.scrollView addSubview:self.stepTipView];
    [self.stepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView).offset(20);
        make.width.equalTo(self.scrollView);
        make.height.mas_equalTo(54+8);
    }];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = [UIColor colorWithHexString:kTemperatureHexColor];
    topicLabel.numberOfLines = 0;
    topicLabel.font = [UIFont wcPfMediumFontOfSize:16];
    topicLabel.text = [_dataDic objectForKey:@"topic"];
    [self.scrollView addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.stepTipView.mas_bottom).offset(20);
//        make.height.mas_equalTo(24);
    }];
    
    
    
    self.imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_distri_tip"]];
    UIImageView *bgmImageView = [[UIImageView alloc]initWithImage:self.imgView.image];

    CGFloat kImageHeight = bgmImageView.frame.size.height;
    CGFloat kImageWeitht = bgmImageView.frame.size.width;
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat kPadding = 16;
    [self.scrollView addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scrollView);
        make.leading.mas_greaterThanOrEqualTo(kPadding);
        make.trailing.mas_lessThanOrEqualTo(-kPadding);
        make.top.equalTo(topicLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(kImageHeight/kImageWeitht*(kScreenWidth-2*kPadding));
    }];
    
//    UILabel *tipLabel = [[UILabel alloc] init];
//    tipLabel.textColor = kRGBColor(166, 166, 166);
//    tipLabel.font = [UIFont wcPfRegularFontOfSize:12];
//    tipLabel.text = @"若指示灯已经在快闪，可以跳过该步骤。";
//    [self.view addSubview:tipLabel];
//    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(16);
//        make.right.equalTo(self.view).offset(-16);
//        make.top.equalTo(self.imgView.mas_bottom).offset(10);
//        make.height.mas_equalTo(24);
//    }];
    
    self.stepLabel = [[UILabel alloc] init];
    NSString *stepLabelText = [_dataDic objectForKey:@"stepDiscribe"];
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.lineSpacing = 6.0;
    // 字体: 大小 颜色 行间距
    NSAttributedString * attributedStr = [[NSAttributedString alloc]initWithString:stepLabelText attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:kRGBColor(51, 51, 51),NSParagraphStyleAttributeName:paragraph}];
    self.stepLabel.attributedText = attributedStr;
    self.stepLabel.numberOfLines = 0;
    [self.scrollView addSubview:self.stepLabel];
    [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgView);
        make.right.equalTo(self.imgView);
        make.top.equalTo(self.imgView.mas_bottom).offset(10);
    }];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *exploreNextString = @"";
    if ([NSString isNullOrNilWithObject:exploreNextString]) {
        exploreNextString = NSLocalizedString(@"next", @"下一步");
    }
    NSString *softApNextString = exploreNextString;

    [nextBtn setTitle: softApNextString forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    nextBtn.layer.cornerRadius = 20;
    [self.scrollView addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(16);
        make.top.equalTo(self.stepLabel.mas_bottom).offset(40 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 32);
        make.height.mas_equalTo(40);
    }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGFloat contentHeight = 100 + 54 + 24 + CGRectGetHeight(self.imgView.frame)+ CGRectGetHeight(self.stepLabel.frame) + 45 + [TIoTUIProxy shareUIProxy].navigationBarHeight;
    if (contentHeight > kScreenHeight) {
        self.scrollView.scrollEnabled = YES;
    }else {
        self.scrollView.scrollEnabled = NO;
    }
    self.scrollView.contentSize = CGSizeMake(kScreenWidth,contentHeight);
}

- (void)getSoftApToken {
    [[TIoTRequestObject shared] post:AppCreateDeviceBindToken Param:@{} success:^(id responseObject) {

        DDLogInfo(@"AppCreateDeviceBindToken----responseObject==%@",responseObject);
        
        if (![NSObject isNullOrNilWithObject:responseObject[@"Token"]]) {
            self.networkToken = responseObject[@"Token"];
        }
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

        DDLogError(@"AppCreateDeviceBindToken--reason==%@--error=%@",reason,reason);
    }];
}

#pragma mark eventResponse

- (void)nav_customBack {
     //配网失败，切换配网方式时候，再新的配网流程中，用来判断返回首页还是上个页面
//    if (self.isDistributeNetFailure == YES) {
        // 查找导航栏里的控制器数组,找到返回查找的控制器,没找到返回nil;
        UIViewController *vc = [self findViewController:@"TIoTNewAddEquipmentViewController"];
        if (vc) {
            // 找到需要返回的控制器的处理方式
            [self.navigationController popToViewController:vc animated:YES];
        }else{
            // 没找到需要返回的控制器的处理方式
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
//    }else {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

- (id)findViewController:(NSString*)className{
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:NSClassFromString(className)]) {
            return viewController;
        }
    }
    return nil;
}

- (void)nextClick:(UIButton *)sender {
    TIoTTargetWIFIViewController *vc = [[TIoTTargetWIFIViewController alloc] init];
    vc.llsyncDeviceVC = self.llsyncDeviceVC;
    vc.step = 2;
    vc.configConnentData = self.configurationData;
    vc.currentDistributionToken = self.networkToken;
    vc.roomId = self.roomId;
    vc.configHardwareStyle = TIoTConfigHardwareStyleLLsync;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark setter or getter

- (void)setConfigHardwareStyle:(TIoTConfigHardwareStyle)configHardwareStyle {
    _configHardwareStyle = configHardwareStyle;
            
    NSString *softAPExploreString = self.configurationData[@"WifiLLSyncBle"][@"hardwareGuide"][@"message"];
    if ([NSString isNullOrNilWithObject:softAPExploreString]) {
        softAPExploreString = NSLocalizedString(@"default_bleConfig_tip", @"1. 接通设备电源。\n2. 长按复位键（开关），指示灯慢闪。\n3. 点击“下一步”开始蓝牙辅助配网。");
    }
    
    _dataDic = @{@"title": NSLocalizedString(@"llsync_network_title", @"蓝牙辅助配网"),
                 @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"setupTargetWiFi", @"设置目标WiFi"), NSLocalizedString(@"connected_device", @"连接设备"), NSLocalizedString(@"start_distributionNetwork", @"开始配网")],
                 @"topic": NSLocalizedString(@"setDevice_softAP_distributionNetwork", @"将设备设置为热点配网模式"),
                 @"stepDiscribe":softAPExploreString
    };
    
    if (self.llsyncDeviceVC) {
        NSString *smartExploreString = self.configurationData[@"WifiLLSyncBle"][@"hardwareGuide"][@"message"];
        if ([NSString isNullOrNilWithObject:smartExploreString]) {
            smartExploreString = NSLocalizedString(@"default_bleConfig_tip", @"1. 接通设备电源。\n2. 长按复位键（开关），指示灯慢闪。\n3. 点击“下一步”开始蓝牙辅助配网。");
        }
        
        _dataDic = @{@"title": NSLocalizedString(@"smartConf_distributionNetwork", @"一键配网"),
                     @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"chooseTargetWiFi", @"选择目标WiFi"), NSLocalizedString(@"start_distributionNetwork", @"开始配网")],
                     @"topic": NSLocalizedString(@"setupDevoice_SmartConfig_distributionNetwork", @"将设备设置为一键配网模式"),
                     @"stepDiscribe": smartExploreString
        };
    }
    
    [self setupUI];
    [self getSoftApToken];
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    return _scrollView;
}

@end
