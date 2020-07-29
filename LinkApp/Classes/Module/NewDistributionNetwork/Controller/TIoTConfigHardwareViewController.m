//
//  TIoTConfigHardwareViewController.m
//  LinkApp
//
//  Created by Sun on 2020/7/28.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTConfigHardwareViewController.h"
#import "TIoTStepTipView.h"

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
    self.view.backgroundColor = kRGBColor(242, 242, 242);
    
    self.stepTipView = [[TIoTStepTipView alloc] init];
    [self.view addSubview:self.stepTipView];
    [self.stepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(80);
    }];
}

@end
