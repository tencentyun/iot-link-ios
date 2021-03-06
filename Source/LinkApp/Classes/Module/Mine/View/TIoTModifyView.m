//
//  TIoTModifyView.m
//  LinkApp
//
//

#import "TIoTModifyView.h"
#import "UILabel+TIoTExtension.h"

static CGFloat kSpace = 0;
@interface TIoTModifyView ()
@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *phoneOrEmailLabel;
@property (nonatomic, strong) UIView *line1;
@property (nonatomic, strong) UILabel *verificationlabel;
@end

@implementation TIoTModifyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    self.backgroundColor = [UIColor whiteColor];
    
    
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
        make.leading.equalTo(self.phoneOrEmailLabel.mas_trailing);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.centerY.equalTo(self.phoneOrEmailLabel);
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
       make.leading.equalTo(self.phoneOrEmailTF.mas_leading);
//       make.trailing.equalTo(self.verificationButton.mas_leading);
        make.width.mas_equalTo(140);
       make.height.mas_equalTo(kHeight);
    }];
    
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = kLineColor;
    [self.contentView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.line1.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.verificationCodeTF.mas_bottom);
    }];
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.bottom.equalTo(line2.mas_top);
    }];
    [self.contentView sendSubviewToBack:bottomView];
    
    [self.contentView addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line2.mas_bottom).offset(24);
        make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.height.mas_equalTo(40);
    }];
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    NSString *placeHoldString = @"";
    if (self.modifyAccoutType == ModifyAccountPhoneType) {
        placeHoldString = NSLocalizedString(@"please_input_phonenumber", @"请输入手机号");
        _phoneOrEmailTF.keyboardType = UIKeyboardTypeNumberPad;
        self.phoneOrEmailLabel.text = NSLocalizedString(@"phone_number", @"手机号码");
    }else if (self.modifyAccoutType == ModifyAccountEmailType) {
        placeHoldString = NSLocalizedString(@"write_email_address", @"请输入邮箱");
        _phoneOrEmailTF.keyboardType = UIKeyboardTypeEmailAddress;
        self.phoneOrEmailLabel.text = NSLocalizedString(@"email_account", @"邮箱账号");
    }
    NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:placeHoldString attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
    self.phoneOrEmailTF.attributedPlaceholder = attriStr;
    
}

#pragma mark - setter and getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        
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
        NSAttributedString *apVerification = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"input_verification_code", @"输入验证码") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        _verificationCodeTF.attributedPlaceholder = apVerification;
        _verificationCodeTF.clearButtonMode = UITextFieldViewModeAlways;
        UIButton *clearButton = [_verificationCodeTF valueForKey:@"_clearButton"];
        [clearButton setImage:[UIImage imageNamed:@"text_clear"] forState:UIControlStateNormal];
        [_verificationCodeTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _verificationCodeTF;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:NSLocalizedString(@"confirm_to_modify", @"确认修改") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:[UIColor colorWithHexString:kNoSelectedHexColor]];
        _confirmButton.enabled = NO;
        _confirmButton.layer.cornerRadius = 20;
        _confirmButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [_confirmButton addTarget:self action:@selector(confirmClickButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (void)confirmClickButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyAccountConfirmClickButtonWithAccountType:)]) {
        [self.delegate modifyAccountConfirmClickButtonWithAccountType:self.modifyAccoutType];
    }
}

-(void)changedTextField:(UITextField *)textField {

    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyAccountChangedTextFieldWithAccountType:)]) {
        [self.delegate modifyAccountChangedTextFieldWithAccountType:self.modifyAccoutType];
    }
    
    CGFloat intervalSpace = 18;
    
    //优化提示文案
    if (textField == self.phoneOrEmailTF) {
        
        if (self.phoneOrEmailTF.keyboardType == UIKeyboardTypeNumberPad) { //手机号改密码
            
            if ([NSString judgePhoneNumberLegal:self.phoneOrEmailTF.text withRegionID:[TIoTCoreUserManage shared].userRegionId]) { //手机号合格
                self.tipLabel.hidden = YES;
                intervalSpace = 0;
            }else{ //手机号不合格
                self.tipLabel.hidden = NO;
                self.tipLabel.text = NSLocalizedString(@"phoneNumber_error", "号码错误");
                intervalSpace = 18;
            }
            
        }else { //邮箱改密码
            
            if ([NSString judgeEmailLegal:self.phoneOrEmailTF.text]) { //邮箱合格
                self.tipLabel.hidden = YES;
                intervalSpace = 0;
            }else{ //邮箱合格不合格
                self.tipLabel.hidden = NO;
                self.tipLabel.text = NSLocalizedString(@"email_invalid", @"邮箱地址格式不正确");
                intervalSpace = 18;
            }
        }
        
        [self.verificationlabel mas_updateConstraints:^(MASConstraintMaker *make) {
           make.top.equalTo(self.line1.mas_bottom).offset(kSpace+intervalSpace);
        }];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyAccountConentIncreaseInterval:accountType:)]) {
        [self.delegate modifyAccountConentIncreaseInterval:intervalSpace accountType:self.modifyAccoutType];
    }

}

- (void)sendCode:(UIButton *)button {

    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyAccountSendCodeWithAccountType:)]) {
        [self.delegate modifyAccountSendCodeWithAccountType:self.modifyAccoutType];
    }
    
}
@end
