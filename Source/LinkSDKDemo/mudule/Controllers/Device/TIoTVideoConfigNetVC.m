//
//  TIoTVideoConfigNetVC.m
//  TIoTLinkKitDemo
//
//  Created by ccharlesren on 2020/12/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTVideoConfigNetVC.h"
#import "TIoTVIdeoQRScanDistributionNet.h"
#import "UIButton+LQRelayout.h"
#import "UIColor+Color.h"
#import "TIoTVideoSoftApDistributionNetVC.h"
#import "TIoTWiredDistributionNetVC.h"

@interface TIoTVideoConfigNetVC ()

@end

@implementation TIoTVideoConfigNetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat kWidth  = 200;
    CGFloat kHeight = 50;
    CGFloat kLeftPaddin = (kScreenWidth - kWidth)/2;
    CGFloat kTopPadding = 40 + kNavBarAndStatusBarHeight;
    CGFloat kInterval = 10;
    
    UIButton *QRScanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    QRScanButton.frame = CGRectMake(kLeftPaddin, kTopPadding, kWidth, kHeight);
    [self setButtonWithTitlt:@"扫码配网" titleColorHexString:kMainThemeColor font:[UIFont systemFontOfSize:18] withButton:QRScanButton];
    [QRScanButton addTarget:self action:@selector(jumpQRScanConfigVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:QRScanButton];
    
    UIButton *softApButton = [UIButton buttonWithType:UIButtonTypeCustom];
    softApButton.frame = CGRectMake(kLeftPaddin, CGRectGetMaxY(QRScanButton.frame)+kInterval, kWidth, kHeight);
    [self setButtonWithTitlt:@"Ap配网" titleColorHexString:kMainThemeColor font:[UIFont systemFontOfSize:18] withButton:softApButton];
    [softApButton addTarget:self action:@selector(jumpSoftApConfigVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:softApButton];
    
    UIButton *wiredButton = [UIButton buttonWithType:UIButtonTypeCustom];
    wiredButton.frame = CGRectMake(kLeftPaddin, CGRectGetMaxY(softApButton.frame)+kInterval, kWidth, kHeight);
    [self setButtonWithTitlt:@"有线配网" titleColorHexString:kMainThemeColor font:[UIFont systemFontOfSize:18] withButton:wiredButton];
    [wiredButton addTarget:self action:@selector(jumpWiredConfigVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wiredButton];
}

- (void)setButtonWithTitlt:(NSString *)titlt titleColorHexString:(NSString *)titleColorString font:(UIFont *)font withButton:(UIButton *)button {
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitle:titlt forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:titleColorString] forState:UIControlStateNormal];
    button.titleLabel.font = font;
    button.layer.borderWidth = 1;
    button.layer.borderColor = kMainColor.CGColor;
    button.layer.cornerRadius = 20;
}

- (void)jumpQRScanConfigVC {
    TIoTVIdeoQRScanDistributionNet *QRScaneVC = [[TIoTVIdeoQRScanDistributionNet alloc]init];
    [self.navigationController pushViewController:QRScaneVC animated:YES];
}

- (void)jumpSoftApConfigVC {
    TIoTVideoSoftApDistributionNetVC *softApVC = [[TIoTVideoSoftApDistributionNetVC alloc]init];
    [self.navigationController pushViewController:softApVC animated:YES];
}

- (void)jumpWiredConfigVC {
    TIoTWiredDistributionNetVC *wiredVC = [[TIoTWiredDistributionNetVC alloc]init];
    [self.navigationController pushViewController:wiredVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
