//
//  TIoTLLSyncViewController.m
//  LinkApp
//
//

#import "TIoTLLSyncViewController.h"
#import "TIoTStepTipView.h"
#import "TIoTTargetWIFIViewController.h"
#import "UIImageView+WebCache.h"
#import "TIoTLLSyncChooseDeviceVC.h"

@interface TIoTLLSyncViewController ()

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, strong) NSString *networkToken;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *stepLabel;

@property (nonatomic, strong) UIView *backMaskView; //重置设备教程弹框背景遮罩
@end

@implementation TIoTLLSyncViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _networkToken = @"";
    self.title = self.isPureBleLLSyncType? NSLocalizedString(@"standard_ble_binding", @"标准蓝牙设备绑定"): NSLocalizedString(@"llsync_network_title", @"蓝牙辅助配网");
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setConfigHardwareStyle:TIoTConfigHardwareStyleLLsync];
}


- (void)setupUI{
//    self.title = [_dataDic objectForKey:@"title"];
    self.title = self.isPureBleLLSyncType? NSLocalizedString(@"standard_ble_binding", @"标准蓝牙设备绑定"): NSLocalizedString(@"llsync_network_title", @"蓝牙辅助配网");
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
    
    UILabel *topicDetLabel = [[UILabel alloc]init];
    UIButton *resetCourseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (self.isPureBleLLSyncType == YES) { //纯蓝牙设备显示
        //字体: 大小 颜色 行间距
        NSMutableParagraphStyle *pureBleparagraph = [[NSMutableParagraphStyle alloc]init];
        pureBleparagraph.lineSpacing = 6.0;
        NSAttributedString *pureBleattributedStr = [[NSAttributedString alloc]initWithString:[_dataDic objectForKey:@"topicDes"] attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:kRGBColor(51, 51, 51),NSParagraphStyleAttributeName:pureBleparagraph}];
        topicDetLabel.attributedText = pureBleattributedStr;
        topicDetLabel.numberOfLines = 0;
        [self.scrollView addSubview:topicDetLabel];
        [topicDetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(topicLabel);
            make.top.equalTo(topicLabel.mas_bottom).offset(5);
        }];
        
        [resetCourseButton setTitle:[_dataDic objectForKey:@"resetCource"] forState:UIControlStateNormal];
        [resetCourseButton setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        resetCourseButton.titleLabel.font = [UIFont wcPfMediumFontOfSize:14];
        [resetCourseButton addTarget:self action:@selector(resetDevcieCource) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:resetCourseButton];
        [resetCourseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(topicLabel.mas_left);
            make.top.equalTo(topicDetLabel.mas_bottom);
        }];
    }
    
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
        if (self.isPureBleLLSyncType == YES) {
            make.top.equalTo(resetCourseButton.mas_bottom).offset(10);
        }else {
            make.top.equalTo(topicLabel.mas_bottom).offset(10);
        }
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
    if (self.isPureBleLLSyncType == NO) {
        // 辅助蓝牙设备绑定
        TIoTTargetWIFIViewController *vc = [[TIoTTargetWIFIViewController alloc] init];
        vc.llsyncDeviceVC = self.llsyncDeviceVC;
        vc.step = 2;
        vc.configConnentData = self.configurationData;
        vc.currentDistributionToken = self.networkToken;
        vc.roomId = self.roomId;
        vc.configHardwareStyle = TIoTConfigHardwareStyleLLsync;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        
        if (self.isFromProductsList) {
            //从发现设备页产品类别中跳转过来的
            TIoTLLSyncChooseDeviceVC *choiceDevice = [[TIoTLLSyncChooseDeviceVC alloc]init];
            choiceDevice.configHardwareStyle = TIoTConfigHardwareStylePureBleLLsync;
            choiceDevice.llsyncDeviceVC = self.llsyncDeviceVC;
            choiceDevice.roomId = self.roomId;
            choiceDevice.currentDistributionToken = self.networkToken;
            choiceDevice.configdata = self.configurationData;
            choiceDevice.isFromProductsList = self.isFromProductsList;
            [self.navigationController pushViewController:choiceDevice animated:YES];
            
        }else {
            //纯蓝牙LLSync设备绑定
            NSDictionary * wifiInfo = @{@"token":self.networkToken?:@""};
            TIoTStartConfigViewController *vc = [[TIoTStartConfigViewController alloc] init];
            vc.wifiInfo = wifiInfo;
            vc.roomId = self.roomId;
            vc.configHardwareStyle = TIoTConfigHardwareStylePureBleLLsync;
            vc.connectGuideData = self.configurationData;
            [self.navigationController pushViewController:vc animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.llsyncDeviceVC.configHardwareStyle = TIoTConfigHardwareStyleLLsync;
                self.llsyncDeviceVC.roomId = self.roomId;
                self.llsyncDeviceVC.currentDistributionToken = self.networkToken;
                self.llsyncDeviceVC.wifiInfo = wifiInfo;
                self.llsyncDeviceVC.connectGuideData = self.configurationData[@"WifiSoftAP"][@"connectApGuide"]?:@{};
                self.llsyncDeviceVC.configdata = self.configurationData;
                [self.llsyncDeviceVC startConnectLLSync:vc];
            });
            
        }
    }
}

///MARK:重置设备教程
- (void)resetDevcieCource {
//    __weak typeof(self) weakself = self;
    TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds withTopImage:nil];
    [av alertWithTitle:NSLocalizedString(@"reset_device_course", @"重置设备教程") message:NSLocalizedString(@"reset_device_course_describe", @"请打开手机蓝牙功能，并将待绑定的BLE设备置于可发现状态")
           cancleTitlt:@"" doneTitle:NSLocalizedString(@"verify", @"确认")];
    [av showSingleConfrimButton];
    av.doneAction = ^(NSString * _Nonnull text) {
        
    };
    
    self.backMaskView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].delegate.window.frame];
    [[UIApplication sharedApplication].delegate.window addSubview:self.backMaskView];
    [av showInView:self.backMaskView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAlertView)];
    [self.backMaskView addGestureRecognizer:tap];
}

- (void)hideAlertView {
    if (self.backMaskView != nil) {
        [self.backMaskView removeFromSuperview];
    }
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
    
    if (self.isPureBleLLSyncType) {
        _configHardwareStyle = TIoTConfigHardwareStylePureBleLLsync;
        
        _dataDic = @{@"title":NSLocalizedString(@"standard_ble_binding", @"标准蓝牙设备绑定"),
                     @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"start_binding", @"开始绑定")],
                     @"topic": NSLocalizedString(@"default_pureble_reset_tip", @"重置设备"),
                     @"topicDes": NSLocalizedString(@"default_pureble_reset_detail_tip", @"1. 设备保持电量充足。\n2. 长按复位键（开关），重新进入配对。"),
                     @"resetCource":[NSString stringWithFormat:@"%@ >",NSLocalizedString(@"reset_device_course", @"重置设备教程")],
                     @"stepDiscribe": @""
        };
    }
    
    if (self.isFromProductsList) {
        
        _dataDic = @{@"title":NSLocalizedString(@"standard_ble_binding", @"标准蓝牙设备绑定"),
                     @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"selected_Device",  @"选择设备"), NSLocalizedString(@"start_binding", @"开始绑定")],
                     @"topic": NSLocalizedString(@"default_pureble_reset_tip", @"重置设备"),
                     @"topicDes": NSLocalizedString(@"default_pureble_reset_detail_tip", @"1. 设备保持电量充足。\n2. 长按复位键（开关），重新进入配对。"),
                     @"resetCource":[NSString stringWithFormat:@"%@ >",NSLocalizedString(@"reset_device_course", @"重置设备教程")],
                     @"stepDiscribe": @""
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
