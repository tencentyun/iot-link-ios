//
//  TIoTMainVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/7/28.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTMainVC.h"
#import "TIoTRegisterViewController.h"
#import "TIoTVCLoginAccountVC.h"
#import "TIoTSingleCustomButton.h"
#import "UIButton+LQRelayout.h"

@interface TIoTMainVC ()
@property (nonatomic, strong) UIImageView   *headerImage;
@property (nonatomic, strong) UILabel       *welcomeLalel;
@property (nonatomic, strong) TIoTSingleCustomButton      *registButton;
@property (nonatomic, strong) UIButton      *loginButton;

@end

@implementation TIoTMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.headerImage];
    [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(100 * kScreenAllHeightScale);
        }else {
            make.top.equalTo(self.view).offset(64 + 100 * kScreenAllHeightScale);
        }
        make.centerX.equalTo(self.view);
        make.width.height.mas_equalTo(100 * kScreenAllHeightScale);
    }];
    
    [self.view addSubview:self.welcomeLalel];
    [self.welcomeLalel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerImage.mas_bottom).offset(20 * kScreenAllHeightScale);
        make.centerX.equalTo(self.view);
    }];
    
    CGFloat kLeftRightPadding = 16;
    CGFloat kHeightButton = 40;
    self.registButton.kLeftRightPadding = kLeftRightPadding;
    [self.view addSubview:self.registButton];
    [self.registButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.welcomeLalel.mas_bottom).offset(100 * kScreenAllHeightScale);
        make.height.mas_equalTo(kHeightButton);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.centerX.equalTo(self.view);
    }];
    
    [self.view addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.registButton.mas_bottom).offset(20 * kScreenAllHeightScale);
        make.height.equalTo(self.registButton);
        make.left.equalTo(self.view.mas_left).offset(kLeftRightPadding * kScreenAllHeightScale);
        make.right.equalTo(self.view.mas_right).offset(-kLeftRightPadding * kScreenAllHeightScale);
        make.centerX.equalTo(self.view);
    }];
}


- (UIImageView *)headerImage {
    if (!_headerImage) {
        _headerImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Main_logo"]];
        _headerImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _headerImage;
}

- (UILabel *)welcomeLalel {
    if (!_welcomeLalel) {
        _welcomeLalel = [[UILabel alloc]init];
        _welcomeLalel.text = NSLocalizedString(@"welcome_to_use_tencent_ll", @"欢迎使用腾讯连连");
        _welcomeLalel.textColor = [UIColor colorWithHexString:@"#6C7078"];
        _welcomeLalel.font = [UIFont wcPfRegularFontOfSize:20];
    }
    return _welcomeLalel;
}

- (TIoTSingleCustomButton *)registButton {
    if (!_registButton) {
        __weak typeof(self)weakSelf = self;
        _registButton = [[TIoTSingleCustomButton alloc]init];
        [_registButton singleCustomButtonStyle:SingleCustomButtonConfirm withTitle:NSLocalizedString(@"create_new_account", @"创建新账号")];
        _registButton.singleAction = ^{
            [weakSelf createNewAccount];
        };
    }
    return _registButton;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton addTarget:self action:@selector(loginOldAccount) forControlEvents:UIControlEventTouchUpInside];
        [_loginButton setBackgroundColor:[UIColor whiteColor]];
        [_loginButton setButtonFormateWithTitlt:NSLocalizedString(@"use_existed_account_to_login", @"使用已有账号登录") titleColorHexString:kIntelligentMainHexColor font:[UIFont wcPfRegularFontOfSize:16]];
        _loginButton.layer.borderWidth = 1;
        _loginButton.layer.borderColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
        _loginButton.layer.cornerRadius = 20;
    }
    return _loginButton;
}

- (void)createNewAccount {
    TIoTRegisterViewController *registerVC = [[TIoTRegisterViewController alloc]init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)loginOldAccount {
    TIoTVCLoginAccountVC *loginAccount = [[TIoTVCLoginAccountVC alloc]init];
    [self.navigationController pushViewController:loginAccount animated:YES];
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
