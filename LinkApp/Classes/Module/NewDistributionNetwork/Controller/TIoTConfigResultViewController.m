//
//  TIoTConfigResultViewController.m
//  LinkApp
//
//  Created by Sun on 2020/7/30.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTConfigResultViewController.h"
#import "TIoTStartConfigViewController.h"

@interface TIoTConfigResultViewController ()

@end

@implementation TIoTConfigResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI{
    self.title = @"一键配网";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"new_distri_failure"];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(105.3*kScreenAllHeightScale + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.width.height.mas_equalTo(53.3);
    }];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = [UIColor blackColor];
    topicLabel.font = [UIFont wcPfMediumFontOfSize:17];
    topicLabel.text = @"配网失败";
    topicLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(15.4);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(280);
        make.height.mas_equalTo(24);
    }];
    
    UILabel *describeLabel = [[UILabel alloc] init];
    describeLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    describeLabel.font = [UIFont wcPfRegularFontOfSize:14];
    describeLabel.text = @"请检查以下信息";
    describeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:describeLabel];
    [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topicLabel.mas_bottom).offset(8);
        make.left.right.equalTo(topicLabel);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *stepLabel = [[UILabel alloc] init];
    NSString *stepLabelText = @"1. 确认设备处于一键配网模式（指示灯慢闪）\n2. 核对家庭WiFi密码是否正确\n3. 确认路由设备是否为2.4G WiFi频段";
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.lineSpacing = 6.0;
    // 字体: 大小 颜色 行间距
    NSAttributedString * attributedStr = [[NSAttributedString alloc]initWithString:stepLabelText attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:kRGBColor(136, 136, 136),NSParagraphStyleAttributeName:paragraph}];
    stepLabel.attributedText = attributedStr;
    stepLabel.numberOfLines = 0;
    [self.view addSubview:stepLabel];
    [stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(describeLabel.mas_bottom).offset(20);
        make.left.right.equalTo(topicLabel);
        make.height.mas_equalTo(72);
    }];
    
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeButton setTitle:@"切换到热点配网" forState:UIControlStateNormal];
    [changeButton setTitleColor:kMainColor forState:UIControlStateNormal];
    changeButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [changeButton addTarget:self action:@selector(changeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
    [changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(describeLabel.mas_bottom).offset(141*kScreenAllHeightScale);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(124);
        make.height.mas_equalTo(72);
    }];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:@"重试" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = kMainColor;
    nextBtn.layer.cornerRadius = 2;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(40);
        make.top.equalTo(changeButton.mas_bottom).offset(1);
        make.width.mas_equalTo(kScreenWidth - 80);
        make.height.mas_equalTo(45);
    }];
}

#pragma mark eventResponse

- (void)changeClick:(UIButton *)sender {
    TIoTStartConfigViewController *vc = [[TIoTStartConfigViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)nextClick:(UIButton *)sender {
    
}

@end
