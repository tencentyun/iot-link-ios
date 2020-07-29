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

@interface TIoTConfigHardwareViewController ()

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@end

@implementation TIoTConfigHardwareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI{
    self.title = @"一键配网";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.stepTipView = [[TIoTStepTipView alloc] initWithTitlesArray:@[@"配置硬件", @"选择目标WiFi", @"开始配网"]];
    self.stepTipView.step = 1;
    [self.view addSubview:self.stepTipView];
    [self.stepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20 + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(54);
    }];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = kRGBColor(51, 51, 51);
    topicLabel.font = [UIFont wcPfMediumFontOfSize:17];
    topicLabel.text = @"将设备设置为一键配网模式";
    [self.view addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.top.equalTo(self.stepTipView.mas_bottom).offset(20);
        make.height.mas_equalTo(24);
    }];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_distri_tip"]];
    [self.view addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.leading.mas_greaterThanOrEqualTo(16);
        make.trailing.mas_lessThanOrEqualTo(-16);
        make.top.equalTo(topicLabel.mas_bottom).offset(10);
    }];
    
//    UILabel *tipLabel = [[UILabel alloc] init];
//    tipLabel.textColor = kRGBColor(166, 166, 166);
//    tipLabel.font = [UIFont wcPfRegularFontOfSize:12];
//    tipLabel.text = @"若指示灯已经在快闪，可以跳过该步骤。";
//    [self.view addSubview:tipLabel];
//    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(16);
//        make.right.equalTo(self.view).offset(-16);
//        make.top.equalTo(imgView.mas_bottom).offset(10);
//        make.height.mas_equalTo(24);
//    }];
    
    UILabel *stepLabel = [[UILabel alloc] init];
    NSString *stepLabelText = @"1. 接通设备电源。\n2. 长按复位键（开关），切换设备配网模式到一键配网（不同设备操作方式有所不同）。\n3. 指示灯快闪即进入一键配网模式。";
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.lineSpacing = 6.0;
    // 字体: 大小 颜色 行间距
    NSAttributedString * attributedStr = [[NSAttributedString alloc]initWithString:stepLabelText attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:kRGBColor(51, 51, 51),NSParagraphStyleAttributeName:paragraph}];
    stepLabel.attributedText = attributedStr;
    stepLabel.numberOfLines = 0;
    [self.view addSubview:stepLabel];
    [stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-19);
        make.top.equalTo(imgView.mas_bottom).offset(10);
    }];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = kMainColor;
    nextBtn.layer.cornerRadius = 2;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(40);
        make.top.equalTo(stepLabel.mas_bottom).offset(40 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 80);
        make.height.mas_equalTo(45);
    }];
}

#pragma mark eventResponse

- (void)nextClick:(UIButton *)sender {
    TIoTTargetWIFIViewController *vc = [[TIoTTargetWIFIViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
