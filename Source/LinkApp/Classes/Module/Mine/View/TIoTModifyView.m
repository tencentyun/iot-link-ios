//
//  TIoTModifyView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/7/31.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTModifyView.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTModifyView ()
@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *phoneOrEmailLabel;
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
    
    CGFloat kSpace = 15;
    CGFloat kPadding = 20;
    CGFloat kHeight = 48;
    CGFloat kWidthTitle = 90;
    
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
        make.top.equalTo(self.contentView.mas_top).offset(kSpace * kScreenAllHeightScale);
        make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
        make.width.mas_equalTo(kWidthTitle);
    }];
    
    [self.contentView addSubview:self.phoneOrEmailTF];
    [self.phoneOrEmailTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneOrEmailLabel.mas_trailing);
        make.centerY.equalTo(self.phoneOrEmailLabel);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
    }];
    
    [self.contentView addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneOrEmailTF.mas_bottom).offset(3);
        make.leading.equalTo(self.phoneOrEmailTF.mas_leading);
    }];
    
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.contentView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.phoneOrEmailLabel.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.phoneOrEmailTF.mas_bottom);
    }];
    
    UILabel *verificationlabel = [[UILabel alloc]init];
    [verificationlabel setLabelFormateTitle:NSLocalizedString(@"verification_code", @"验证码") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:verificationlabel];
    [verificationlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(kSpace*kScreenAllHeightScale);
       make.leading.equalTo(self.contentView.mas_leading).offset(kPadding);
        make.width.mas_equalTo(kWidthTitle);
       make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
        
    }];
    
    [self.contentView addSubview:self.verificationButton];
    [self.verificationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-kPadding);
        make.top.equalTo(verificationlabel.mas_top);
        make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
        make.width.mas_equalTo(100);
    }];
    
    [self.contentView addSubview:self.verificationCodeTF];
    [self.verificationCodeTF mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(verificationlabel.mas_top);
       make.leading.equalTo(self.phoneOrEmailTF.mas_leading);
       make.trailing.equalTo(self.verificationButton.mas_leading);
       make.height.mas_equalTo(kHeight * kScreenAllHeightScale);
    }];
    
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.contentView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(line1.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(1);
        make.top.equalTo(self.verificationCodeTF.mas_bottom);
    }];
    
    [self.contentView addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line2.mas_bottom).offset(60 * kScreenAllHeightScale);
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
    NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:placeHoldString attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#cccccc"],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
    self.phoneOrEmailTF.attributedPlaceholder = attriStr;
    
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
        _phoneOrEmailTF.textColor = [UIColor blackColor];
        _phoneOrEmailTF.font = [UIFont wcPfRegularFontOfSize:14];
        _phoneOrEmailTF.keyboardType = UIKeyboardTypeNumberPad;
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_input_phonenumber", @"请输入手机号") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#cccccc"],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        _phoneOrEmailTF.attributedPlaceholder = ap;
        _phoneOrEmailTF.clearButtonMode = UITextFieldViewModeAlways;
        [_phoneOrEmailTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _phoneOrEmailTF;
  
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:12];
        _tipLabel.text = @"";
        _tipLabel.textColor = UIColor.redColor;
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
        [_verificationButton setTitleColor:[UIColor colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
        _verificationButton.enabled = NO;
        [_verificationButton addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verificationButton;
}

- (UITextField *)verificationCodeTF {
    if (!_verificationCodeTF) {
        _verificationCodeTF = [[UITextField alloc]init];
        _verificationCodeTF.keyboardType = UIKeyboardTypeNumberPad;
        _verificationCodeTF.textColor = [UIColor blackColor];
        _verificationCodeTF.font = [UIFont wcPfRegularFontOfSize:14];
        NSAttributedString *apVerification = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_input_verifycode", @"请输入验证码") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#cccccc"],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        _verificationCodeTF.attributedPlaceholder = apVerification;
        _verificationCodeTF.clearButtonMode = UITextFieldViewModeAlways;
        [_verificationCodeTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    }
    return _verificationCodeTF;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:NSLocalizedString(@"confirm_to_modify", @"确认修改") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:kMainColorDisable];
        _confirmButton.enabled = NO;
        _confirmButton.layer.cornerRadius = 20;
        _confirmButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
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
    
    //优化提示文案
    if (textField == self.phoneOrEmailTF) {
        
        if (self.phoneOrEmailTF.keyboardType == UIKeyboardTypeNumberPad) { //手机号改密码
            
            if ([NSString judgePhoneNumberLegal:self.phoneOrEmailTF.text]) { //手机号合格
                self.tipLabel.hidden = YES;
            }else{ //手机号不合格
                self.tipLabel.hidden = NO;
                self.tipLabel.text = NSLocalizedString(@"phoneNumber_error", "号码错误");
            }
            
        }else { //邮箱改密码
            
            if ([NSString judgeEmailLegal:self.phoneOrEmailTF.text]) { //邮箱合格
                self.tipLabel.hidden = YES;
            }else{ //邮箱合格不合格
                self.tipLabel.hidden = NO;
                self.tipLabel.text = NSLocalizedString(@"email_invalid", @"邮箱地址格式不正确");
            }
        }
        
    }
}

- (void)sendCode:(UIButton *)button {

    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyAccountSendCodeWithAccountType:)]) {
        [self.delegate modifyAccountSendCodeWithAccountType:self.modifyAccoutType];
    }
    
}
@end
