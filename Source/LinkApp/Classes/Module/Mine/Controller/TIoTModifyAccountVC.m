//
//  TIoTModifyAccountVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/7/31.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTModifyAccountVC.h"
#import "XWCountryCodeController.h"
#import "TIoTModifyView.h"
#import "TIoTChooseRegionVC.h"
#import "NSObject+CountdownTimer.h"

@interface TIoTModifyAccountVC ()<TIoTModifyAccountViewDelegate>
@property (nonatomic, strong) UIButton      *areaCodeBtn;
@property (nonatomic, strong) NSString      *conturyCode;
@property (nonatomic, strong) TIoTModifyView *modifyView;
@end

@implementation TIoTModifyAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.accountType == AccountModifyType_Phone) {
        self.title = @"修改手机号";
    }else if (self.accountType == AccountModifyType_Email) {
        self.title = @"修改邮箱";
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
    
    [self.view addSubview:self.modifyView];
    [self.modifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.areaCodeBtn.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    if (self.accountType == AccountModifyType_Phone) {
        
    }else if (self.accountType == AccountModifyType_Email) {
        self.areaCodeBtn.hidden = YES;
        imgV.hidden = YES;
        [self.modifyView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(48 * kScreenAllHeightScale - kPadding);
            }else {
                make.top.equalTo(self.view.mas_top).offset(64 + 48 * kScreenAllHeightScale - kPadding);
            }

        }];
    }
    
    [self responseModifyVerificationButton];
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

- (TIoTModifyView *)modifyView {
    if (!_modifyView) {
        _modifyView = [[TIoTModifyView alloc]init];
        _modifyView.delegate = self;
        if (self.accountType == AccountModifyType_Phone) {
            _modifyView.modifyAccoutType = ModifyAccountPhoneType;
        }else if (self.accountType == AccountModifyType_Email) {
            _modifyView.modifyAccoutType = ModifyAccountEmailType;
        }
        
    }
    return _modifyView;
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

#pragma mark - TIoTModifyAccountViewDelegate

- (void)modifyAccountSendCodeWithAccountType:(ModifyAccountType)accountType {
    NSDictionary *tmpDic = nil;
    NSString *actioinString = @"";
    
    if (accountType == ModifyAccountPhoneType) {
        
        tmpDic = @{@"Type":@"register",@"CountryCode":self.conturyCode,@"PhoneNumber":self.modifyView.phoneOrEmailTF.text};
        actioinString = AppSendVerificationCode;
        
        //等待发送验证码倒计时
        [NSObject countdownTimerWithShowView:self.modifyView.verificationButton inputText:self.modifyView.phoneOrEmailTF.text phoneOrEmailType:YES];
        
    }else if (accountType == ModifyAccountEmailType) {
        
        tmpDic = @{@"Type":@"register",@"Email":self.modifyView.phoneOrEmailTF.text};
        actioinString = AppSendEmailVerificationCode;
        
        //等待发送验证码倒计时
        [NSObject countdownTimerWithShowView:self.modifyView.verificationButton inputText:self.modifyView.phoneOrEmailTF.text phoneOrEmailType:NO];
    }
    
    [[TIoTRequestObject shared] postWithoutToken:actioinString Param:tmpDic success:^(id responseObject) {

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

    }];
}

- (void)modifyAccountChangedTextFieldWithAccountType:(ModifyAccountType)accountType {
    //需要验证手机号、验证码、密码
    BOOL isPhoneTypeOrEmail = NO;
    if (accountType == ModifyAccountPhoneType) {
        isPhoneTypeOrEmail = [NSString judgePhoneNumberLegal:self.modifyView.phoneOrEmailTF.text];
    }else if (accountType == ModifyAccountEmailType) {
        isPhoneTypeOrEmail = [NSString judgeEmailLegal:self.modifyView.phoneOrEmailTF.text];
    }
    
    [self responseModifyVerificationButton];
    
    if (isPhoneTypeOrEmail && ![NSString isNullOrNilWithObject:self.modifyView.verificationCodeTF.text] && self.modifyView.verificationCodeTF.text.length == 6) {
        self.modifyView.confirmButton.backgroundColor =kMainColor;
        self.modifyView.confirmButton.enabled = YES;
    }else {
        self.modifyView.confirmButton.backgroundColor = kMainColorDisable;
        self.modifyView.confirmButton.enabled = NO;
    }
}

- (void)modifyAccountConfirmClickButtonWithAccountType:(ModifyAccountType)accountType {
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    NSDictionary *tmpDic = nil;
    
    if (accountType == ModifyAccountPhoneType) {
        tmpDic = @{@"CountryCode":self.conturyCode,@"PhoneNumber":self.modifyView.phoneOrEmailTF.text,@"VerificationCode":self.modifyView.verificationCodeTF.text};
    }else if (accountType == ModifyAccountEmailType) {
        tmpDic = @{@"Email":self.modifyView.phoneOrEmailTF.text,@"VerificationCode":self.modifyView.verificationCodeTF.text};
    }
    
    [[TIoTRequestObject shared] post:AppUpdateUser Param:tmpDic success:^(id responseObject) {
        [MBProgressHUD showSuccess:NSLocalizedString(@"modify_success", @"修改成功")];
        [[TIoTCoreUserManage shared] saveUserInfo:tmpDic];

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)responseModifyVerificationButton {
    
    if ([self.modifyView.verificationButton.currentTitle isEqual:NSLocalizedString(@"register_get_code", @"获取验证码")] )  {
        if (self.accountType == AccountModifyType_Phone) {
            if (![NSString isNullOrNilWithObject:self.modifyView.phoneOrEmailTF] && ([NSString judgePhoneNumberLegal:self.modifyView.phoneOrEmailTF.text])) {
                [self.modifyView.verificationButton setTitleColor:kMainColor forState:UIControlStateNormal];
                self.modifyView.verificationButton.enabled = YES;
            }else {
                [self.modifyView.verificationButton setTitleColor:[UIColor colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
                self.modifyView.verificationButton.enabled = NO;
            }
        }else if (self.accountType == AccountModifyType_Email) {
            if (![NSString isNullOrNilWithObject:self.modifyView.phoneOrEmailTF] && ([NSString judgeEmailLegal:self.modifyView.phoneOrEmailTF.text])) {
                [self.modifyView.verificationButton setTitleColor:kMainColor forState:UIControlStateNormal];
                self.modifyView.verificationButton.enabled = YES;
            }else {
                [self.modifyView.verificationButton setTitleColor:[UIColor colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
                self.modifyView.verificationButton.enabled = NO;
            }
        }
        
    }else {
        [self.modifyView.verificationButton setTitleColor:[UIColor colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
        self.modifyView.verificationButton.enabled = NO;
        
        //在发验证码倒计时过程中，修改手机或邮箱，用来判断【获取验证码按钮】时候有效可点击
        if (self.accountType == AccountModifyType_Phone) {
            if ([NSString isNullOrNilWithObject:self.modifyView.phoneOrEmailTF] || !([NSString judgePhoneNumberLegal:self.modifyView.phoneOrEmailTF.text])) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"verificationCodeNotification" object:@(YES)];
            }
        }else if (self.accountType == AccountModifyType_Email) {
            if ([NSString isNullOrNilWithObject:self.modifyView.phoneOrEmailTF] || !([NSString judgeEmailLegal:self.modifyView.phoneOrEmailTF.text])) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"verificationCodeNotification" object:@(YES)];
            }
        }
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
