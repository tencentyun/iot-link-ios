//
//  TIoTWIFITipViewController.m
//  LinkApp
//
//  Created by Sun on 2020/7/30.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTWIFITipViewController.h"
#import "TIoTTargetWIFIViewController.h"
#import "UIImage+Ex.h"

@interface TIoTWIFITipViewController ()

@end

@implementation TIoTWIFITipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = [UIColor blackColor];
    topicLabel.font = [UIFont wcPfMediumFontOfSize:17];
    topicLabel.text = NSLocalizedString(@"iOSWIFIRefresh_course", @"iOS WiFi刷新教程");
    [self.view addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10 + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.left.equalTo(self.view).offset(20.5);
        make.right.equalTo(self.view).offset(-20.5);
        make.height.mas_equalTo(24);
    }];
    
    UILabel *describeLabel = [[UILabel alloc] init];
    describeLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    describeLabel.font = [UIFont wcPfRegularFontOfSize:14];
    describeLabel.text = NSLocalizedString(@"finishFourSteps_refreshWIFI", @"完成以下4个步骤，就可以刷新WiFi了");
    [self.view addSubview:describeLabel];
    [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topicLabel.mas_bottom);
        make.left.right.equalTo(topicLabel);
        make.height.mas_equalTo(20);
    }];

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"new_distri_wifi_tip"];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(describeLabel.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(imageView.mas_width).multipliedBy(1.322);
    }];

    UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectButton setImage:[UIImage imageNamed:@"new_distri_check"] forState:UIControlStateSelected];
    [selectButton setImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    selectButton.layer.borderWidth = 0.5f;
    selectButton.layer.borderColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
    selectButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:selectButton];
    [selectButton addTarget:self action:@selector(selectClick:) forControlEvents:UIControlEventTouchUpInside];
    [selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(8.5);
        make.left.equalTo(self.view).offset(20);
        make.width.height.mas_equalTo(20);
    }];

    UILabel *selectLabel = [[UILabel alloc] init];
    selectLabel.textColor = kRGBColor(166, 166, 166);
    selectLabel.font = [UIFont wcPfRegularFontOfSize:12];
    selectLabel.text = NSLocalizedString(@"nextNoTip_refrsh", @"下次不再提示，直接去刷新");
    [self.view addSubview:selectLabel];
    [selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(selectButton);
        make.left.equalTo(selectButton.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-20);
    }];

    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshBtn setTitle:NSLocalizedString(@"know_refresh", @"看懂了，去刷新") forState:UIControlStateNormal];
    [refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    refreshBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [refreshBtn addTarget:self action:@selector(refreshClick:) forControlEvents:UIControlEventTouchUpInside];
    refreshBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    refreshBtn.layer.cornerRadius = 2;
    [self.view addSubview:refreshBtn];
    [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(40);
        make.top.equalTo(selectButton.mas_bottom).offset(10);
        make.width.mas_equalTo(kScreenWidth - 80);
        make.height.mas_equalTo(45);
    }];
    
}

#pragma mark eventResponse

- (void)refreshClick:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
    // 查找导航栏里的控制器数组,找到返回查找的控制器,没找到返回nil;
    TIoTTargetWIFIViewController *vc = [self findViewController:NSStringFromClass([TIoTTargetWIFIViewController class])];
    if (vc) {
        // 找到需要返回的控制器的处理方式
        [vc showWiFiListView];
        [self.navigationController popToViewController:vc animated:YES];
    }else{
        // 没找到需要返回的控制器的处理方式
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (void)selectClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sender.selected forKey:@"wifi_tip_konwn"];
    [defaults synchronize];
}

-(id)findViewController:(NSString*)className{
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:NSClassFromString(className)]) {
            return viewController;
        }
    }
    return nil;
}

@end
