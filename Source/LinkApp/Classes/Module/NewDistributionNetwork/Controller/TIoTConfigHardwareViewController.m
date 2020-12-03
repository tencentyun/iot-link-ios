//
//  TIoTConfigHardwareViewController.m
//  LinkApp
//
//  Created by Sun on 2020/7/28.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTConfigHardwareViewController.h"
#import "TIoTStepTipView.h"
#import "TIoTTargetWIFIViewController.h"
#import "UIImageView+WebCache.h"

@interface TIoTConfigHardwareViewController ()

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, strong) NSString *networkToken;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *stepLabel;

@end

@implementation TIoTConfigHardwareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _networkToken = @"";
}

- (void)setupUI{
    self.title = [_dataDic objectForKey:@"title"];
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
        make.height.mas_equalTo(54);
    }];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = kRGBColor(51, 51, 51);
    topicLabel.font = [UIFont wcPfMediumFontOfSize:17];
    topicLabel.text = [_dataDic objectForKey:@"topic"];
    [self.scrollView addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(16);
        make.right.equalTo(self.scrollView).offset(-16);
        make.top.equalTo(self.stepTipView.mas_bottom).offset(20);
        make.height.mas_equalTo(24);
    }];
    
    
    
//    UIImageView *self.imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_distri_tip"]];
    self.imgView = [[UIImageView alloc] init];
        UIImageView *bgmImageView = nil;
        
        if (self.configHardwareStyle == TIoTConfigHardwareStyleSoftAP) {
            NSString *softAPImageUrlString = self.configurationData[@"WifiSoftAP"][@"hardwareGuide"][@"bgImg"];
            if ([NSString isNullOrNilWithObject:softAPImageUrlString]) {
                self.imgView.image = [UIImage imageNamed:@"new_distri_tip"];
                
                bgmImageView = [[UIImageView alloc]initWithImage:self.imgView.image];
            }else {
                [self.imgView setImageWithURLStr:softAPImageUrlString placeHolder:@"new_distri_tip"];
                bgmImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:softAPImageUrlString]]]];
            }
        }else if (self.configHardwareStyle == TIoTConfigHardwareStyleSmartConfig) {
            NSString *smartImageeUrlString = self.configurationData[@"WifiSmartConfig"][@"hardwareGuide"][@"bgImg"];
            if ([NSString isNullOrNilWithObject:smartImageeUrlString]) {
                self.imgView.image = [UIImage imageNamed:@"new_distri_tip"];
                bgmImageView = [[UIImageView alloc]initWithImage:self.imgView.image];
            }else {
                [self.imgView setImageWithURLStr:smartImageeUrlString placeHolder:@"new_distri_tip"];
                bgmImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:smartImageeUrlString]]]];
            }
            
        }
        
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
    if (self.configHardwareStyle == TIoTConfigHardwareStyleSoftAP) {
        exploreNextString = self.configurationData[@"WifiSoftAP"][@"hardwareGuide"][@"btnText"];
    }else if (self.configHardwareStyle == TIoTConfigHardwareStyleSmartConfig) {
        exploreNextString = self.configurationData[@"WifiSmartConfig"][@"hardwareGuide"][@"btnText"];
    }
    
    if ([NSString isNullOrNilWithObject:exploreNextString]) {
        exploreNextString = NSLocalizedString(@"next", @"下一步");
    }
    NSString *softApNextString = exploreNextString;

    [nextBtn setTitle: softApNextString forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = kMainColor;
    nextBtn.layer.cornerRadius = 2;
    [self.scrollView addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(40);
        make.top.equalTo(self.stepLabel.mas_bottom).offset(40 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 80);
        make.height.mas_equalTo(45);
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

        WCLog(@"AppCreateDeviceBindToken----responseObject==%@",responseObject);
        
        if (![NSObject isNullOrNilWithObject:responseObject[@"Token"]]) {
            self.networkToken = responseObject[@"Token"];
        }
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

        WCLog(@"AppCreateDeviceBindToken--reason==%@--error=%@",reason,reason);
    }];
}

#pragma mark eventResponse

- (void)nextClick:(UIButton *)sender {
    TIoTTargetWIFIViewController *vc = [[TIoTTargetWIFIViewController alloc] init];
    vc.step = 2;
    vc.configHardwareStyle = _configHardwareStyle;
    vc.currentDistributionToken = self.networkToken;
    vc.roomId = self.roomId;
    vc.configConnentData = self.configurationData;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark setter or getter

- (void)setConfigHardwareStyle:(TIoTConfigHardwareStyle)configHardwareStyle {
    _configHardwareStyle = configHardwareStyle;
    switch (configHardwareStyle) {
        case TIoTConfigHardwareStyleSoftAP: 
        {
            
            NSString *softAPExploreString = self.configurationData[@"WifiSoftAP"][@"hardwareGuide"][@"message"];
            if ([NSString isNullOrNilWithObject:softAPExploreString]) {
                softAPExploreString = @"1. 接通设备电源。\n2. 长按复位键（开关），切换设备配网模式到热点配网（不同设备操作方式有所不同）。\n3. 指示灯慢闪即进入热点配网模式。";
            }
            
            _dataDic = @{@"title": NSLocalizedString(@"softAP_distributionNetwork", @"热点配网"),
                         @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"setupTargetWiFi", @"设置目标WiFi"), NSLocalizedString(@"connected_device", @"连接设备"), NSLocalizedString(@"start_distributionNetwork", @"开始配网")],
                         @"topic": NSLocalizedString(@"setDevice_softAP_distributionNetwork", @"将设备设置为热点配网模式"),
                         @"stepDiscribe":softAPExploreString
            };
        }
            break;
            
        case TIoTConfigHardwareStyleSmartConfig:
        {
            NSString *smartExploreString = self.configurationData[@"WifiSmartConfig"][@"hardwareGuide"][@"message"];
            if ([NSString isNullOrNilWithObject:smartExploreString]) {
                smartExploreString = @"1. 接通设备电源。\n2. 长按复位键（开关），切换设备配网模式到一键配网（不同设备操作方式有所不同）。\n3. 指示灯快闪即进入一键配网模式。";
            }
            _dataDic = @{@"title": NSLocalizedString(@"smartConf_distributionNetwork", @"一键配网"),
                         @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"chooseTargetWiFi", @"选择目标WiFi"), NSLocalizedString(@"start_distributionNetwork", @"开始配网")],
                         @"topic": NSLocalizedString(@"setupDevoice_SmartConfig_distributionNetwork", @"将设备设置为一键配网模式"),
                         @"stepDiscribe": smartExploreString
            };
        }
            break;
            
        default:
            break;
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
