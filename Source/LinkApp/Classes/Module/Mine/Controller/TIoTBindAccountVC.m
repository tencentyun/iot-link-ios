//
//  TIoTBindAccountVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/7/30.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTBindAccountVC.h"
#import "XWCountryCodeController.h"
#import "TIoTBindAccountView.h"
#import "TIoTChooseRegionVC.h"
#import "NSObject+CountdownTimer.h"

@interface TIoTBindAccountVC ()<TIoTBindAccountViewDelegate>

@property (nonatomic, strong) UIButton      *areaCodeBtn;
@property (nonatomic, strong) NSString      *conturyCode;
@property (nonatomic, strong) TIoTBindAccountView *bindAccountView;
@end

@implementation TIoTBindAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
}

- (void)setUpUI{
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.accountType == AccountType_Phone) {
        self.title = NSLocalizedString(@"bind_phonenumber", @"绑定手机");
    }else if (self.accountType == AccountType_Email) {
        self.title = NSLocalizedString(@"bind_email_address", @"绑定邮箱");
    }
    
    self.conturyCode = @"86";
    
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
    
    UIImageView *imgV = [UIImageView new];
    imgV.image = [UIImage imageNamed:@"mineArrow"];
    [self.view addSubview:imgV];
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.areaCodeBtn.mas_trailing).offset(5);
        make.centerY.equalTo(self.areaCodeBtn);
    }];
    
    [self.view addSubview:self.bindAccountView];
    [self.bindAccountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.areaCodeBtn.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    if (self.accountType == AccountType_Phone) {
        
    }else if (self.accountType == AccountType_Email) {
        self.areaCodeBtn.hidden = YES;
        imgV.hidden = YES;
        [self.bindAccountView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(48 * kScreenAllHeightScale - kPadding);
            }else {
                make.top.equalTo(self.view.mas_top).offset(64 + 48 * kScreenAllHeightScale - kPadding);
            }

        }];
    }
    
    [self responseBindVerificationButton];
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

- (TIoTBindAccountView *)bindAccountView {
    if (!_bindAccountView) {
        _bindAccountView = [[TIoTBindAccountView alloc]init];
        _bindAccountView.delegate = self;
        if (self.accountType == AccountType_Phone) {
            _bindAccountView.bindAccoutType = BindAccountPhoneType;
        }else if (self.accountType == AccountType_Email) {
            _bindAccountView.bindAccoutType = BindAccountEmailType;
        }
        
    }
    return _bindAccountView;
}

#pragma mark - event
- (void)choseAreaCode:(id)sender{
    
//    XWCountryCodeController *countryCodeVC = [[XWCountryCodeController alloc] init];
//    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
//        self.conturyCode = code;
//        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",countryName] forState:UIControlStateNormal];
//    };
//    [self.navigationController pushViewController:countryCodeVC animated:YES];
    
    TIoTChooseRegionVC *regionVC = [[TIoTChooseRegionVC alloc]init];
    
    regionVC.returnRegionBlock = ^(NSString * _Nonnull Title,NSString * _Nonnull region,NSString * _Nonnull RegionID,NSString *_Nullable CountryCode) {
    
        self.conturyCode = CountryCode;
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:regionVC animated:YES];
}


#pragma mark - TIoTBindAccountViewDelegate
- (void)bindAccountSendCodeWithAccountType:(BindAccountType)accountType {
    
    NSDictionary *tmpDic = nil;
    NSString *actioinString = @"";
    
    if (accountType == BindAccountPhoneType) {
        
        tmpDic = @{@"Type":@"register",@"CountryCode":self.conturyCode,@"PhoneNumber":self.bindAccountView.phoneOrEmailTF.text};
        actioinString = AppSendVerificationCode;
        
        //等待发送验证码倒计时
        [NSObject countdownTimerWithShowView:self.bindAccountView.verificationButton inputText:self.bindAccountView.phoneOrEmailTF.text phoneOrEmailType:YES];
        
    }else if (accountType == BindAccountEmailType) {
        
        tmpDic = @{@"Type":@"register",@"Email":self.bindAccountView.phoneOrEmailTF.text};
        actioinString = AppSendEmailVerificationCode;
        
        //等待发送验证码倒计时
        [NSObject countdownTimerWithShowView:self.bindAccountView.verificationButton inputText:self.bindAccountView.phoneOrEmailTF.text phoneOrEmailType:NO];
    }
    
    [[TIoTRequestObject shared] postWithoutToken:actioinString Param:tmpDic success:^(id responseObject) {

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

    }];
    
}

- (void)bindAccountChangedTextFieldWithAccountType:(BindAccountType)accountType {
    //需要验证手机号、验证码、密码
    BOOL isPhoneTypeOrEmail = NO;
    if (accountType == BindAccountPhoneType) {
        isPhoneTypeOrEmail = [NSString judgePhoneNumberLegal:self.bindAccountView.phoneOrEmailTF.text];
    }else if (accountType == BindAccountEmailType) {
        isPhoneTypeOrEmail = [NSString judgeEmailLegal:self.bindAccountView.phoneOrEmailTF.text];
    }
    
    [self responseBindVerificationButton];
    
    if (isPhoneTypeOrEmail && ![NSString isNullOrNilWithObject:self.bindAccountView.verificationCodeTF.text] && self.bindAccountView.verificationCodeTF.text.length == 6) {
        
        if (self.bindAccountView.passwordTF.isHidden || self.bindAccountView.passwordConfirmTF.isHidden) {
            
            self.bindAccountView.confirmButton.backgroundColor =kMainColor;
            self.bindAccountView.confirmButton.enabled = YES;
            
        }else if (self.bindAccountView.passwordTF.text.length >= 1 && self.bindAccountView.passwordConfirmTF.text.length >= 1) {
            
            self.bindAccountView.confirmButton.backgroundColor =kMainColor;
            self.bindAccountView.confirmButton.enabled = YES;
            
        }else {
            
            self.bindAccountView.confirmButton.backgroundColor = kMainColorDisable;
            self.bindAccountView.confirmButton.enabled = NO;
        }
        
        
    }else {
        self.bindAccountView.confirmButton.backgroundColor = kMainColorDisable;
        self.bindAccountView.confirmButton.enabled = NO;
    }
}

- (void)bindAccountConfirmClickButtonWithAccountType:(BindAccountType)accountType {
    
    if (![self.bindAccountView.passwordTF.text isEqualToString:self.bindAccountView.passwordConfirmTF.text]) {
        [MBProgressHUD showMessage:NSLocalizedString(@"two_password_not_same", @"两次输入的密码不一致") icon:@"" toView:self.view];
        return;
    }
    
    BOOL isPass = [NSString judgePassWordLegal:self.bindAccountView.passwordTF.text];
    if (!isPass) {
        [MBProgressHUD showMessage:NSLocalizedString(@"password_irregularity", @"密码不合规") icon:@"" toView:self.view];
        return;
    }
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    NSDictionary *tmpDic = nil;
    
    if (accountType == BindAccountPhoneType) {
        if ([[TIoTCoreUserManage shared].hasPassword isEqualToString:@"1"]) {
            tmpDic = @{@"CountryCode":self.conturyCode,@"PhoneNumber":self.bindAccountView.phoneOrEmailTF.text,@"VerificationCode":self.bindAccountView.verificationCodeTF.text};
        }else {
            tmpDic = @{@"CountryCode":self.conturyCode,@"PhoneNumber":self.bindAccountView.phoneOrEmailTF.text,@"VerificationCode":self.bindAccountView.verificationCodeTF.text,@"NewPasword":self.bindAccountView.passwordTF.text};
        }
        
    }else if (accountType ==BindAccountEmailType) {
        if ([[TIoTCoreUserManage shared].hasPassword isEqualToString:@"1"]) {
            tmpDic = @{@"Email":self.bindAccountView.phoneOrEmailTF.text,@"VerificationCode":self.bindAccountView.verificationCodeTF.text};
        }else {
            tmpDic = @{@"Email":self.bindAccountView.phoneOrEmailTF.text,@"VerificationCode":self.bindAccountView.verificationCodeTF.text,@"NewPasword":self.bindAccountView.passwordTF.text};
        }
        
    }
    
    [[TIoTRequestObject shared] post:AppUpdateUser Param:tmpDic success:^(id responseObject) {
        [MBProgressHUD showSuccess:NSLocalizedString(@"bind_success", @"绑定成功")];
        [[TIoTCoreUserManage shared] saveUserInfo:tmpDic];
        self.resfreshResponseBlock(YES);
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

#pragma mark - 判断获取验证码是否可点击
- (void)responseBindVerificationButton {
    
    if ([self.bindAccountView.verificationButton.currentTitle isEqual:NSLocalizedString(@"register_get_code", @"获取验证码")] ) {
        
        if (self.accountType == AccountType_Phone) {
            //不为空且格式正确
            if ((![NSString isNullOrNilWithObject:self.bindAccountView.phoneOrEmailTF.text]) && ([NSString judgePhoneNumberLegal:self.bindAccountView.phoneOrEmailTF.text])) {
                [self.bindAccountView.verificationButton setTitleColor:kMainColor forState:UIControlStateNormal];
                self.bindAccountView.verificationButton.enabled = YES;
            }else {
                [self.bindAccountView.verificationButton setTitleColor:[UIColor colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
                self.bindAccountView.verificationButton.enabled = NO;
            }
        }else if (self.accountType == AccountType_Email) {
            //不为空且格式正确
            if ((![NSString isNullOrNilWithObject:self.bindAccountView.phoneOrEmailTF.text]) && ([NSString judgeEmailLegal:self.bindAccountView.phoneOrEmailTF.text])) {
                [self.bindAccountView.verificationButton setTitleColor:kMainColor forState:UIControlStateNormal];
                self.bindAccountView.verificationButton.enabled = YES;
            }else {
                [self.bindAccountView.verificationButton setTitleColor:[UIColor colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
                self.bindAccountView.verificationButton.enabled = NO;
            }
        }
        
    }else {
        [self.bindAccountView.verificationButton setTitleColor:[UIColor colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
        self.bindAccountView.verificationButton.enabled = NO;
        
        //在发验证码倒计时过程中，修改手机或邮箱，用来判断【获取验证码按钮】时候有效可点击
        if (self.accountType == AccountType_Phone) {
            if (([NSString isNullOrNilWithObject:self.bindAccountView.phoneOrEmailTF.text]) || !([NSString judgePhoneNumberLegal:self.bindAccountView.phoneOrEmailTF.text])) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"verificationCodeNotification" object:@(YES)];
            }
        }else if (self.accountType == AccountType_Email) {
            if (([NSString isNullOrNilWithObject:self.bindAccountView.phoneOrEmailTF.text]) || !([NSString judgeEmailLegal:self.bindAccountView.phoneOrEmailTF.text])) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"verificationCodeNotification" object:@(YES)];
            }
        }
        
    }
    
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
