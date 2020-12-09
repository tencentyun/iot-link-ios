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
#import "TIoTCountdownTimer.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTModifyAccountVC ()<TIoTModifyAccountViewDelegate>
@property (nonatomic, strong) UIButton      *areaCodeBtn;
@property (nonatomic, strong) UILabel       *phoneAreaLabel;
@property (nonatomic, strong) NSString      *conturyCode;
@property (nonatomic, strong) TIoTModifyView *modifyView;
@property (nonatomic, strong) TIoTCountdownTimer *countdownTimer;
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
    
    CGFloat kLeftRightPadding = 20;
    CGFloat kWidthTitle = 90;
    CGFloat kHeightCell = 50 * kScreenAllHeightScale;
    
    UIView *topView = [[UIView alloc]init];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(48 * kScreenAllHeightScale);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64 + 48 * kScreenAllHeightScale);
        }
        make.height.mas_equalTo(kHeightCell);
    }];
    
    UILabel *contryLabel = [[UILabel alloc]init];
    [contryLabel setLabelFormateTitle:NSLocalizedString(@"contry_region", @"国家/地区") font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [topView addSubview:contryLabel];
    [contryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kLeftRightPadding);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(kHeightCell);
        make.width.mas_equalTo(kWidthTitle);
    }];
    
    [topView addSubview:self.areaCodeBtn];
    [self.areaCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contryLabel);
        make.left.equalTo(contryLabel.mas_right);
        make.height.mas_equalTo(kHeightCell);
    }];
    
    self.phoneAreaLabel = [[UILabel alloc]init];
    [self.phoneAreaLabel setLabelFormateTitle:@"(+86)" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kRegionHexColor textAlignment:NSTextAlignmentLeft];
    [topView addSubview:self.phoneAreaLabel];
    [self.phoneAreaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.areaCodeBtn.mas_right).offset(5);
        make.centerY.equalTo(contryLabel);
        make.height.mas_equalTo(kHeightCell);
    }];
    
    UIImageView *imgV = [UIImageView new];
    imgV.image = [UIImage imageNamed:@"mineArrow"];
    [topView addSubview:imgV];
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-kLeftRightPadding);
        make.centerY.equalTo(contryLabel);
        make.width.height.mas_equalTo(18);
    }];
    
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = kLineColor;
    [topView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.bottom.equalTo(contryLabel.mas_bottom).offset(-1);
        make.leading.mas_equalTo(kLeftRightPadding);
        make.trailing.mas_equalTo(0);
    }];
    
    UIButton *chooseContryAreaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [chooseContryAreaBtn addTarget:self action:@selector(choseAreaCode) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:chooseContryAreaBtn];
    [chooseContryAreaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(0);
        make.top.equalTo(contryLabel.mas_top);
        make.bottom.equalTo(contryLabel.mas_bottom);
    }];
    
    [self.view addSubview:self.modifyView];
    [self.modifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(topView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    if (self.accountType == AccountModifyType_Phone) {
        
    }else if (self.accountType == AccountModifyType_Email) {
        self.areaCodeBtn.hidden = YES;
        imgV.hidden = YES;
        topView.hidden = YES;
        [self.modifyView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(48 * kScreenAllHeightScale - kLeftRightPadding);
            }else {
                make.top.equalTo(self.view.mas_top).offset(64 + 48 * kScreenAllHeightScale - kLeftRightPadding);
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
        [_areaCodeBtn setTitleColor:[UIColor colorWithHexString:kRegionHexColor] forState:UIControlStateNormal];
        _areaCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _areaCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [_areaCodeBtn addTarget:self action:@selector(choseAreaCode) forControlEvents:UIControlEventTouchUpInside];
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

- (TIoTCountdownTimer *)countdownTimer {
    if (!_countdownTimer) {
        _countdownTimer = [[TIoTCountdownTimer alloc]init];
    }
    return _countdownTimer;
}

#pragma mark - event
- (void)choseAreaCode{
    
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
        self.phoneAreaLabel.text = [NSString stringWithFormat:@"(+%@)",CountryCode];
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
        [self.countdownTimer startTimerWithShowView:self.modifyView.verificationButton inputText:self.modifyView.phoneOrEmailTF.text phoneOrEmailType:YES];
        
    }else if (accountType == ModifyAccountEmailType) {
        
        tmpDic = @{@"Type":@"register",@"Email":self.modifyView.phoneOrEmailTF.text};
        actioinString = AppSendEmailVerificationCode;
        
        //等待发送验证码倒计时
        [self.countdownTimer startTimerWithShowView:self.modifyView.verificationButton inputText:self.modifyView.phoneOrEmailTF.text phoneOrEmailType:NO];
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
    [self.countdownTimer closeTimer];
    [self.countdownTimer clearObserver];
}

@end
