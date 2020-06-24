//
//  WCLoginVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/13.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTLoginVC.h"
#import "TIoTSendPhoneCodeViewController.h"
#import "XWCountryCodeController.h"
#import "TIoTPhoneResetPwdViewController.h"
#import "TIoTRegisterViewController.h"
#import "TIoTTabBarViewController.h"
#import "XGPushManage.h"
#import "WxManager.h"
#import "UIButton+LQRelayout.h"
#import "TIoTAppConfig.h"

#define kMargin 16

typedef NS_ENUM(NSUInteger,WCLoginStyle){
    WCLoginStylePhone,
    WCLoginStyleEmail,
    WCLoginStyleWechat
};

@interface TIoTLoginVC ()

@property (nonatomic, strong) UIButton *areaCodeBtn;
@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UITextField *pwdTF;
@property (nonatomic, copy) NSString *conturyCode;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UITextField *emailTF;
@property (nonatomic, strong) UITextField *emailPwdTF;

@property (nonatomic, strong) UIView *loginView;
@property (nonatomic, strong) UIScrollView *scView;
@property (nonatomic, strong) UIView *phoneLoginView;
@property (nonatomic, strong) UIView *emailLoginView;
@property (nonatomic, strong) UIView *registView;
@property (nonatomic, strong) UIImageView *headerImg;
@property (nonatomic, strong) UILabel *welcomeL;

@property (nonatomic) WCLoginStyle loginStyle;

//
@property (nonatomic) CGRect oriFrame;
@property (nonatomic,strong) MASConstraint *topLayout;
@property (nonatomic,strong) MASConstraint *bottomLayout;

@end

@implementation TIoTLoginVC

- (instancetype)init {
    if (self = [super init]) {
        self.isExpireAt = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addKeyboardNote];
    [self setUpUI];
}

#pragma mark - UI
- (void)setUpUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.conturyCode = @"86";
    self.fd_prefersNavigationBarHidden = YES;
    
    UIView *header = [[UIView alloc] init];
    [self.view addSubview:header];
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(300 * kScreenAllHeightScale);
    }];
    CAGradientLayer *layer = [[CAGradientLayer alloc] init];
    layer.frame = CGRectMake(0, 0, kScreenWidth, 300);
    layer.colors = @[(id)kMainColor.CGColor,(id)[UIColor whiteColor].CGColor];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(0, 1);
    [header.layer addSublayer:layer];
    
    
    [self.view addSubview:self.headerImg];
    [self.headerImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * kScreenAllHeightScale);
        make.centerX.equalTo(self.view);
        make.width.height.mas_equalTo(80 * kScreenAllHeightScale);
    }];
    
    
    [self.view addSubview:self.welcomeL];
    [self.welcomeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerImg.mas_bottom).offset(20 * kScreenAllHeightScale);
        make.centerX.equalTo(self.view);
    }];
    
    
    
    [self.view addSubview:self.registView];
    
    [self.view addSubview:self.loginView];
    [_loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(kMargin);
        make.trailing.mas_equalTo(-kMargin);
        self.topLayout = make.top.equalTo(self.welcomeL.mas_bottom).offset(20 * kScreenAllHeightScale);
    }];
    
    [self.registView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(26);
        make.trailing.mas_equalTo(-26);
        self.bottomLayout = make.bottom.equalTo(self.loginView.mas_bottom).offset(60);
        make.height.mas_equalTo(100);
    }];
    
    self.registView.hidden = self.isExpireAt;
    
    UILabel *proctolLab = [[UILabel alloc] init];
    proctolLab.text = @"Copyright @ 2013-2020 Tencent Cloud.All Right Reserved.\n腾讯云 版权所有";
    proctolLab.textAlignment = NSTextAlignmentCenter;
    proctolLab.textColor = kRGBColor(187, 187, 187);
    proctolLab.font = [UIFont wcPfRegularFontOfSize:10];
    proctolLab.numberOfLines = 0;
    [self.view addSubview:proctolLab];
    [proctolLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(- 20 - kXDPiPhoneBottomSafeAreaHeight);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    UIButton *wxLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [wxLoginBtn setTitle:@"微信登录" forState:UIControlStateNormal];
    [wxLoginBtn setTitleColor:kFontColor forState:UIControlStateNormal];
    [wxLoginBtn setImage:[UIImage imageNamed:@"wxlogin"] forState:UIControlStateNormal];
    wxLoginBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:10];
    [wxLoginBtn addTarget:self action:@selector(wxLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wxLoginBtn];
    [wxLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(proctolLab.mas_top).offset(-10);
        make.height.mas_equalTo(80);
    }];
    [wxLoginBtn relayoutButton:XDPButtonLayoutStyleTop];
    
    // 对未安装的用户隐藏微信登录按钮，只提供其他登录方式（比如手机号注册登录、游客登录等）。
    wxLoginBtn.hidden = ![WxManager isWXAppInstalled];
}


- (UIView *)phoneLoginView
{
    if (!_phoneLoginView) {
        UIView *bgView = [UIView new];
        _phoneLoginView = bgView;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 48)];
        self.areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.areaCodeBtn.frame = CGRectMake(0, 0, 70, 48);
        [self.areaCodeBtn setTitle:@"+86" forState:UIControlStateNormal];
        [self.areaCodeBtn setTitleColor:kMainColor forState:UIControlStateNormal];
        self.areaCodeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.areaCodeBtn addTarget:self action:@selector(choseAreaCode:) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:self.areaCodeBtn];
        
        self.phoneTF = [[UITextField alloc] init];
        self.phoneTF.layer.cornerRadius = 4;
        self.phoneTF.backgroundColor = kLineColor;
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:@"手机号码" attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224)}];
        self.phoneTF.attributedPlaceholder = as;
        self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
        self.phoneTF.textColor = kFontColor;
        self.phoneTF.font = [UIFont systemFontOfSize:18];
        self.phoneTF.leftViewMode = UITextFieldViewModeAlways;
        self.phoneTF.leftView = leftView;
        self.phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.phoneTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
        [bgView addSubview:self.phoneTF];
        [self.phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(30);
            make.height.mas_equalTo(48);
            make.trailing.mas_equalTo(-30);
            make.top.mas_equalTo(30 * kScreenAllHeightScale);
        }];
        
        
        
        self.pwdTF = [[UITextField alloc] init];
        self.pwdTF.layer.cornerRadius = 4;
        self.pwdTF.backgroundColor = kLineColor;
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224)}];
        self.pwdTF.attributedPlaceholder = ap;
        self.pwdTF.textColor = kFontColor;
        self.pwdTF.secureTextEntry = YES;
        if (@available(iOS 12.0, *)) {
            self.pwdTF.textContentType = UITextContentTypeNewPassword;
        }
        else if (@available(iOS 11.0, *)) {
            self.pwdTF.textContentType = UITextContentTypePassword;
        }
        self.pwdTF.leftViewMode = UITextFieldViewModeAlways;
        self.pwdTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 48)];
        self.pwdTF.font = [UIFont systemFontOfSize:18];
        self.pwdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.pwdTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
        [bgView addSubview:self.pwdTF];
        [self.pwdTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneTF.mas_bottom).offset(30 * kScreenAllHeightScale);
            make.leading.mas_equalTo(30);
            make.trailing.mas_equalTo(-30);
            make.bottom.mas_equalTo(-10);
            make.height.mas_equalTo(48);
        }];
    }
    return _phoneLoginView;
}

- (UIView *)emailLoginView
{
    if (!_emailLoginView) {
        UIView *bgView = [UIView new];
        _emailLoginView = bgView;
        
        
        self.emailTF = [[UITextField alloc] init];
        _emailTF.layer.cornerRadius = 4;
        _emailTF.backgroundColor = kLineColor;
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:@"邮箱地址" attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224)}];
        self.emailTF.attributedPlaceholder = as;
        self.emailTF.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTF.textColor = kFontColor;
        self.emailTF.font = [UIFont systemFontOfSize:18];
        self.emailTF.leftViewMode = UITextFieldViewModeAlways;
        self.emailTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 48)];
        [self.emailTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
        [bgView addSubview:self.emailTF];
        [self.emailTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(30);
            make.top.mas_equalTo(30 * kScreenAllHeightScale);
            make.trailing.mas_equalTo(-30);
            make.height.mas_equalTo(48);
        }];
        
        self.emailPwdTF = [[UITextField alloc] init];
        _emailPwdTF.layer.cornerRadius = 4;
        _emailPwdTF.backgroundColor = kLineColor;
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224)}];
        self.emailPwdTF.attributedPlaceholder = ap;
        self.emailPwdTF.textColor = kFontColor;
        self.emailPwdTF.secureTextEntry = YES;
        self.emailPwdTF.leftViewMode = UITextFieldViewModeAlways;
        self.emailPwdTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 48)];
        self.emailPwdTF.font = [UIFont systemFontOfSize:18];
        [self.emailPwdTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
        [bgView addSubview:self.emailPwdTF];
        [self.emailPwdTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.emailTF.mas_bottom).offset(30 * kScreenAllHeightScale);
            make.leading.mas_equalTo(30);
            make.trailing.mas_equalTo(-30);
            make.bottom.mas_equalTo(-10);
            make.height.mas_equalTo(48);
        }];
        
        
        
    }
    return _emailLoginView;
}

- (UIImageView *)headerImg
{
    if (!_headerImg) {
        _headerImg = [[UIImageView alloc] init];
        [_headerImg setImage:[UIImage imageNamed:@"logo"]];
        _headerImg.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _headerImg;
}

- (UILabel *)welcomeL
{
    if (!_welcomeL) {
        _welcomeL = [[UILabel alloc] init];
        _welcomeL.text = @"欢迎使用腾讯连连";
        _welcomeL.textColor = [UIColor whiteColor];
        _welcomeL.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    }
    return _welcomeL;
}

- (UIView *)loginView
{
    if (!_loginView) {
        _loginView = [UIView new];
        _loginView.layer.shadowColor = [UIColor colorWithRed:20/255.0 green:104/255.0 blue:213/255.0 alpha:0.23].CGColor;
        _loginView.layer.shadowOffset = CGSizeMake(0,20);
        _loginView.layer.shadowRadius = 20;
        _loginView.layer.shadowOpacity = 1;
        
        
        UIView *contentView = [UIView new];
        contentView.layer.cornerRadius = 20;
        contentView.backgroundColor = [UIColor whiteColor];
        [_loginView addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        
        UIScrollView *scroll = [[UIScrollView alloc] init];
        scroll.bounces = NO;
        scroll.scrollEnabled = NO;
        [contentView addSubview:scroll];
        self.scView = scroll;
        [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(0);
            make.height.mas_equalTo(48 * 2 + 10 + 30 * kScreenAllHeightScale * 2);
        }];
        [scroll addSubview:self.phoneLoginView];
        [_phoneLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(0);
            make.width.equalTo(scroll);
        }];
        [scroll addSubview:self.emailLoginView];
        [_emailLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.top.bottom.mas_equalTo(0);
            make.leading.equalTo(self.phoneLoginView.mas_trailing);
            make.width.equalTo(scroll);
        }];
        
        
        UIButton *emailLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [emailLoginBtn setTitle:@"邮箱登录" forState:UIControlStateNormal];
        [emailLoginBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateNormal];
        [emailLoginBtn addTarget:self action:@selector(contentChange:) forControlEvents:UIControlEventTouchUpInside];
        emailLoginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [contentView addSubview:emailLoginBtn];
        [emailLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(30);
            make.top.equalTo(scroll.mas_bottom).offset(10);
        }];
        
        
        UIButton *forgetPwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [forgetPwdBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
        [forgetPwdBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateNormal];
        [forgetPwdBtn addTarget:self action:@selector(forgetPwdClick:) forControlEvents:UIControlEventTouchUpInside];
        forgetPwdBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [contentView addSubview:forgetPwdBtn];
        [forgetPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-30);
            make.top.equalTo(scroll.mas_bottom).offset(10);
        }];
        
        self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [self.loginBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateDisabled];
        self.loginBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [self.loginBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
        self.loginBtn.backgroundColor = kMainColorDisable;
        self.loginBtn.enabled = NO;
        self.loginBtn.layer.cornerRadius = 3;
        [contentView addSubview:self.loginBtn];
        [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(30);
            make.trailing.mas_equalTo(-30);
            make.top.equalTo(scroll.mas_bottom).offset(60);
            make.height.mas_equalTo(48);
            make.bottom.mas_equalTo(-30);
        }];
    }
    return _loginView;
}

- (UIView *)registView
{
    if (!_registView) {
        
        _registView = [UIView new];
        _registView.layer.shadowColor = [UIColor colorWithRed:20/255.0 green:104/255.0 blue:213/255.0 alpha:0.23].CGColor;
        _registView.layer.shadowOffset = CGSizeMake(0,20);
        _registView.layer.shadowRadius = 20;
        _registView.layer.shadowOpacity = 1;
        
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.layer.cornerRadius = 20;
        [_registView addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toRegist:)];
        [contentView addGestureRecognizer:tap];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"注册账号" forState:UIControlStateNormal];
        [btn setTitleColor:kMainColor forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        btn.userInteractionEnabled = NO;
        [contentView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-20);
            make.bottom.mas_equalTo(-15);
        }];
        
        UILabel *lab = [[UILabel alloc] init];
        lab.text = @"还没有账号？";
        lab.textColor = kRGBColor(153, 153, 153);
        lab.font = [UIFont systemFontOfSize:16];
        [contentView addSubview:lab];
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(btn.mas_leading).offset(0);
            make.centerY.equalTo(btn);
        }];
        
    }
    return _registView;
}


#pragma mark - event

-(void)changedTextField:(UITextField *)textField{
    
    if (WCLoginStylePhone == self.loginStyle) {
        if ([NSString judgePhoneNumberLegal:self.phoneTF.text] && [NSString judgePassWordLegal:self.pwdTF.text]) {
            self.loginBtn.backgroundColor = kMainColor;
            self.loginBtn.enabled = YES;
            
        }
        else{
            self.loginBtn.backgroundColor = kMainColorDisable;
            self.loginBtn.enabled = NO;
            
        }
        
    }
    else if (WCLoginStyleEmail == self.loginStyle)
    {
        if ([NSString judgeEmailLegal:self.emailTF.text] && [NSString judgePassWordLegal:self.emailPwdTF.text]) {
            self.loginBtn.backgroundColor = kMainColor;
            self.loginBtn.enabled = YES;
            
        }
        else{
            self.loginBtn.backgroundColor = kMainColorDisable;
            self.loginBtn.enabled = NO;
            
        }
        
        
    }
}


- (void)toRegist:(id)sender{
    TIoTRegisterViewController *vc = [[TIoTRegisterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)forgetPwdClick:(id)sender{
    TIoTPhoneResetPwdViewController *vc = [[TIoTPhoneResetPwdViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)choseAreaCode:(id)sender{
    XWCountryCodeController *countryCodeVC = [[XWCountryCodeController alloc] init];
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
        
        [MBProgressHUD dismissInView:self.view];
        self.conturyCode = code;
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"+%@",code] forState:UIControlStateNormal];
    };
    
    [self.navigationController pushViewController:countryCodeVC animated:YES];
}

- (void)sureClick:(id)sender{
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    if (WCLoginStylePhone == self.loginStyle) {
        NSDictionary *tmpDic = @{
                                 @"Type":@"phone",
                                 @"CountryCode":self.conturyCode,
                                 @"PhoneNumber":self.phoneTF.text,
                                 @"Password":self.pwdTF.text,
                                 //@"Email":@"",
                                 };
        
        [[TIoTRequestObject shared] postWithoutToken:AppGetToken Param:tmpDic success:^(id responseObject) {
            [MBProgressHUD dismissInView:nil];
            [[TIoTUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
            [self loginSuccess];

            //信鸽推送注册
            [[XGPushManage sharedXGPushManage] bindPushToken];
            [HXYNotice addLoginInPost];
        } failure:^(NSString *reason, NSError *error) {
            
        }];
    }
    else if (WCLoginStyleEmail == self.loginStyle)
    {
        NSDictionary *tmpDic = @{
                                 @"Type":@"email",
                                 @"Password":self.emailPwdTF.text,
                                 @"Email":self.emailTF.text,
                                 };
        [[TIoTRequestObject shared] postWithoutToken:AppGetToken Param:tmpDic success:^(id responseObject) {
            
            [[TIoTUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
            [self loginSuccess];
            
            //信鸽推送绑定
            [[XGPushManage sharedXGPushManage] bindPushToken];
//            [HXYNotice addLoginInPost];
        } failure:^(NSString *reason, NSError *error) {
            
        }];
    }
    
}

- (void)wxLoginClick:(id)sender{
    [[WxManager sharedWxManager] authFromWxComplete:^(id obj, NSError *error) {
        if (!error) {
            [self getTokenByOpenId:[NSString stringWithFormat:@"%@",obj]];
        }
    }];
}

- (void)getTokenByOpenId:(NSString *)code
{
    NSString *busivalue = @"studioappOpensource";
    
    TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
    if ([TIoTAppConfig appTypeWithModel:model] == 0){
        //公版
        busivalue = @"studioapp";
    }else {
        //开源
        busivalue = @"studioappOpensource";
    }
    NSDictionary *tmpDic = @{@"code":code,@"busi":busivalue};
    
    [[TIoTRequestObject shared] postWithoutToken:AppGetTokenByWeiXin Param:tmpDic success:^(id responseObject) {
        [MBProgressHUD dismissInView:self.view];
        [[TIoTUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
        
        [self loginSuccess];
        
        //信鸽推送注册
        [[XGPushManage sharedXGPushManage] bindPushToken];
        [HXYNotice addLoginInPost];
    } failure:^(NSString *reason, NSError *error) {
        
    }];
}


- (void)contentChange:(UIButton *)btn
{
    [self.view endEditing:YES];
    self.loginBtn.backgroundColor = kMainColorDisable;
    self.loginBtn.enabled = NO;
    if ([@"手机登录" isEqualToString:btn.titleLabel.text]) {
        self.loginStyle = WCLoginStylePhone;
        [self.scView setContentOffset:CGPointMake(0, 0) animated:YES];
        [btn setTitle:@"邮箱登录" forState:UIControlStateNormal];
        self.emailTF.text = @"";
        self.emailPwdTF.text = @"";
    }
    else
    {
        self.loginStyle = WCLoginStyleEmail;
        [self.scView setContentOffset:CGPointMake(kScreenWidth - kMargin * 2, 0) animated:YES];
        [btn setTitle:@"手机登录" forState:UIControlStateNormal];
        self.phoneTF.text = @"";
        self.pwdTF.text = @"";
    }
}

- (void)loginSuccess {
    if (self.isExpireAt) {
        [MBProgressHUD showLodingNoneEnabledInView:[UIApplication sharedApplication].keyWindow withMessage:@""];
        [[TIoTRequestObject shared] post:AppGetTokenTicket Param:@{} success:^(id responseObject) {
            
            NSString *ticket = responseObject[@"TokenTicket"]?:@"";
            [MBProgressHUD dismissInView:self.view];
            [HXYNotice postLoginInTicketToken:ticket];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } failure:^(NSString *reason, NSError *error) {
            [MBProgressHUD dismissInView:self.view];
        }];
    } else {
        self.view.window.rootViewController = [[TIoTTabBarViewController alloc] init];
    }
}

#pragma mark - keyboard

- (void)addKeyboardNote {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    // 1.显示键盘
    [center addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    
    // 2.隐藏键盘
    [center addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardChange:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    CGRect keyboardBeginFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBeginFrame];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    
    if ([notification.name isEqualToString:@"UIKeyboardWillShowNotification"]) {
//        self.oriFrame = self.loginView.frame;
//
//        CGRect newFrame = self.loginView.frame;
//        newFrame.origin.y = [WCUIProxy shareUIProxy].navigationBarHeight + 10;
//        self.loginView.frame = newFrame;
        
        if (keyboardBeginFrame.origin.y + keyboardBeginFrame.size.height != keyboardEndFrame.origin.y + keyboardEndFrame.size.height) {
            [self.topLayout uninstall];
            [self.loginView mas_updateConstraints:^(MASConstraintMaker *make) {
                self.topLayout = make.top.equalTo(self.view).offset([TIoTUIProxy shareUIProxy].navigationBarHeight + 10);
            }];
            [self.registView mas_updateConstraints:^(MASConstraintMaker *make) {
                self.bottomLayout = make.bottom.equalTo(self.loginView.mas_bottom).offset(200);
            }];
            
            [self.view layoutIfNeeded];
            
            self.headerImg.alpha = 0;
            self.welcomeL.alpha = 0;
            self.registView.alpha = 0;
        }
    }
    else if ([notification.name isEqualToString:@"UIKeyboardWillHideNotification"]) {
        
//        self.loginView.frame = self.oriFrame;
        [self.topLayout uninstall];
        [self.loginView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.topLayout = make.top.equalTo(self.welcomeL.mas_bottom).offset(20 * kScreenAllHeightScale);
        }];
        
        [self.registView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.bottomLayout = make.bottom.equalTo(self.loginView.mas_bottom).offset(60);
        }];
        
        [self.view layoutIfNeeded];
        
        self.headerImg.alpha = 1;
        self.welcomeL.alpha = 1;
        self.registView.alpha = 1;
    }
    
    [UIView commitAnimations];
}

@end
