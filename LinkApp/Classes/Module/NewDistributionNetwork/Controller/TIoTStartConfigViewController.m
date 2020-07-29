//
//  TIoTStartConfigViewController.m
//  LinkApp
//
//  Created by Sun on 2020/7/30.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTStartConfigViewController.h"
#import "TIoTStepTipView.h"
#import "TIoTConnectStepTipView.h"

@interface TIoTStartConfigViewController ()

@property (nonatomic, strong) TIoTStepTipView *stepTipView;

@property (nonatomic, strong) TIoTConnectStepTipView *connectStepTipView;

@end

@implementation TIoTStartConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self performSelector:@selector(clock4Timer:) withObject:@(1) afterDelay:3.0f];
}

- (void)setupUI{
    self.title = @"一键配网";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.stepTipView = [[TIoTStepTipView alloc] initWithTitlesArray:@[@"配置硬件", @"选择目标WiFi", @"开始配网"]];
    self.stepTipView.step = 3;
    [self.view addSubview:self.stepTipView];
    [self.stepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20 + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(54);
    }];
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"new_distri_connect"];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stepTipView.mas_bottom).offset(103*kScreenAllHeightScale);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(203);
        make.height.mas_equalTo(100);
    }];
    
    self.connectStepTipView = [[TIoTConnectStepTipView alloc] initWithTitlesArray:@[@"手机与设备连接成功", @"向设备发送信息成功", @"设备连接云端成功", @"初始化成功"]];
    [self.view addSubview:self.connectStepTipView];
    [self.connectStepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(50);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(166);
        make.height.mas_equalTo(114);
    }];
}

- (void)clock4Timer:(NSNumber *)count {
    if (count.intValue > 4) {
        return;
    } else {
        self.connectStepTipView.step = count.intValue;
        [self performSelector:@selector(clock4Timer:) withObject:@(count.intValue+1) afterDelay:3.0f];
    }
}

@end
