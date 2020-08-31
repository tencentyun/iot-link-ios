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

@interface TIoTMainVC ()
@property (nonatomic, strong) UIImageView   *headerImage;
@property (nonatomic, strong) UILabel       *welcomeLalel;
@property (nonatomic, strong) UIButton      *registButton;
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
    
    [self.view addSubview:self.registButton];
    [self.registButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.welcomeLalel.mas_bottom).offset(133 * kScreenAllHeightScale);
        make.height.mas_equalTo(45);
        make.left.equalTo(self.view.mas_left).offset(30 * kScreenAllWidthScale);
        make.right.equalTo(self.view.mas_right).offset(-30 * kScreenAllWidthScale);
        make.centerX.equalTo(self.view);
    }];
    
    [self.view addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.registButton.mas_bottom).offset(40 * kScreenAllHeightScale);
        make.centerX.equalTo(self.view);
    }];
}


- (UIImageView *)headerImage {
    if (!_headerImage) {
        _headerImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
        _headerImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _headerImage;
}

- (UILabel *)welcomeLalel {
    if (!_welcomeLalel) {
        _welcomeLalel = [[UILabel alloc]init];
        _welcomeLalel.text = @"欢迎使用腾讯连连";
        _welcomeLalel.textColor = [UIColor colorWithHexString:@"#444444"];
        _welcomeLalel.font = [UIFont wcPfRegularFontOfSize:18];
    }
    return _welcomeLalel;
}

- (UIButton *)registButton {
    if (!_registButton) {
        _registButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registButton setTitle:@"创建新账号" forState:UIControlStateNormal];
        _registButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [_registButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registButton addTarget:self action:@selector(createNewAccount) forControlEvents:UIControlEventTouchUpInside];
        [_registButton setBackgroundColor:[UIColor colorWithHexString:@"#0052D9"]];
    }
    return _registButton;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:@"使用已有账号登录" forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [_loginButton addTarget:self action:@selector(loginOldAccount) forControlEvents:UIControlEventTouchUpInside];
        [_loginButton setTitleColor:[UIColor colorWithHexString:@"#0052D9"] forState:UIControlStateNormal];
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
