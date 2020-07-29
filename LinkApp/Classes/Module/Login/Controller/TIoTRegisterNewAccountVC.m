//
//  TIoTRegisterNewAccountVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/7/29.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTRegisterNewAccountVC.h"
#import "XWCountryCodeController.h"

@interface TIoTRegisterNewAccountVC ()
@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UIButton      *areaCodeBtn;
@property (nonatomic, strong) NSString      *conturyCode;
@property (nonatomic, strong) UITextField   *phoneTF;
@property (nonatomic, strong) UIButton      *verificationButton;
@property (nonatomic, strong) UITextField   *verificationCodeTF;
@property (nonatomic, strong) UITextField   *passwordTF;
@property (nonatomic, strong) UITextField   *passwordConfirmTF;
@property (nonatomic, strong) UIButton      *confirmButton;
@end

@implementation TIoTRegisterNewAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
}

- (void)setUpUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"新用户注册";
    self.conturyCode = @"86";
    
    CGFloat kSpace = 15;
    CGFloat kPadding = 30;
    CGFloat kHeight = 50;
    
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
    
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.areaCodeBtn.mas_bottom);
    }];
    
    [self.contentView addSubview:self.phoneTF];
    [self.phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kSpace * kScreenAllHeightScale);
        make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
    }];
    
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.contentView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneTF.mas_leading);
        make.trailing.equalTo(self.phoneTF.mas_trailing);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(self.phoneTF.mas_bottom);
    }];
    
    [self.contentView addSubview:self.verificationButton];
    [self.verificationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.top.equalTo(line1.mas_bottom).offset(kSpace);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
    }];
    
    [self.contentView addSubview:self.verificationCodeTF];
    [self.verificationCodeTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verificationButton.mas_top);
       make.leading.equalTo(self.phoneTF.mas_leading);
       make.trailing.equalTo(self.verificationButton.mas_leading);
       make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
    }];
    
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.contentView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneTF.mas_leading);
        make.trailing.equalTo(self.phoneTF.mas_trailing);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(self.verificationCodeTF.mas_bottom);
    }];
    
    [self.contentView addSubview:self.passwordTF];
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneTF.mas_leading);
        make.trailing.equalTo(self.phoneTF.mas_trailing);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
        make.top.equalTo(line2.mas_bottom).offset(kSpace);
    }];
    
    UIView *line3 = [[UIView alloc]init];
    line3.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.contentView addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneTF.mas_leading);
        make.trailing.equalTo(self.phoneTF.mas_trailing);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(self.passwordTF.mas_bottom);
    }];
    
    [self.contentView addSubview:self.passwordConfirmTF];
    [self.passwordConfirmTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneTF.mas_leading);
        make.trailing.equalTo(self.phoneTF.mas_trailing);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
        make.top.equalTo(line3.mas_bottom).offset(kSpace);
    }];
    
    UIView *line4 = [[UIView alloc]init];
    line4.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.contentView addSubview:line4];
    [line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneTF.mas_leading);
        make.trailing.equalTo(self.phoneTF.mas_trailing);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(self.passwordConfirmTF.mas_bottom);
    }];
    
    [self.view addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line4.mas_bottom).offset(60 * kScreenAllHeightScale);
        make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.height.mas_equalTo(48);
    }];
    
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
        
    }
    return _contentView;
}

- (UIButton *)areaCodeBtn {
    if (!_areaCodeBtn) {
        _areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_areaCodeBtn setTitle:[NSString stringWithFormat:@"中国大陆"] forState:UIControlStateNormal];
        [_areaCodeBtn setTitleColor:kFontColor forState:UIControlStateNormal];
        _areaCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _areaCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [_areaCodeBtn addTarget:self action:@selector(choseAreaCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _areaCodeBtn;
}

#pragma mark - setter and getter
- (UITextField *)phoneTF {
    if (!_phoneTF) {
        _phoneTF = [[UITextField alloc]init];
        _phoneTF.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTF.textColor = [UIColor blackColor];
        _phoneTF.font = [UIFont wcPfRegularFontOfSize:16];
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:@"请输入手机号" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#cccccc"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        _phoneTF.attributedPlaceholder = ap;
        _phoneTF.clearButtonMode = UITextFieldViewModeAlways;
        [_phoneTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _phoneTF;
}

- (UIButton *)verificationButton {
    if (!_verificationButton) {
        _verificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_verificationButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_verificationButton setTitleColor:kMainColor forState:UIControlStateNormal];
        _verificationButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [_verificationButton addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verificationButton;
}

- (UITextField *)verificationCodeTF {
    if (!_verificationCodeTF) {
        _verificationCodeTF = [[UITextField alloc]init];
        _verificationCodeTF.keyboardType = UIKeyboardTypePhonePad;
        _verificationCodeTF.textColor = [UIColor blackColor];
        _verificationCodeTF.font = [UIFont wcPfRegularFontOfSize:16];
        NSAttributedString *apVerification = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#cccccc"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        _verificationCodeTF.attributedPlaceholder = apVerification;
        _verificationCodeTF.clearButtonMode = UITextFieldViewModeAlways;
        [_verificationCodeTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _verificationCodeTF;
}

- (UITextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc]init];
        _passwordTF.keyboardType = UITextFieldViewModeAlways;
        _passwordTF.textColor = [UIColor blackColor];
        _passwordTF.secureTextEntry = YES;
        _passwordTF.font = [UIFont wcPfRegularFontOfSize:16];
        NSAttributedString *passwordAttStr = [[NSAttributedString alloc] initWithString:@"请设置您的密码" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#cccccc"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        _passwordTF.attributedPlaceholder = passwordAttStr;
        _passwordTF.clearButtonMode = UITextFieldViewModeAlways;
        [_passwordTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _passwordTF;
}

- (UITextField *)passwordConfirmTF {
    if (!_passwordConfirmTF) {
        _passwordConfirmTF = [[UITextField alloc]init];
        _passwordConfirmTF = [[UITextField alloc]init];
        _passwordConfirmTF.keyboardType = UITextFieldViewModeAlways;
        _passwordConfirmTF.textColor = [UIColor blackColor];
        _passwordConfirmTF.secureTextEntry = YES;
        _passwordConfirmTF.font = [UIFont wcPfRegularFontOfSize:16];
        NSAttributedString *passwordAttStr = [[NSAttributedString alloc] initWithString:@"请再次确认您的密码" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#cccccc"],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        _passwordConfirmTF.attributedPlaceholder = passwordAttStr;
        _passwordConfirmTF.clearButtonMode = UITextFieldViewModeAlways;
        [_passwordConfirmTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _passwordConfirmTF;;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"确认注册" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:kMainColorDisable];
        _confirmButton.enabled = NO;
        _confirmButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:20];
        [_confirmButton addTarget:self action:@selector(confirmClickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

#pragma mark - event
- (void)choseAreaCode:(id)sender{
    
    XWCountryCodeController *countryCodeVC = [[XWCountryCodeController alloc] init];
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
        self.conturyCode = code;
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",countryName] forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:countryCodeVC animated:YES];
}

-(void)changedTextField:(UITextField *)textField {
    //需要验证手机号、验证码、密码
    if ([NSString judgePhoneNumberLegal:self.phoneTF.text] && (![self.verificationCodeTF.text isEqual: @""] && self.verificationCodeTF.text != nil) && (self.passwordTF.text.length >= 8 && self.passwordConfirmTF.text.length >= 8)) {
        self.confirmButton.backgroundColor =kMainColor;
        self.confirmButton.enabled = YES;
    }else {
        self.confirmButton.backgroundColor = kMainColorDisable;
        self.confirmButton.enabled = NO;
    }
}

- (void)confirmClickButton {
    
    if (![self.passwordTF.text isEqualToString:self.passwordConfirmTF.text]) {
        [MBProgressHUD showMessage:@"两次输入的密码不一致" icon:@"" toView:self.view];
        return;
    }
    
    BOOL isPass = [NSString judgePassWordLegal:self.passwordTF.text];
    if (!isPass) {
        [MBProgressHUD showMessage:@"密码不合规" icon:@"" toView:self.view];
        return;
    }
    
    NSDictionary *tmpDic = @{@"CountryCode":self.conturyCode,@"PhoneNumber":self.phoneTF.text,@"VerificationCode":self.verificationCodeTF.text,@"Password":self.passwordTF.text};
    [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
    
    [[TIoTRequestObject shared] postWithoutToken:AppCreateCellphoneUser Param:tmpDic success:^(id responseObject) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
    
}

- (void)sendCode:(UIButton *)button {
    NSDictionary *tmpDic = @{@"Type":@"register",@"CountryCode":self.conturyCode,@"PhoneNumber":self.phoneTF.text};
    [[TIoTRequestObject shared] postWithoutToken:AppSendVerificationCode Param:tmpDic success:^(id responseObject) {
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

#pragma mark - private method


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
