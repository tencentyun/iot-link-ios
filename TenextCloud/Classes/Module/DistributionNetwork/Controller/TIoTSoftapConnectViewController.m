//
//  WCSoftapConnectViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTSoftapConnectViewController.h"
#import "TIoTSoftapWaitVC.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>
#import "UIImage+Ex.h"

@interface TIoTSoftapConnectViewController ()

@property (nonatomic,strong) UIButton *connectB;//连接按钮
@property (nonatomic,strong) UIButton *nextB;//下一步按钮

@end

@implementation TIoTSoftapConnectViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePage) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self setupUI];
    
}

#pragma mark privateMethods
- (void)setupUI{
    self.view.backgroundColor = kBgColor;
    self.title = @"自助配网";
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [cancleBtn sizeToFit];
    UIBarButtonItem *cancleItem = [[UIBarButtonItem alloc] initWithCustomView:cancleBtn];
    self.navigationItem.leftBarButtonItems  = @[cancleItem];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:scroll];
    
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.text = @"将手机Wi-Fi连接设备热点";
    tipLab.textColor = kRGBColor(51, 51, 51);
    tipLab.font = [UIFont wcPfSemiboldFontOfSize:20];
    [scroll addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scroll).offset(20);
        make.top.equalTo(scroll).offset(30);
    }];
    
    
    UILabel *tip1 = [[UILabel alloc] init];
    tip1.text = @"1、手机WIFI连接到如下图所示的设备热点";
    tip1.textColor = kRGBColor(51, 51, 51);
    tip1.font = [UIFont wcPfRegularFontOfSize:16];
    [scroll addSubview:tip1];
    [tip1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(scroll).offset(20);
        make.top.equalTo(tipLab.mas_bottom).offset(30);
    }];
    
    
    UIImageView *tipImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor redColor]]];
    [tipImageView setImage:[UIImage imageNamed:@"wifieg"]];
    tipImageView.contentMode = UIViewContentModeCenter;
    [scroll addSubview:tipImageView];
    [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tip1.mas_bottom).offset(20);
        make.centerX.equalTo(scroll);
        make.left.equalTo(scroll).offset(30).priorityLow();
        make.right.equalTo(scroll).offset(-30).priorityLow();
//        make.height.mas_equalTo(200);
    }];
    
    
    UILabel *tip2 = [[UILabel alloc] init];
    tip2.text = @"2、返回APP,添加设备";
    tip2.textColor = kRGBColor(51, 51, 51);
    tip2.font = [UIFont wcPfRegularFontOfSize:16];
    [scroll addSubview:tip2];
    [tip2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(scroll).offset(20);
        make.top.equalTo(tipImageView.mas_bottom).offset(20);
    }];
    
    
    UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [connectBtn setTitle:@"连接设备热点" forState:UIControlStateNormal];
    [connectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    connectBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [connectBtn addTarget:self action:@selector(connectClick:) forControlEvents:UIControlEventTouchUpInside];
    connectBtn.backgroundColor = kMainColor;
    connectBtn.layer.cornerRadius = 3;
    [scroll addSubview:connectBtn];
    self.connectB = connectBtn;
    [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scroll).offset(30);
        make.top.equalTo(tip2.mas_bottom).offset(70 * kScreenAllHeightScale);
        make.width.mas_equalTo(kScreenWidth - 60);
        make.height.mas_equalTo(48);
    }];
    
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:@"连接正确，进入下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = kMainColor;
    nextBtn.layer.cornerRadius = 3;
    nextBtn.hidden = YES;
    [scroll addSubview:nextBtn];
    self.nextB = nextBtn;
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scroll).offset(30);
        make.top.equalTo(connectBtn.mas_bottom).offset(kScreenAllHeightScale * 30);
        make.width.mas_equalTo(kScreenWidth - 60);
        make.height.mas_equalTo(48);
        make.bottom.equalTo(scroll.mas_bottom).offset(-20);
    }];
    
 }


- (void)updatePage
{
    self.connectB.backgroundColor = [UIColor whiteColor];
    [self.connectB setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.connectB setTitle:@"重新连接" forState:UIControlStateNormal];
    self.connectB.layer.borderColor = kRGBColor(221, 221, 221).CGColor;
    self.connectB.layer.borderWidth = 1.0;
    
    self.nextB.hidden = NO;
}

#pragma mark eventResponse
- (void)connectClick:(id)sender{
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//    NSURL *url = [NSURL URLWithString:@"App-prefs:root=WIFI"];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)nextClick:(id)sender{
    TIoTSoftapWaitVC *vc = [[TIoTSoftapWaitVC alloc] init];
    vc.title = @"soft ap配网";
    vc.wifiInfo = self.wifiInfo.copy;
    vc.roomId = self.roomId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancleClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
