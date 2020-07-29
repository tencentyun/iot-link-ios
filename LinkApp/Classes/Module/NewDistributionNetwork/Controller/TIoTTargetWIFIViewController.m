//
//  TIoTTargetWIFIViewController.m
//  LinkApp
//
//  Created by Sun on 2020/7/29.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTTargetWIFIViewController.h"
#import "TIoTStepTipView.h"
#import "TIoTConfigInputView.h"
#import "TIoTWIFIListView.h"

#import "TIoTWIFITipViewController.h"

@interface TIoTTargetWIFIViewController ()

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@property (nonatomic, strong) TIoTConfigInputView *wifiInputView;

@property (nonatomic, strong) TIoTConfigInputView *pwdInputView;

@property (nonatomic, strong) TIoTWIFIListView *wifiListView;

@end

@implementation TIoTTargetWIFIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI{
    self.title = @"一键配网";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.stepTipView = [[TIoTStepTipView alloc] initWithTitlesArray:@[@"配置硬件", @"选择目标WiFi", @"开始配网"]];
    self.stepTipView.step = 2;
    [self.view addSubview:self.stepTipView];
    [self.stepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20 + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(54);
    }];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = kRGBColor(51, 51, 51);
    topicLabel.font = [UIFont wcPfMediumFontOfSize:17];
    topicLabel.text = @"请输入WiFi密码";
    [self.view addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.top.equalTo(self.stepTipView.mas_bottom).offset(20);
        make.height.mas_equalTo(24);
    }];
    
    self.wifiInputView = [[TIoTConfigInputView alloc] initWithTitle:@"WIFI" placeholder:@"请点击箭头按钮选择WIFI" haveButton:YES];
    WeakObj(self)
    self.wifiInputView.buttonAction = ^{
        selfWeak.wifiListView = [[TIoTWIFIListView alloc] init];
        [[UIApplication sharedApplication].keyWindow addSubview:selfWeak.wifiListView];
        [selfWeak.wifiListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo([UIApplication sharedApplication].keyWindow);
        }];
    };
    self.wifiInputView.inputText = @"Tencent-GuestWiFi";
    [self.view addSubview:self.wifiInputView];
    [self.wifiInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topicLabel.mas_bottom).offset(20);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(56);
    }];
    
    self.pwdInputView = [[TIoTConfigInputView alloc] initWithTitle:@"密码" placeholder:@"请输入密码（非必填）" haveButton:NO];
    [self.view addSubview:self.pwdInputView];
    [self.pwdInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.wifiInputView);
        make.top.equalTo(self.wifiInputView.mas_bottom);
    }];
    
    UILabel *makeLabel = [[UILabel alloc] init];
    makeLabel.textColor = kRGBColor(51, 51, 51);
    makeLabel.font = [UIFont wcPfMediumFontOfSize:17];
    makeLabel.text = @"操作方式:";
    [self.view addSubview:makeLabel];
    
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
        make.top.equalTo(self.pwdInputView.mas_bottom).offset(264 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 80);
        make.height.mas_equalTo(45);
    }];
}

#pragma mark eventResponse

- (void)nextClick:(UIButton *)sender {
    TIoTWIFITipViewController *vc = [[TIoTWIFITipViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
