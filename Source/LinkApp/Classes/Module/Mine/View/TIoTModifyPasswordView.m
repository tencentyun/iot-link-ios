//
//  TIoTModifyPasswordView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/8/1.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTModifyPasswordView.h"
#import "UILabel+TIoTExtension.h"

static CGFloat kSpace = 0;
@interface TIoTModifyPasswordView ()

@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *passTipLabel;
@property (nonatomic, strong) UILabel *passConfirmTipLabel;

@property (nonatomic, strong) UIView *line1;
@property (nonatomic, strong) UILabel *verificationlabel;
@property (nonatomic, strong) UIView *line3;
@property (nonatomic, strong) UILabel *confirmPasswordLabel;
@property (nonatomic, strong) UIView *line4;

@property (nonatomic, assign) CGFloat kPhoneOrEmailFormatError;
@property (nonatomic, assign) CGFloat kPasswordConfirmError;
@property (nonatomic, assign) CGFloat kPassConfirmError;
@end

@implementation TIoTModifyPasswordView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.kPhoneOrEmailFormatError = 0;
    self.kPasswordConfirmError = 0;
    self.kPassConfirmError = 0;
    
    CGFloat kPadding = 16;
    CGFloat kHeight = 48;
    CGFloat kWidthTitle = 80;
    
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    self.phoneOrEmailLabel = [[UILabel alloc]init];
    [self.phoneOrEmailLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.phoneOrEmailLabel];
    [self.phoneOrEmailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kSpace);
        make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
        make.height.mas_equalTo(kHeight);
        make.width.mas_equalTo(kWidthTitle);
    }];
    
    [self.contentView addSubview:self.phoneOrEmailTF];
    [self.phoneOrEmailTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kSpace);
        make.leading.equalTo(self.phoneOrEmailLabel.mas_trailing);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.height.mas_equalTo(kHeight);
    }];
    
    [self.contentView addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneOrEmailTF.mas_bottom).offset(3);
        make.leading.equalTo(self.phoneOrEmailTF.mas_leading);
    }];
    
    self.line1 = [[UIView alloc]init];
    self.line1.backgroundColor = kLineColor;
    [self.contentView addSubview:self.line1];
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneOrEmailLabel.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.phoneOrEmailTF.mas_bottom);
    }];
    
    self.verificationlabel = [[UILabel alloc]init];
    [self.verificationlabel setLabelFormateTitle:NSLocalizedString(@"verification_code", @"验证码") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.verificationlabel];
    [self.verificationlabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(self.line1.mas_bottom).offset(kSpace);
       make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
       make.width.mas_equalTo(kWidthTitle);
       make.height.mas_equalTo(kHeight);
        
    }];
    
    [self.contentView addSubview:self.verificationButton];
    [self.verificationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.top.equalTo(self.verificationlabel.mas_top);
        make.height.mas_equalTo(kHeight);
    }];
    
    [self.contentView addSubview:self.verificationCodeTF];
    [self.verificationCodeTF mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(self.verificationlabel.mas_top);
       make.leading.equalTo(self.verificationlabel.mas_trailing);
//       make.trailing.equalTo(self.verificationButton.mas_leading);
        make.width.mas_equalTo(140);
       make.height.mas_equalTo(kHeight);
    }];
    
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = kLineColor;
    [self.contentView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.verificationlabel.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.verificationCodeTF.mas_bottom);
    }];
    
    UILabel *passwordLabel = [[UILabel alloc]init];
    [passwordLabel setLabelFormateTitle:NSLocalizedString(@"password", @"密码") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:passwordLabel];
    [passwordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(line2.mas_bottom).offset(kSpace);
       make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
       make.width.mas_equalTo(kWidthTitle);
       make.height.mas_equalTo(kHeight);
    }];
    
    CGFloat kPassWordBtnWidth = 18;
    
    [self.contentView addSubview:self.passwordTF];
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(passwordLabel.mas_trailing);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding - kPassWordBtnWidth*2);
        make.height.mas_equalTo(kHeight);
        make.top.equalTo(passwordLabel.mas_top);
    }];
    
    UIButton *passwordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [passwordButton addTarget:self action:@selector(changePasswordTextShow:) forControlEvents:UIControlEventTouchUpInside];
    [passwordButton setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    [self.contentView addSubview:passwordButton];
    [passwordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kPassWordBtnWidth);
        make.centerY.equalTo(self.passwordTF);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
    }];
    
    [self.contentView addSubview:self.passTipLabel];
    [self.passTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTF.mas_bottom).offset(3);
        make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
    }];
    
    self.line3 = [[UIView alloc]init];
    self.line3.backgroundColor = kLineColor;
    [self.contentView addSubview:self.line3];
    [self.line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(passwordLabel.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.passwordTF.mas_bottom);
    }];
    
    self.confirmPasswordLabel = [[UILabel alloc]init];
    [self.confirmPasswordLabel setLabelFormateTitle:NSLocalizedString(@"confirm_password", @"确认密码") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.confirmPasswordLabel];
    [self.confirmPasswordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(self.line3.mas_bottom).offset(kSpace);
       make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
       make.width.mas_equalTo(kWidthTitle);
       make.height.mas_equalTo(kHeight);
        
    }];
    
    [self.contentView addSubview:self.passwordConfirmTF];
    [self.passwordConfirmTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.confirmPasswordLabel.mas_trailing);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding - kPassWordBtnWidth*2);
        make.height.mas_equalTo(kHeight);
        make.top.equalTo(self.confirmPasswordLabel.mas_top);
    }];
    
    UIButton *passwordConfirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [passwordConfirmButton addTarget:self action:@selector(changePasswordConfirmTextShow:) forControlEvents:UIControlEventTouchUpInside];
    [passwordConfirmButton setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    [self.contentView addSubview:passwordConfirmButton];
    [passwordConfirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kPassWordBtnWidth);
        make.centerY.equalTo(self.passwordConfirmTF);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
    }];
    
    self.line4 = [[UIView alloc]init];
    self.line4.backgroundColor = kLineColor;
    [self.contentView addSubview:self.line4];
    [self.line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.passwordConfirmTF.mas_bottom);
    }];
    
    [self.contentView addSubview:self.passConfirmTipLabel];
    [self.passConfirmTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.line4.mas_bottom).offset(3);
        make.leading.equalTo(self.phoneOrEmailTF.mas_leading);
    }];
    
    [self.contentView addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.line4.mas_bottom).offset(24);
        make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - setter and getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
        
    }
    return _contentView;
}

- (UITextField *)phoneOrEmailTF {
    if (!_phoneOrEmailTF) {
        _phoneOrEmailTF = [[UITextField alloc]init];
        _phoneOrEmailTF.textColor = [UIColor colorWithHexString:kRegionHexColor];
        _phoneOrEmailTF.font = [UIFont wcPfRegularFontOfSize:14];
        _phoneOrEmailTF.keyboardType = UIKeyboardTypeNumberPad;
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_input_phonenumber", @"请输入手机号") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        _phoneOrEmailTF.attributedPlaceholder = ap;
        _phoneOrEmailTF.clearButtonMode = UITextFieldViewModeAlways;
        UIButton *clearButton = [_phoneOrEmailTF valueForKey:@"_clearButton"];
        [clearButton setImage:[UIImage imageNamed:@"text_clear"] forState:UIControlStateNormal];
        [_phoneOrEmailTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _phoneOrEmailTF;
  
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont wcPfRegularFontOfSize:12];
        _tipLabel.text = @"";
        _tipLabel.textColor = [UIColor colorWithHexString:kInputErrorTipHexColor];
        _tipLabel.hidden = YES;
    }
    return _tipLabel;
}

- (UILabel *)passTipLabel {
    if (!_passTipLabel) {
        _passTipLabel = [[UILabel alloc] init];
        _passTipLabel.font = [UIFont wcPfRegularFontOfSize:12];
        _passTipLabel.text = @"";
        _passTipLabel.numberOfLines = 0;
        _passTipLabel.textColor = [UIColor colorWithHexString:kInputErrorTipHexColor];
        _passTipLabel.hidden = YES;
    }
    return _passTipLabel;
}

- (UILabel *)passConfirmTipLabel {
    if (!_passConfirmTipLabel) {
        _passConfirmTipLabel = [[UILabel alloc] init];
        _passConfirmTipLabel.font = [UIFont wcPfRegularFontOfSize:12];
        _passConfirmTipLabel.text = @"";
        _passConfirmTipLabel.numberOfLines = 0;
        _passConfirmTipLabel.textColor = [UIColor colorWithHexString:kInputErrorTipHexColor];
        _passConfirmTipLabel.hidden = YES;
    }
    return _passConfirmTipLabel;
}

- (UIButton *)verificationButton {
    if (!_verificationButton) {
        _verificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_verificationButton setTitle:NSLocalizedString(@"register_get_code", @"获取验证码") forState:UIControlStateNormal];
        [_verificationButton setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        _verificationButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_verificationButton setTitleColor:[UIColor colorWithHexString:kPhoneEmailHexColor] forState:UIControlStateNormal];
        _verificationButton.enabled = NO;
        [_verificationButton addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verificationButton;
}

- (UITextField *)verificationCodeTF {
    if (!_verificationCodeTF) {
        _verificationCodeTF = [[UITextField alloc]init];
        _verificationCodeTF.keyboardType = UIKeyboardTypeNumberPad;
        _verificationCodeTF.textColor = [UIColor colorWithHexString:kRegionHexColor];
        _verificationCodeTF.font = [UIFont wcPfRegularFontOfSize:14];
        NSAttributedString *apVerification = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"input_verification_code", @"请输入验证码") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        _verificationCodeTF.attributedPlaceholder = apVerification;
        _verificationCodeTF.clearButtonMode = UITextFieldViewModeAlways;
        UIButton *clearButton = [_verificationCodeTF valueForKey:@"_clearButton"];
        [clearButton setImage:[UIImage imageNamed:@"text_clear"] forState:UIControlStateNormal];
        [_verificationCodeTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _verificationCodeTF;
}

- (UITextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc]init];
        _passwordTF.keyboardType = UITextFieldViewModeAlways;
        _passwordTF.textColor = [UIColor colorWithHexString:kRegionHexColor];
        _passwordTF.secureTextEntry = YES;
        _passwordTF.font = [UIFont wcPfRegularFontOfSize:14];
        NSAttributedString *passwordAttStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_set_passwd", @"请设置您的密码") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        _passwordTF.attributedPlaceholder = passwordAttStr;
//        _passwordTF.clearButtonMode = UITextFieldViewModeAlways;
        [_passwordTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _passwordTF;
}

- (UITextField *)passwordConfirmTF {
    if (!_passwordConfirmTF) {
        _passwordConfirmTF = [[UITextField alloc]init];
        _passwordConfirmTF = [[UITextField alloc]init];
        _passwordConfirmTF.keyboardType = UITextFieldViewModeAlways;
        _passwordConfirmTF.textColor = [UIColor colorWithHexString:kRegionHexColor];
        _passwordConfirmTF.secureTextEntry = YES;
        _passwordConfirmTF.font = [UIFont wcPfRegularFontOfSize:14];
        NSAttributedString *passwordAttStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_confirm_passwd", @"请再次确认您的密码") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        _passwordConfirmTF.attributedPlaceholder = passwordAttStr;
//        _passwordConfirmTF.clearButtonMode = UITextFieldViewModeAlways;
        [_passwordConfirmTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _passwordConfirmTF;;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:NSLocalizedString(@"confirm_to_bind", @"确认绑定") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:[UIColor colorWithHexString:kNoSelectedHexColor]];
        _confirmButton.enabled = NO;
        _confirmButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_confirmButton addTarget:self action:@selector(confirmClickButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (void)changePasswordTextShow:(UIButton *)button {
    
    if (button.selected) {
        self.passwordTF.secureTextEntry = YES;
        [button setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    }else {
        self.passwordTF.secureTextEntry = NO;
        [button setImage:[UIImage imageNamed:@"password_show"] forState:UIControlStateNormal];
    }
    
    button.selected = !button.selected;
    
}

- (void)changePasswordConfirmTextShow:(UIButton *)button {
    
    if (button.selected) {
        self.passwordConfirmTF.secureTextEntry = YES;
        [button setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    }else {
        self.passwordConfirmTF.secureTextEntry = NO;
        [button setImage:[UIImage imageNamed:@"password_show"] forState:UIControlStateNormal];
    }
    
    button.selected = !button.selected;
    
}

- (void)confirmClickButton {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyPasswordConfirmClickButton)]) {
        [self.delegate modifyPasswordConfirmClickButton];
    }
}

-(void)changedTextField:(UITextField *)textField {

    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyPasswordChangedTextField)]) {
        [self.delegate modifyPasswordChangedTextField];
    }
    
    CGFloat intervalSpace = 18;
    CGFloat intervalConfirmSpace = 22;
    
    //优化提示文案
    if (textField == self.phoneOrEmailTF) {
        
        if (self.phoneOrEmailTF.keyboardType == UIKeyboardTypeNumberPad) { //手机号改密码
            
            if ([NSString judgePhoneNumberLegal:self.phoneOrEmailTF.text withRegionID:[TIoTCoreUserManage shared].userRegionId]) { //手机号合格
                self.tipLabel.hidden = YES;
                self.kPhoneOrEmailFormatError = 0;
            }else{ //手机号不合格
                self.tipLabel.hidden = NO;
                self.tipLabel.text = NSLocalizedString(@"phoneNumber_error", "号码错误");
                self.kPhoneOrEmailFormatError = intervalSpace;
            }
            
        }else { //邮箱改密码
            
            if ([NSString judgeEmailLegal:self.phoneOrEmailTF.text]) { //邮箱合格
                self.tipLabel.hidden = YES;
                self.kPhoneOrEmailFormatError = 0;
            }else{ //邮箱合格不合格
                self.tipLabel.hidden = NO;
                self.tipLabel.text = NSLocalizedString(@"email_invalid", @"邮箱地址格式不正确");
                self.kPhoneOrEmailFormatError = intervalSpace;
            }
        }
        
        [self.verificationlabel mas_updateConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.line1.mas_bottom).offset(kSpace+self.kPhoneOrEmailFormatError);
        }];
    }
    
    if (textField == self.passwordTF) {
        if ([NSString judgePassWordLegal:self.passwordTF.text]) {
            self.passTipLabel.hidden = YES;
            self.kPasswordConfirmError = 0;
        }else {
            self.passTipLabel.hidden = NO;
            self.passTipLabel.text = NSLocalizedString(@"password_style", @"密码支持8-16位，必须包含字母和数字");
            self.kPasswordConfirmError = intervalSpace;
        }
        
        [self.confirmPasswordLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.line3.mas_bottom).offset(kSpace+self.kPasswordConfirmError);
        }];
    }
    
    if (textField == self.passwordConfirmTF) {
        if ([self.passwordTF.text isEqualToString:self.passwordConfirmTF.text] && [NSString judgePassWordLegal:self.passwordConfirmTF.text]) {
            self.passConfirmTipLabel.hidden = YES;
            self.kPassConfirmError = 0;
        }else {
            self.passConfirmTipLabel.hidden = NO;
            self.kPassConfirmError = intervalConfirmSpace;
            if (![self.passwordTF.text isEqualToString:self.passwordConfirmTF.text]) {
                self.passConfirmTipLabel.text = NSLocalizedString(@"two_password_not_same", @"两次输入的密码不一致");
            }else if (![NSString judgePassWordLegal:self.passwordConfirmTF.text]) {
                self.passConfirmTipLabel.text = NSLocalizedString(@"password_irregularity", @"密码不合规");
            }
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyPasswordConentIncreaseInterval:)]) {
        [self.delegate modifyPasswordConentIncreaseInterval:(self.kPhoneOrEmailFormatError + self.kPasswordConfirmError + self.kPassConfirmError)];
    }
}

- (void)sendCode:(UIButton *)button {

    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyPasswordSendCode)]) {
        [self.delegate modifyPasswordSendCode];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
