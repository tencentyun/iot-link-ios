//
//  TIoTDeviceWIFITipViewController.m
//  LinkApp
//
//  Created by Sun on 2020/8/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTDeviceWIFITipViewController.h"
#import "TIoTStepTipView.h"
#import "TIoTTargetWIFIViewController.h"

@interface TIoTDeviceWIFITipViewController ()

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *stepLabel;

@end

@implementation TIoTDeviceWIFITipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
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
        make.width.equalTo(self.scrollView);
        make.height.mas_equalTo(54);
    }];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = kRGBColor(51, 51, 51);
    topicLabel.font = [UIFont wcPfMediumFontOfSize:17];
    topicLabel.text = [self.dataDic objectForKey:@"topic"];
    [self.scrollView addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).offset(16);
        make.right.equalTo(self.scrollView).offset(-16);
        make.top.equalTo(self.stepTipView.mas_bottom).offset(20);
        make.height.mas_equalTo(24);
    }];

    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"wifieg"];
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topicLabel.mas_bottom).offset(20);
        make.left.equalTo(self.scrollView).offset(20);
        make.right.equalTo(self.scrollView).offset(-20);
        make.height.mas_equalTo(self.imageView.mas_width).multipliedBy(0.8667);
    }];
    
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
        make.left.right.equalTo(self.imageView);
        make.top.equalTo(self.imageView.mas_bottom).offset(20);
    }];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:NSLocalizedString(@"next", @"下一步") forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.layer.cornerRadius = 2;
    nextBtn.backgroundColor = kMainColor;
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
    
    CGFloat contentHeight = 120 + 54 + 24 + CGRectGetHeight(self.imageView.frame)+ CGRectGetHeight(self.stepLabel.frame) + 45 + [TIoTUIProxy shareUIProxy].navigationBarHeight;
    if (contentHeight > kScreenHeight) {
        self.scrollView.scrollEnabled = YES;
    }else {
        self.scrollView.scrollEnabled = NO;
    }
    self.scrollView.contentSize = CGSizeMake(kScreenWidth,contentHeight);
}

- (void)nextClick:(UIButton *)sender {
    
    TIoTTargetWIFIViewController *vc = [[TIoTTargetWIFIViewController alloc] init];
    vc.step = 3;
    vc.configHardwareStyle = _configHardwareStyle;
    vc.roomId = self.roomId;
    vc.currentDistributionToken = self.currentDistributionToken;
    vc.softApWifiInfo = [self.wifiInfo copy];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark setter or getter

- (NSDictionary *)dataDic {
    if (!_dataDic) {
        
        NSString *guideDiscirbe = self.connectGuideData[@"message"] ? : NSLocalizedString(@"leavefor_setupWIFI_connectDevice", @"请前往手机WiFi设置界面，连接上图所示设备WiFi");
        _dataDic = @{@"title": NSLocalizedString(@"softAP_distributionNetwork", @"热点配网"),
                     @"stepTipArr": @[NSLocalizedString(@"setHardware",  @"配置硬件"), NSLocalizedString(@"setupTargetWiFi", @"设置目标WiFi"), NSLocalizedString(@"connected_device", @"连接设备"), NSLocalizedString(@"start_distributionNetwork", @"开始配网")],
                     @"topic": NSLocalizedString(@"soft_ap_hotspot_set", @"将手机WiFi连接设备热点"),
                     @"stepDiscribe": guideDiscirbe
        };
    }
    return _dataDic;
}

@end
