//
//  TIoTModifyPasswordVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/7/31.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTModifyPasswordVC.h"
#import "TIoTModifyPasswordView.h"
#import "XWCountryCodeController.h"
#import "TIoTNavigationController.h"
#import "TIoTMainVC.h"
#import "TIoTAppEnvironment.h"
#import "TIoTAlertView.h"
#import "TIoTChooseRegionVC.h"
#import "NSObject+CountdownTimer.h"

@interface TIoTModifyPasswordVC ()<TIoTModifyPasswordViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL     modifyStyle;            // YES 手机  NO 邮箱

@property (nonatomic, strong) TIoTModifyPasswordView *contentView;
@property (nonatomic, strong) UIButton *areaCodeBtn;
@property (nonatomic, strong) NSString *conturyCode;
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) TIoTModifyPasswordView *contentView2;

@property (nonatomic, strong) NSString *conturyCode2;

@property (nonatomic, strong) UIButton *comfirmModifyButton;

@end

@implementation TIoTModifyPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
}

- (void)setUpUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"modify_password", @"修改密码");
    self.conturyCode = @"86";
    self.conturyCode2 = @"86";
    self.modifyStyle = YES;
    
    CGFloat kPadding = 30;
    
    [self.view addSubview:self.areaCodeBtn];
    [self.areaCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {

        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(48 * kScreenAllHeightScale);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64 + 48 * kScreenAllHeightScale);
        }
        make.leading.mas_equalTo(kPadding);
        make.height.mas_equalTo(kPadding);
    }];
    
    self.imgV = [UIImageView new];
    self.imgV.image = [UIImage imageNamed:@"mineArrow"];
    [self.view addSubview:self.imgV];
    [self.imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.areaCodeBtn.mas_trailing).offset(5);
        make.centerY.equalTo(self.areaCodeBtn);
    }];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.areaCodeBtn.mas_bottom);
        
        make.height.mas_equalTo(278 * kScreenAllHeightScale);
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
    
    UIButton *verificationCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [verificationCodeButton setTitle:NSLocalizedString(@"email_verify_mofify", @"邮箱验证修改") forState:UIControlStateNormal];
    [verificationCodeButton setTitleColor:[UIColor colorWithHexString:@"006EFF"] forState:UIControlStateNormal];
    verificationCodeButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
    [verificationCodeButton addTarget:self action:@selector(modifyStyleChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:verificationCodeButton];
    [verificationCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(30 * kScreenAllWidthScale);
        make.top.equalTo(self.scrollView.mas_bottom).offset(10 * kScreenAllWidthScale);
    }];
    
    [self.view addSubview:self.comfirmModifyButton];
    [self.comfirmModifyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(verificationCodeButton.mas_bottom).offset(60 *kScreenAllHeightScale);
        make.leading.mas_equalTo(kPadding * kScreenAllWidthScale);
        make.trailing.mas_equalTo(-kPadding * kScreenAllWidthScale);
        make.height.mas_equalTo(48 * kScreenAllHeightScale);
    }];
 
    [self responsedModifyPasswordVerifivationButton];
}

#pragma mark - setter and getter

- (UIButton *)areaCodeBtn {
    if (!_areaCodeBtn) {
        _areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
        [_areaCodeBtn setTitleColor:kFontColor forState:UIControlStateNormal];
        _areaCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _areaCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [_areaCodeBtn addTarget:self action:@selector(choseAreaCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _areaCodeBtn;
}

- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = NO;
    }
    return _scrollView;
}

- (TIoTModifyPasswordView *)contentView {
    if (!_contentView) {
        _contentView = [[TIoTModifyPasswordView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.delegate = self;
        _contentView.confirmButton.hidden = YES;
        
    }
    return _contentView;
}

- (TIoTModifyPasswordView *)contentView2 {
    if (!_contentView2) {
        _contentView2 = [[TIoTModifyPasswordView alloc]init];
        _contentView2.backgroundColor = [UIColor whiteColor];
        _contentView2.delegate = self;
        _contentView2.confirmButton.hidden = YES;
    }
    return _contentView2;
}

- (UIButton *)comfirmModifyButton {
    if (!_comfirmModifyButton) {
        _comfirmModifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_comfirmModifyButton setTitle:NSLocalizedString(@"confirm_to_modify", @"确认修改") forState:UIControlStateNormal];
        [_comfirmModifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_comfirmModifyButton setBackgroundColor:kMainColorDisable];
        _comfirmModifyButton.enabled = NO;
        _comfirmModifyButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_comfirmModifyButton addTarget:self action:@selector(modifySure) forControlEvents:UIControlEventTouchUpInside];
    }
    return _comfirmModifyButton;;
}

#pragma mark - event

- (void)choseAreaCode:(id)sender{
    
//    XWCountryCodeController *countryCodeVC = [[XWCountryCodeController alloc] init];
//    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
//        self.conturyCode = code;
//        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",countryName] forState:UIControlStateNormal];
//    };
//
//    [self.navigationController pushViewController:countryCodeVC animated:YES];
    
    TIoTChooseRegionVC *regionVC = [[TIoTChooseRegionVC alloc]init];
    
    regionVC.returnRegionBlock = ^(NSString * _Nonnull Title,NSString * _Nonnull region,NSString * _Nonnull RegionID,NSString *_Nullable CountryCode) {
    
        self.conturyCode = CountryCode;
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:regionVC animated:YES];
}

- (void)modifyStyleChange:(UIButton *)sender {
    [self.view endEditing:YES];
    
    self.comfirmModifyButton.backgroundColor = kMainColorDisable;
    self.comfirmModifyButton.enabled = NO;
    if ([sender.titleLabel.text containsString:NSLocalizedString(@"verification_code", @"验证码")]) {
        self.modifyStyle = YES;
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [sender setTitle:NSLocalizedString(@"email_verify_mofify", @"邮箱验证修改") forState:UIControlStateNormal];
        self.contentView.phoneOrEmailTF.text = @"";
        self.contentView.verificationCodeTF.text = @"";
        self.contentView.passwordTF.text = @"";
        self.contentView.passwordConfirmTF.text = @"";
        NSString *placeHoldString = placeHoldString = NSLocalizedString(@"please_input_phonenumber", @"请输入手机号");
        self.contentView.phoneOrEmailTF.keyboardType = UIKeyboardTypeNumberPad;
        NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:placeHoldString attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#cccccc"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        self.contentView.phoneOrEmailTF.attributedPlaceholder = attriStr;
        
        self.areaCodeBtn.hidden = NO;
        self.imgV.hidden = NO;

    }else {
        self.modifyStyle = NO;
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
        [sender setTitle:NSLocalizedString(@"phone_verify_code_modify", @"手机验证码修改") forState:UIControlStateNormal];
        self.contentView2.phoneOrEmailTF.text = @"";
        self.contentView2.verificationCodeTF.text = @"";
        self.contentView2.passwordTF.text = @"";
        self.contentView2.passwordConfirmTF.text = @"";
        NSString *placeHoldString = placeHoldString = NSLocalizedString(@"write_email_address", @"请输入邮箱");
        self.contentView2.phoneOrEmailTF.keyboardType = UIKeyboardTypeEmailAddress;
        NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:placeHoldString attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#cccccc"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        self.contentView2.phoneOrEmailTF.attributedPlaceholder = attriStr;
        
        self.areaCodeBtn.hidden = YES;
        self.imgV.hidden = YES;
    }
}

- (void)modifySure {
    
    if ([NSString judgePhoneNumberLegal:self.contentView.phoneOrEmailTF.text]) {       //手机号获取验证码

        [self checkPasswordWithPassword:self.contentView.passwordTF.text confimPassword:self.contentView.passwordConfirmTF.text];

        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];

        NSDictionary *tmpDic = @{@"CountryCode":self.conturyCode,@"VerificationCode":self.contentView.verificationCodeTF.text,@"PhoneNumber":self.contentView.phoneOrEmailTF.text,@"Password":self.contentView.passwordTF.text};
        [[TIoTRequestObject shared] postWithoutToken:AppResetPasswordByCellphone Param:tmpDic success:^(id responseObject) {

            [self modifySuccessAlert];

        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

        }];

    }else if ([NSString judgeEmailLegal:self.contentView2.phoneOrEmailTF.text]) {       //邮箱获取验证码

        [self checkPasswordWithPassword:self.contentView2.passwordTF.text confimPassword:self.contentView2.passwordConfirmTF.text];

        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];

        NSDictionary *tmpDic = @{@"Email":self.contentView2.phoneOrEmailTF.text,@"VerificationCode":self.contentView2.verificationCodeTF.text,@"Password":self.contentView2.passwordTF.text};
        [[TIoTRequestObject shared] postWithoutToken:AppResetPasswordByEmail Param:tmpDic success:^(id responseObject) {
            
            [self modifySuccessAlert];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

        }];
    }
}

- (void)modifySuccessAlert {
    
    TIoTAlertView *modifyAlertView = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleText];
    [modifyAlertView alertWithTitle:NSLocalizedString(@"modify_passwd_success", @"密码修改成功，请重新登录") message:@"" cancleTitlt:@"" doneTitle:NSLocalizedString(@"have_known", @"知道了")];
    [modifyAlertView showSingleConfrimButton];
    modifyAlertView.doneAction = ^(NSString * _Nonnull text) {
        [[TIoTAppEnvironment shareEnvironment] loginOut];
        TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTMainVC alloc] init]];
        self.view.window.rootViewController = nav;
    };
    [modifyAlertView showInView:[UIApplication sharedApplication].keyWindow];
}
#pragma mark - TIoTModifyPasswordViewDelegate

- (void)modifyPasswordSendCode {

    //等待发送验证码倒计时
    
    if (self.modifyStyle == YES) {
        
        //等待发送验证码倒计时
        [NSObject countdownTimerWithShowView:self.contentView.verificationButton inputText:self.contentView.phoneOrEmailTF.text phoneOrEmailType:YES];
    }else {
        
        //等待发送验证码倒计时
        [NSObject countdownTimerWithShowView:self.contentView2.verificationButton inputText:self.contentView2.phoneOrEmailTF.text phoneOrEmailType:NO];
    }
    
    if ([NSString judgePhoneNumberLegal:self.contentView.phoneOrEmailTF.text]) {       //手机号获取验证码
        
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        NSDictionary *tmpDic = @{@"Type":@"resetpass",@"CountryCode":self.conturyCode,@"PhoneNumber":self.contentView.phoneOrEmailTF.text};
        [[TIoTRequestObject shared] postWithoutToken:AppSendVerificationCode Param:tmpDic success:^(id responseObject) {

        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

        }];

    }else if ([NSString judgeEmailLegal:self.contentView2.phoneOrEmailTF.text]) {       //邮箱获取验证码
        
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        NSDictionary *tmpDic = @{@"Type":@"resetpass",@"Email":self.contentView2.phoneOrEmailTF.text};
        [[TIoTRequestObject shared] postWithoutToken:AppSendEmailVerificationCode Param:tmpDic success:^(id responseObject) {

        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

        }];
    }
}

- (void)checkPasswordWithPassword:(NSString *)password confimPassword:(NSString *)confimPassword {
    
    if (![password isEqualToString:confimPassword]) {
        [MBProgressHUD showMessage:NSLocalizedString(@"two_password_not_same", @"两次输入的密码不一致") icon:@"" toView:self.view];
        return;
    }
    
    BOOL isPass = [NSString judgePassWordLegal:password];
    if (!isPass) {
        [MBProgressHUD showMessage:NSLocalizedString(@"password_irregularity", @"密码不合规") icon:@"" toView:self.view];
        return;
    }
}

- (void)modifyPasswordChangedTextField {
    
    [self responsedModifyPasswordVerifivationButton];
    
    //需要验证手机号、验证码、密码

    if (self.modifyStyle == YES) {
        if ([NSString judgePhoneNumberLegal:self.contentView.phoneOrEmailTF.text] && ![NSString isNullOrNilWithObject:self.contentView.verificationCodeTF.text] && self.contentView.verificationCodeTF.text.length == 6 && (self.contentView.passwordTF.text.length >= 8 && self.contentView.passwordConfirmTF.text.length >= 8)) {
            self.comfirmModifyButton.backgroundColor =kMainColor;
            self.comfirmModifyButton.enabled = YES;
        }else {
            
            self.comfirmModifyButton.backgroundColor = kMainColorDisable;
            self.comfirmModifyButton.enabled = NO;
            
        }
        
    }else {
        if ([NSString judgeEmailLegal:self.contentView2.phoneOrEmailTF.text] && ![NSString isNullOrNilWithObject:self.contentView2.verificationCodeTF.text] && self.contentView2.verificationCodeTF.text.length == 6 && (self.contentView2.passwordTF.text.length >= 8 && self.contentView2.passwordConfirmTF.text.length >= 8)) {
            self.comfirmModifyButton.backgroundColor =kMainColor;
            self.comfirmModifyButton.enabled = YES;
        }else {
            
            self.comfirmModifyButton.backgroundColor = kMainColorDisable;
            self.comfirmModifyButton.enabled = NO;
        }
    }
}

#pragma mark - 判断获取验证码按钮可否可点击
- (void)responsedModifyPasswordVerifivationButton {
    
    if (self.modifyStyle == YES) {
        
        if ([self.contentView.verificationButton.currentTitle isEqual:NSLocalizedString(@"register_get_code", @"获取验证码")] )  {
            if (![NSString isNullOrNilWithObject:self.contentView.phoneOrEmailTF.text] && ([NSString judgePhoneNumberLegal:self.contentView.phoneOrEmailTF.text])) {
                [self.contentView.verificationButton setTitleColor:kMainColor forState:UIControlStateNormal];
                self.contentView.verificationButton.enabled = YES;
            }else {
                [self.contentView.verificationButton setTitleColor:[UIColor colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
                self.contentView.verificationButton.enabled = NO;
            }
        }else {
            [self.contentView.verificationButton setTitleColor:[UIColor colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
            self.contentView.verificationButton.enabled = NO;
            
            //在发验证码倒计时过程中，修改手机或邮箱，用来判断【获取验证码按钮】时候有效可点击
            if ([NSString isNullOrNilWithObject:self.contentView.phoneOrEmailTF.text] || !([NSString judgePhoneNumberLegal:self.contentView.phoneOrEmailTF.text])) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"verificationCodeNotification" object:@(YES)];
            }
        }
        
        
    }else {
        if ([self.contentView2.verificationButton.currentTitle isEqual:NSLocalizedString(@"register_get_code", @"获取验证码")] )  {
            if (![NSString isNullOrNilWithObject:self.contentView2.phoneOrEmailTF.text] && ([NSString judgeEmailLegal:self.contentView2.phoneOrEmailTF.text])) {
                [self.contentView2.verificationButton setTitleColor:kMainColor forState:UIControlStateNormal];
                self.contentView2.verificationButton.enabled = YES;
            }else {
                [self.contentView2.verificationButton setTitleColor:[UIColor colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
                self.contentView2.verificationButton.enabled = NO;
            }
            
        }else {
            [self.contentView2.verificationButton setTitleColor:[UIColor colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
            self.contentView2.verificationButton.enabled = NO;
            
            //在发验证码倒计时过程中，修改手机或邮箱，用来判断【获取验证码按钮】时候有效可点击
            if ([NSString isNullOrNilWithObject:self.contentView2.phoneOrEmailTF.text] || !([NSString judgeEmailLegal:self.contentView2.phoneOrEmailTF.text])) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"verificationCodeNotification" object:@(YES)];
            }
            
        }
        
        
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
