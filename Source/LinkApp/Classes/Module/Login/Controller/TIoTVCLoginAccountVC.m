//
//  TIoTVCLoginAccountVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/7/28.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTVCLoginAccountVC.h"
#import "XWCountryCodeController.h"
#import "TIoTTabBarViewController.h"
#import "UIButton+LQRelayout.h"
#import "WxManager.h"
#import "XGPushManage.h"
#import "TIoTAppConfig.h"
#import "TIoTPhoneResetPwdViewController.h"
#import "TIoTRegisterViewController.h"
#import "TIoTChooseRegionVC.h"
#import "TIoTAppConfig.h"
#import "TIoTUserRegionModel.h"
#import "YYModel.h"
@interface TIoTVCLoginAccountVC ()<UITextViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL     loginStyle;            // YES 验证码  NO 手机/邮箱

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *areaCodeBtn;
@property (nonatomic, strong) NSString *conturyCode;
@property (nonatomic, strong) UITextField *phoneAndEmailTF;
@property (nonatomic, strong) UIButton *verificationButton;
@property (nonatomic, strong) UITextField *verificationcodeTF;
@property (nonatomic, strong) UIButton  *forgetPasswordButton;

@property (nonatomic, strong) UIView *contentView2;
@property (nonatomic, strong) UIButton *areaCodeBtn2;
@property (nonatomic, strong) NSString *conturyCode2;
@property (nonatomic, strong) UITextField *phoneAndEmailTF2;
@property (nonatomic, strong) UITextField *passwordTF;

@property (nonatomic, strong) UIButton *loginAccountButton;
@property (nonatomic, strong) UIButton *weixinLoginButton;

@property (nonatomic, strong) NSString *cancelAccountTimeString;
@end

@implementation TIoTVCLoginAccountVC

- (instancetype)init {
    if (self = [super init]) {
        self.isExpireAt = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
}

- (void)setUpUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"verify_code_login", @"验证码登录");
    self.conturyCode = @"86";
    self.conturyCode2 = @"86";
    self.loginStyle = YES;
    
    //不选地区列表赋默认值
    [TIoTCoreUserManage shared].userRegion = @"ap-guangzhou";
    [TIoTCoreUserManage shared].userRegionId = @"1";
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64);
        }
    }];
    
    [self.scrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.equalTo(self.scrollView);
        make.width.height.equalTo(self.scrollView);
    }];
    
    [self.scrollView addSubview:self.contentView2];
    [self.contentView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.equalTo(self.scrollView);
        make.width.height.equalTo(self.scrollView);
        make.leading.equalTo(self.contentView.mas_trailing);
    }];
    
    [self.view addSubview:self.loginAccountButton];
    [self.loginAccountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView.mas_bottom).offset(30);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.right.equalTo(self.view.mas_right).offset(-30);
        make.height.mas_equalTo(45);
    }];
    
    UIButton *verificationCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [verificationCodeButton setTitle:NSLocalizedString(@"account_passwd_login", @"账号密码登录") forState:UIControlStateNormal];
    [verificationCodeButton setTitleColor:[UIColor colorWithHexString:@"006EFF"] forState:UIControlStateNormal];
    verificationCodeButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
    [verificationCodeButton addTarget:self action:@selector(loginStyleChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:verificationCodeButton];
    [verificationCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loginAccountButton.mas_left);
        make.top.equalTo(self.loginAccountButton.mas_bottom).offset(10);
    }];
    
    
    UILabel *otherLoginLabel = [[UILabel alloc]init];
    otherLoginLabel.text = @"其他登录方式";
    otherLoginLabel.textColor = [UIColor colorWithHexString:@"#cccccc"];
    otherLoginLabel.font = [UIFont wcPfRegularFontOfSize:14];
    otherLoginLabel.hidden = self.weixinLoginButton.hidden;
    [self.view addSubview:otherLoginLabel];
    [otherLoginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(verificationCodeButton.mas_bottom).offset(80);
        make.centerX.equalTo(self.view);
    }];
    
    UIView *otherLoginLine1 = [[UIView alloc]init];
    otherLoginLine1.backgroundColor = [UIColor colorWithHexString:@"#cccccc"];
    otherLoginLine1.hidden = self.weixinLoginButton.hidden;
    [self.view addSubview:otherLoginLine1];
    [otherLoginLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(otherLoginLabel.mas_centerY);
        make.trailing.equalTo(otherLoginLabel.mas_leading).offset(-10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(0.5);
    }];
    
    UIView *otherLoginLine2 = [[UIView alloc]init];
    otherLoginLine2.backgroundColor = [UIColor colorWithHexString:@"#cccccc"];
    otherLoginLine2.hidden = self.weixinLoginButton.hidden;
    [self.view addSubview:otherLoginLine2];
    [otherLoginLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(otherLoginLabel.mas_centerY);
        make.leading.equalTo(otherLoginLabel.mas_trailing).offset(10);
        make.width.height.equalTo(otherLoginLine1);
    }];
    
    [self.view addSubview:self.weixinLoginButton];
    [self.weixinLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(otherLoginLabel.mas_bottom).offset(20);
        make.height.mas_equalTo(80);
    }];
    [self.weixinLoginButton relayoutButton:XDPButtonLayoutStyleTop];
    // 对未安装的用户隐藏微信登录按钮，只提供其他登录方式（比如手机号注册登录、游客登录等）。
    self.weixinLoginButton.hidden = ![WxManager isWXAppInstalled];
    
    self.forgetPasswordButton.hidden = YES;
    [self.view addSubview:self.forgetPasswordButton];
    [self.forgetPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.loginAccountButton.mas_trailing);
        make.centerY.equalTo(verificationCodeButton.mas_centerY);
    }];
    
    //判断获取验证码按钮是否可点击
    [self judgeVerificationButtonResponse];
}

#pragma mark - //判断获取验证码按钮是否可点击
- (void)judgeVerificationButtonResponse {
    
    if ((![NSString isNullOrNilWithObject:self.phoneAndEmailTF.text]) && ([NSString judgePhoneNumberLegal:self.phoneAndEmailTF.text] || [NSString judgeEmailLegal:self.phoneAndEmailTF.text])) {
        //手机号或邮箱不为空且格式正确
        [_verificationButton setTitleColor:kMainColor forState:UIControlStateNormal];
        _verificationButton.enabled = YES;
    }else {
        [_verificationButton setTitleColor:[UIColor colorWithHexString:@"#bbbbbb"] forState:UIControlStateNormal];
        _verificationButton.enabled = NO;
    }
}

#pragma mark setter or getter
- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = NO;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
        
        self.areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
        [self.areaCodeBtn setTitleColor:kFontColor forState:UIControlStateNormal];
        self.areaCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.areaCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [self.areaCodeBtn addTarget:self action:@selector(choseAreaCode:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:self.areaCodeBtn];
        [self.areaCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(30);
            make.top.mas_equalTo(40*kScreenAllHeightScale);
            make.height.mas_equalTo(30);
        }];
        
        UIImageView *imgV = [UIImageView new];
        imgV.image = [UIImage imageNamed:@"mineArrow"];
        [_contentView addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.areaCodeBtn.mas_trailing).offset(5);
            make.centerY.equalTo(self.areaCodeBtn);
        }];
        
        
        [_contentView addSubview:self.phoneAndEmailTF];
        [self.phoneAndEmailTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(30);
            make.trailing.mas_equalTo(-30);
            make.top.equalTo(self.areaCodeBtn.mas_bottom).offset(10);
            make.height.mas_equalTo(55);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = kLineColor;
        [_contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneAndEmailTF.mas_bottom);
            make.height.mas_equalTo(0.5);
            make.leading.mas_equalTo(30);
            make.trailing.mas_equalTo(-30);
        }];
        
        [_contentView addSubview:self.verificationButton];
        [self.verificationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-30);
            make.top.equalTo(lineView.mas_bottom);
            make.height.mas_equalTo(55);
        }];
        
        [_contentView addSubview:self.verificationcodeTF];
        [self.verificationcodeTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView.mas_bottom);
            make.leading.equalTo(self.phoneAndEmailTF.mas_leading);
            make.trailing.equalTo(self.verificationButton.mas_leading);
            make.height.mas_equalTo(55);
        }];

        UIView *lineViewVerification = [[UIView alloc] init];
        lineViewVerification.backgroundColor = kLineColor;
        [_contentView addSubview:lineViewVerification];
        [lineViewVerification mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.verificationcodeTF.mas_bottom);
            make.height.mas_equalTo(0.5);
            make.bottom.mas_equalTo(0);
            make.leading.mas_equalTo(30);
            make.trailing.mas_equalTo(-30);
        }];
    }
    return _contentView;
}

- (UIView *)contentView2 {
    if (!_contentView2) {
        _contentView2 = [[UIView alloc]init];
        _contentView2.backgroundColor = [UIColor whiteColor];
        
        self.areaCodeBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.areaCodeBtn2 setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
        [self.areaCodeBtn2 setTitleColor:kFontColor forState:UIControlStateNormal];
        self.areaCodeBtn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.areaCodeBtn2.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [self.areaCodeBtn2 addTarget:self action:@selector(choseAreaCode:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView2 addSubview:self.areaCodeBtn2];
        [self.areaCodeBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(30);
            make.top.mas_equalTo(40*kScreenAllHeightScale);
            make.height.mas_equalTo(30);
        }];
        
        UIImageView *imgV = [UIImageView new];
        imgV.image = [UIImage imageNamed:@"mineArrow"];
        [_contentView2 addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.areaCodeBtn2.mas_trailing).offset(5);
            make.centerY.equalTo(self.areaCodeBtn2);
        }];
        
        [_contentView2 addSubview:self.phoneAndEmailTF2];
        [self.phoneAndEmailTF2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(30);
            make.trailing.mas_equalTo(-30);
            make.top.equalTo(self.areaCodeBtn2.mas_bottom).offset(10);
            make.height.mas_equalTo(55);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = kLineColor;
        [_contentView2 addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneAndEmailTF2.mas_bottom);
            make.height.mas_equalTo(0.5);
            make.leading.mas_equalTo(30);
            make.trailing.mas_equalTo(-30);
        }];
        
        [_contentView2 addSubview:self.passwordTF];
        [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView.mas_bottom);
            make.leading.equalTo(self.phoneAndEmailTF2.mas_leading);
            make.trailing.equalTo(self.phoneAndEmailTF2.mas_trailing);
            make.height.mas_equalTo(55);
        }];

        UIView *passwordLineView = [[UIView alloc] init];
        passwordLineView.backgroundColor = kLineColor;
        [_contentView2 addSubview:passwordLineView];
        [passwordLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordTF.mas_bottom);
            make.height.mas_equalTo(0.5);
            make.leading.mas_equalTo(30);
            make.trailing.mas_equalTo(-30);
        }];
        
    }
    return _contentView2;
}

- (UIButton *)loginAccountButton {
    if (!_loginAccountButton) {
        _loginAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginAccountButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginAccountButton setBackgroundColor:kMainColorDisable];
        _loginAccountButton.enabled = NO;
        _loginAccountButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_loginAccountButton addTarget:self action:@selector(loginSure) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginAccountButton;;
}

- (UITextField *)phoneAndEmailTF {
    if (!_phoneAndEmailTF) {
        _phoneAndEmailTF = [[UITextField alloc] init];
        _phoneAndEmailTF.keyboardType = UIKeyboardTypeEmailAddress;
        _phoneAndEmailTF.textColor = [UIColor blackColor];
        _phoneAndEmailTF.font = [UIFont wcPfRegularFontOfSize:16];
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"mobile_or_email", @"手机号码/邮箱地址") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#bbbbbb"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        _phoneAndEmailTF.attributedPlaceholder = ap;
        _phoneAndEmailTF.clearButtonMode = UITextFieldViewModeAlways;
        [_phoneAndEmailTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _phoneAndEmailTF;
}

- (UIButton *)verificationButton {
    if (!_verificationButton) {
        _verificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_verificationButton setTitle:NSLocalizedString(@"register_get_code", @"获取验证码") forState:UIControlStateNormal];
        [_verificationButton setTitleColor:kMainColor forState:UIControlStateNormal];
        _verificationButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [_verificationButton setTitleColor:[UIColor colorWithHexString:@"#bbbbbb"] forState:UIControlStateNormal];
        _verificationButton.enabled = NO;
        [_verificationButton addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verificationButton;
}

- (UITextField *)verificationcodeTF {
    if (!_verificationcodeTF) {
        _verificationcodeTF = [[UITextField alloc]init];
        _verificationcodeTF.keyboardType = UIKeyboardTypePhonePad;
        _verificationcodeTF.textColor = [UIColor blackColor];
        _verificationcodeTF.font = [UIFont wcPfRegularFontOfSize:16];
        NSAttributedString *apVerification = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"verification_code", @"验证码") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#bbbbbb"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        _verificationcodeTF.attributedPlaceholder = apVerification;
        _verificationcodeTF.clearButtonMode = UITextFieldViewModeAlways;
        [_verificationcodeTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _verificationcodeTF;
}

- (UIButton *)forgetPasswordButton {
    if (!_forgetPasswordButton) {
        _forgetPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgetPasswordButton setTitle:NSLocalizedString(@"forgot_password", @"忘记密码") forState:UIControlStateNormal];
        [_forgetPasswordButton setTitleColor:kMainColor forState:UIControlStateNormal];
        _forgetPasswordButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_forgetPasswordButton addTarget:self action:@selector(forgetPasswordClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgetPasswordButton;
}

- (UITextField *)phoneAndEmailTF2 {
    if (!_phoneAndEmailTF2) {
        _phoneAndEmailTF2 = [[UITextField alloc] init];
        _phoneAndEmailTF2.keyboardType = UIKeyboardTypeEmailAddress;
        _phoneAndEmailTF2.textColor = [UIColor blackColor];
        _phoneAndEmailTF2.font = [UIFont wcPfRegularFontOfSize:16];
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"mobile_or_email", @"手机号码/邮箱地址") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#bbbbbb"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        _phoneAndEmailTF2.attributedPlaceholder = ap;
        _phoneAndEmailTF2.clearButtonMode = UITextFieldViewModeAlways;
        [_phoneAndEmailTF2 addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _phoneAndEmailTF2;
}

- (UITextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc]init];
        _passwordTF.keyboardType = UITextFieldViewModeAlways;
        _passwordTF.textColor = [UIColor blackColor];
        _passwordTF.secureTextEntry = YES;
        _passwordTF.font = [UIFont wcPfRegularFontOfSize:16];
        NSAttributedString *passwordAttStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"password", @"密码") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#bbbbbb"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        _passwordTF.attributedPlaceholder = passwordAttStr;
        _passwordTF.clearButtonMode = UITextFieldViewModeAlways;
        [_passwordTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _passwordTF;
}

- (UIButton *)weixinLoginButton {
    if (!_weixinLoginButton) {
        _weixinLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_weixinLoginButton setTitle:NSLocalizedString(@"wechat", @"微信") forState:UIControlStateNormal];
        [_weixinLoginButton setTitleColor:kFontColor forState:UIControlStateNormal];
        [_weixinLoginButton setImage:[UIImage imageNamed:@"wxlogin"] forState:UIControlStateNormal];
        _weixinLoginButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:10];
        [_weixinLoginButton addTarget:self action:@selector(wxLoginClick:) forControlEvents:UIControlEventTouchUpInside];
        [_weixinLoginButton relayoutButton:XDPButtonLayoutStyleTop];
        // 对未安装的用户隐藏微信登录按钮，只提供其他登录方式（比如手机号注册登录、游客登录等）。
        _weixinLoginButton.hidden = ![WxManager isWXAppInstalled];
    }
    return _weixinLoginButton;
}

#pragma makr - event

- (void)loginStyleChange:(UIButton *)sender {
    
    [self.view endEditing:YES];
    self.loginAccountButton.backgroundColor = kMainColorDisable;
    self.loginAccountButton.enabled = NO;
    if ([sender.titleLabel.text containsString:NSLocalizedString(@"verification_code", @"验证码")]) {
        self.loginStyle = YES;
        self.title = NSLocalizedString(@"verify_code_login", @"验证码登录");
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [sender setTitle:NSLocalizedString(@"account_passwd_login", @"账号密码登录") forState:UIControlStateNormal];
        self.forgetPasswordButton.hidden = YES;
        self.phoneAndEmailTF2.text = @"";
        self.passwordTF.text = @"";
        [self.areaCodeBtn2 setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
    }else {
        self.loginStyle = NO;
        self.title = NSLocalizedString(@"account_passwd_login", @"账号密码登录");
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
        [sender setTitle:NSLocalizedString(@"verify_code_login", @"验证码登录") forState:UIControlStateNormal];
        self.forgetPasswordButton.hidden = NO;
        self.phoneAndEmailTF.text = @"";
        self.verificationcodeTF.text = @"";
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
    }
}

- (void)loginSure {
    
    NSDictionary *tmpDic = nil;
    
    if (self.loginStyle == YES) {     //验证码登录
        if ([NSString judgePhoneNumberLegal:self.phoneAndEmailTF.text]) {
            
            //短信验证码登录
            tmpDic = @{
                @"Type":@"phone",
                @"CountryCode":self.conturyCode,
                @"PhoneNumber":self.phoneAndEmailTF.text,
                @"VerificationCode":self.verificationcodeTF.text,
                
            };
            
            [self phoneLoginWith:tmpDic];
            
        }else  if ([NSString judgeEmailLegal:self.phoneAndEmailTF.text]) {
            
            //邮件验证码登录
            tmpDic = @{
                @"Type":@"email",
                @"CountryCode":self.conturyCode,
                @"Email":self.phoneAndEmailTF.text,
                @"VerificationCode":self.verificationcodeTF.text,
                
            };
            
            [self emailLoginWith:tmpDic];
        }
    }else {         //账号密码登录
        if ([NSString judgePhoneNumberLegal:self.phoneAndEmailTF2.text]) {

            //手机号密码登录
            tmpDic = @{
                @"Type":@"phone",
                @"CountryCode":self.conturyCode2,
                @"PhoneNumber":self.phoneAndEmailTF2.text,
                @"Password":self.passwordTF.text,
            };

            [self phoneLoginWith:tmpDic];

        }else  if ([NSString judgeEmailLegal:self.phoneAndEmailTF2.text]) {
            //邮件账号密码登录
            tmpDic = @{
                @"Type":@"email",
                @"CountryCode":self.conturyCode2,
                @"Email":self.phoneAndEmailTF2.text,
                @"Password":self.passwordTF.text,
            };

            [self emailLoginWith:tmpDic];
        }
        
    }
}

- (void)phoneLoginWith:(NSDictionary *)tmpDic {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] postWithoutToken:AppGetToken Param:tmpDic success:^(id responseObject) {
        
        [MBProgressHUD dismissInView:nil];
        [self loginWithResponseData:responseObject];
        [HXYNotice addLoginInPost];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)emailLoginWith:(NSDictionary *)tmpDic {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] postWithoutToken:AppGetToken Param:tmpDic success:^(id responseObject) {
        
        [MBProgressHUD dismissInView:nil];
        [self loginWithResponseData:responseObject];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)loginWithResponseData:(id)responseObject {
    
    [MBProgressHUD dismissInView:nil];
    [[TIoTCoreUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
    
    if (responseObject[@"Data"][@"CancelAccountTime"]) {
        self.cancelAccountTimeString = [NSString stringWithFormat:@"%@",responseObject[@"Data"][@"CancelAccountTime"]];
    }else {
        self.cancelAccountTimeString = nil;
    }
    
    [self loginSuccess];
    //信鸽推送注册
    [[XGPushManage sharedXGPushManage] startPushService];
    
}

- (void)choseAreaCode:(id)sender{
    
    TIoTChooseRegionVC *regionVC = [[TIoTChooseRegionVC alloc]init];
    
    regionVC.returnRegionBlock = ^(NSString * _Nonnull Title,NSString * _Nonnull region,NSString * _Nonnull RegionID,NSString *_Nullable CountryCode) {
    
        if (self.loginStyle == YES) {
            self.conturyCode = CountryCode;
            [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
        }else {
             self.conturyCode2 = CountryCode;
            [self.areaCodeBtn2 setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
        }
        
    };
    [self.navigationController pushViewController:regionVC animated:YES];
}

- (void)sendCode:(UIButton *)button {
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];

    if ([NSString judgePhoneNumberLegal:self.phoneAndEmailTF.text]) {       //手机号获取验证码
        NSDictionary *tmpDic = @{@"Type":@"login",@"CountryCode":self.conturyCode,@"PhoneNumber":self.phoneAndEmailTF.text};
        [[TIoTRequestObject shared] postWithoutToken:AppSendVerificationCode Param:tmpDic success:^(id responseObject) {

        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            //验证码登录时，如果用户没有注册，则跳转到单独注册页面，让用户输入密码进行注册
            NSString *errorCode = dic[@"data"][@"Error"][@"Code"];
            if ([errorCode isEqual: @"InvalidParameterValue.ErrorUserNotExists"]) {
                TIoTRegisterViewController *registerVC = [[TIoTRegisterViewController alloc]init];
                registerVC.defaultPhoneOrEmail = self.phoneAndEmailTF.text;
                [self.navigationController pushViewController:registerVC animated:YES];
            }
        }];

    }else if ([NSString judgeEmailLegal:self.phoneAndEmailTF.text]) {       //邮箱获取验证码
        NSDictionary *tmpDic = @{@"Type":@"login",@"Email":self.phoneAndEmailTF.text};
        [[TIoTRequestObject shared] postWithoutToken:AppSendEmailVerificationCode Param:tmpDic success:^(id responseObject) {

        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            //验证码登录时，如果用户没有注册，则跳转到单独注册页面，让用户输入密码进行注册
            NSString *errorCode = dic[@"data"][@"Error"][@"Code"];
            if ([errorCode isEqual: @"InvalidParameterValue.ErrorUserNotExists"]) {
                TIoTRegisterViewController *registerVC = [[TIoTRegisterViewController alloc]init];
                registerVC.defaultPhoneOrEmail = self.phoneAndEmailTF.text;
                [self.navigationController pushViewController:registerVC animated:YES];
            }
        }];
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
            [self judgeCancelAccountTip];
            
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [MBProgressHUD dismissInView:self.view];
        }];
    } else {
        self.view.window.rootViewController = [[TIoTTabBarViewController alloc] init];
        [self judgeCancelAccountTip];
    }
}

- (void)judgeCancelAccountTip {
    if (self.cancelAccountTimeString != nil) {
        
        NSString *tempStr = [NSString convertTimestampToTime:self.cancelAccountTimeString byDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        TIoTAlertView *modifyAlertView = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds withTopImage:nil];
        [modifyAlertView alertWithTitle:NSLocalizedString(@"cancel_account_stopped_title", @"账号注销已终止") message:[NSString stringWithFormat:@"由于你在申请“账号注销”后的7天内重新登录，该账号在%@提交的“账号注销”申请已被撤销",tempStr] cancleTitlt:@"" doneTitle:NSLocalizedString(@"verify", @"确认")];
        [modifyAlertView showSingleConfrimButton];
        modifyAlertView.doneAction = ^(NSString * _Nonnull text) {
        
        };
        [modifyAlertView showInView:[[UIApplication sharedApplication] delegate].window];
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

    if ([TIoTAppConfig weixinLoginWithModel:model]){
        
        busivalue = @"studioapp";
    }else {
        
        busivalue = @"studioappOpensource";
    }
    NSDictionary *tmpDic = @{@"code":code,@"busi":busivalue};
    
    [[TIoTRequestObject shared] postWithoutToken:AppGetTokenByWeiXin Param:tmpDic success:^(id responseObject) {
        [MBProgressHUD dismissInView:self.view];
        [[TIoTCoreUserManage shared] saveAccessToken:responseObject[@"Data"][@"Token"] expireAt:responseObject[@"Data"][@"ExpireAt"]];
        
        if (responseObject[@"Data"][@"CancelAccountTime"]) {
            self.cancelAccountTimeString = [NSString stringWithFormat:@"%@",responseObject[@"Data"][@"CancelAccountTime"]];
        }else {
            self.cancelAccountTimeString = nil;
        }
        
        [self loginSuccess];
        //信鸽推送注册
        [[XGPushManage sharedXGPushManage] startPushService];
        
        [HXYNotice addLoginInPost];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:NSLocalizedString(@"ensure_import_wechat_login_with_offical_doc", @"请确保已按官网文档接入微信登录")];
    }];
}

- (void)forgetPasswordClick {
    TIoTPhoneResetPwdViewController *vc = [[TIoTPhoneResetPwdViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)changedTextField:(UITextField *)textField {
    
    if (self.loginStyle == YES) {    //验证码登录

        [self judgeVerificationButtonResponse];
        
        if (([NSString judgePhoneNumberLegal:self.phoneAndEmailTF.text] || [NSString judgeEmailLegal:self.phoneAndEmailTF.text]) && (![self.verificationcodeTF.text isEqual: @""] && self.verificationcodeTF.text != nil) && (self.verificationcodeTF.text.length == 6)) {
            self.loginAccountButton.backgroundColor =kMainColor;
            self.loginAccountButton.enabled = YES;
        }else {
            self.loginAccountButton.backgroundColor = kMainColorDisable;
            self.loginAccountButton.enabled = NO;
        }
        
    }else {                          //账号密码登录
        
        if (([NSString judgePhoneNumberLegal:self.phoneAndEmailTF2.text] || [NSString judgeEmailLegal:self.phoneAndEmailTF2.text]) && [NSString judgePassWordLegal:self.passwordTF.text]) {
            self.loginAccountButton.backgroundColor =kMainColor;
            self.loginAccountButton.enabled = YES;
        }else {
            self.loginAccountButton.backgroundColor = kMainColorDisable;
            self.loginAccountButton.enabled = NO;
        }
    }
    
    
}

@end
