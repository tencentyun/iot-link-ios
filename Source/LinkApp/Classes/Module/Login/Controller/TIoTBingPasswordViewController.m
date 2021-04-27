//
//  WCBingPasswordViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTBingPasswordViewController.h"
#import "UILabel+TIoTExtension.h"

static CGFloat kHeightCell = 48;

@interface TIoTBingPasswordViewController ()

@property (nonatomic, strong) UITextField *passWordTF;
@property (nonatomic, strong) UITextField *passWordTF2;
@property (nonatomic, strong) UIButton *downBtn;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *passTipLabel;
@property (nonatomic, strong) UILabel *passConfirmTipLabel;
@property (nonatomic, strong) UIView *lineView2;
@property (nonatomic, strong) UILabel *passWordLabel2;
@end

@implementation TIoTBingPasswordViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.passWordTF becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

#pragma mark privateMethods
- (void)setUpUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"set_password", @"设置密码");
    
    CGFloat kLeftRightPadding = 16;
    CGFloat kWidthTitle = 80;
    
    UILabel *passWordLabel = [[UILabel alloc]init];
    [passWordLabel setLabelFormateTitle:NSLocalizedString(@"password", @"密码") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.view addSubview:passWordLabel];
    [passWordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kLeftRightPadding);
        make.top.mas_equalTo([TIoTUIProxy shareUIProxy].navigationBarHeight + 52 * kScreenAllHeightScale);
        make.width.mas_equalTo(kWidthTitle);
        make.height.mas_equalTo(kHeightCell);
        make.height.mas_equalTo(kHeightCell);
    }];
    
    CGFloat kPassWordBtnWidth = 18;
    
    self.passWordTF = [[UITextField alloc] init];
    self.passWordTF.textColor = [UIColor colorWithHexString:kRegionHexColor];;
//    self.passWordTF.clearButtonMode = UITextFieldViewModeAlways;
    self.passWordTF.secureTextEntry = YES;
    self.passWordTF.font = [UIFont wcPfRegularFontOfSize:14];
    NSAttributedString *passwordAttStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_set_passwd", @"请设置您的密码") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
    self.passWordTF.attributedPlaceholder = passwordAttStr;
    [self.passWordTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.passWordTF];
    [self.passWordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(passWordLabel.mas_trailing);
        make.centerY.equalTo(passWordLabel);
        make.trailing.equalTo(self.view).offset(-kLeftRightPadding - kPassWordBtnWidth*2);
        make.height.equalTo(passWordLabel);
    }];
    
    UIButton *passwordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [passwordButton addTarget:self action:@selector(changePasswordTextShow:) forControlEvents:UIControlEventTouchUpInside];
    [passwordButton setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    [self.view addSubview:passwordButton];
    [passwordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kPassWordBtnWidth);
        make.centerY.equalTo(self.passWordTF);
        make.trailing.equalTo(self.view.mas_trailing).offset(-kLeftRightPadding);
    }];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = kLineColor;
    [self.view addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passWordTF.mas_bottom).offset(0);
        make.left.equalTo(self.view).offset(kLeftRightPadding);
        make.right.equalTo(self.view).offset(-kLeftRightPadding);
        make.height.mas_equalTo(1);
    }];
    
    [self.view addSubview:self.passTipLabel];
    [self.passTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).offset(3);
        make.left.equalTo(self.view).offset(kLeftRightPadding);
    }];
    
    self.passWordLabel2 = [[UILabel alloc]init];
    [self.passWordLabel2 setLabelFormateTitle:NSLocalizedString(@"confirm_password", @"确认密码") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.view addSubview:self.passWordLabel2];
    [self.passWordLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kLeftRightPadding);
        make.top.equalTo(self.lineView.mas_bottom);
        make.width.mas_equalTo(kWidthTitle);
        make.height.mas_equalTo(kHeightCell);
    }];
    
    self.passWordTF2 = [[UITextField alloc] init];
    self.passWordTF2.textColor = [UIColor colorWithHexString:kRegionHexColor];;
    self.passWordTF2.secureTextEntry = YES;
//    self.passWordTF2.clearButtonMode = UITextFieldViewModeAlways;
    self.passWordTF2.font = [UIFont wcPfRegularFontOfSize:14];
    NSAttributedString *passwordAttStr2 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_confirm_passwd", @"请再次确认您的密码") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:kPhoneEmailHexColor],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
    self.passWordTF2.attributedPlaceholder = passwordAttStr2;
    [self.passWordTF2 addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.passWordTF2];
    [self.passWordTF2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.passWordLabel2.mas_trailing);
        make.centerY.equalTo(self.passWordLabel2);
        make.trailing.equalTo(self.view).offset(-kLeftRightPadding - kPassWordBtnWidth*2);
        make.height.equalTo(self.passWordLabel2);
    }];
    
    UIButton *passwordConfirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [passwordConfirmButton addTarget:self action:@selector(changePasswordConfirmTextShow:) forControlEvents:UIControlEventTouchUpInside];
    [passwordConfirmButton setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    [self.view addSubview:passwordConfirmButton];
    [passwordConfirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kPassWordBtnWidth);
        make.centerY.equalTo(self.passWordTF2);
        make.trailing.equalTo(self.view.mas_trailing).offset(-kLeftRightPadding);
    }];
    
    self.lineView2 = [[UIView alloc] init];
    self.lineView2.backgroundColor = kLineColor;
    [self.view addSubview:self.lineView2];
    [self.lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passWordTF2.mas_bottom).offset(0);
        make.left.equalTo(self.view).offset(kLeftRightPadding);
        make.right.equalTo(self.view).offset(-kLeftRightPadding);
        make.height.mas_equalTo(1);
    }];
    
    [self.view addSubview:self.passConfirmTipLabel];
    [self.passConfirmTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView2.mas_bottom).offset(1);
        make.leading.equalTo(self.passWordTF.mas_leading);
    }];
    
    self.downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downBtn setTitle:NSLocalizedString(@"finish", @"完成") forState:UIControlStateNormal];
    [self.downBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.downBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateDisabled];
    self.downBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.downBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    self.downBtn.backgroundColor = [UIColor colorWithHexString:kNoSelectedHexColor];
    self.downBtn.enabled = NO;
    self.downBtn.layer.cornerRadius = 20;
    [self.view addSubview:self.downBtn];
    [self.downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kLeftRightPadding);
//        make.top.equalTo(self.passConfirmTipLabel.mas_bottom).offset((114+40+18) * kScreenAllHeightScale);
        make.centerY.equalTo(self.view);
        make.right.equalTo(self.view).offset(-kLeftRightPadding);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark eventResponse
-(void)changedTextField:(UITextField *)textField{
    if ((self.passWordTF.text.length >= 8 && self.passWordTF2.text.length >= 8) && ([NSString judgePassWordLegal:self.passWordTF.text]&&[NSString judgePassWordLegal:self.passWordTF2.text]&&[self.passWordTF.text isEqualToString:self.passWordTF2.text])) {
        self.downBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
        self.downBtn.enabled = YES;
    }
    else
    {
        self.downBtn.backgroundColor = [UIColor colorWithHexString:kNoSelectedHexColor];
        self.downBtn.enabled = NO;
    }
    
    CGFloat intervalSpace = 0;
    
    if (textField == self.passWordTF) {
        if ([NSString judgePassWordLegal:self.passWordTF.text]) {
            self.passTipLabel.hidden = YES;
            intervalSpace = 0;
        }else {
            self.passTipLabel.hidden = NO;
            self.passTipLabel.text = NSLocalizedString(@"password_style", @"密码支持8-16位，必须包含字母和数字");
            intervalSpace = 18;
        }
        
        [self.passWordLabel2 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lineView.mas_bottom).offset(intervalSpace);
        }];
    }
    
    if (textField == self.passWordTF2) {
        if ([self.passWordTF.text isEqualToString:self.passWordTF2.text] && [NSString judgePassWordLegal:self.passWordTF2.text]) {
            self.passConfirmTipLabel.hidden = YES;
        }else {
            self.passConfirmTipLabel.hidden = NO;
            if (![self.passWordTF.text isEqualToString:self.passWordTF2.text]) {
                self.passConfirmTipLabel.text = NSLocalizedString(@"two_password_not_same", @"两次输入的密码不一致");
            }else if (![NSString judgePassWordLegal:self.passWordTF2.text]) {
                self.passConfirmTipLabel.text = NSLocalizedString(@"password_irregularity", @"密码不合规");
            }
        }
    }
    
}


- (void)sureClick:(id)sender{
    
    if (![self.passWordTF.text isEqualToString:self.passWordTF2.text]) {
//        [MBProgressHUD showMessage:NSLocalizedString(@"two_password_not_same", @"两次输入的密码不一致") icon:@"" toView:self.view];
        return;
    }
    
    BOOL isPass = [NSString judgePassWordLegal:self.passWordTF.text];
    if (!isPass) {
//        [MBProgressHUD showMessage:NSLocalizedString(@"password_irregularity", @"密码不合规") icon:@"" toView:self.view];
        return;
    }
    
    if (self.registerType == PhoneRegister) {
        NSDictionary *tmpDic = @{@"CountryCode":self.sendDataDic[@"CountryCode"],@"PhoneNumber":self.sendDataDic[@"PhoneNumber"],@"VerificationCode":self.sendDataDic[@"VerificationCode"],@"Password":self.passWordTF.text};
        [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppCreateCellphoneUser Param:tmpDic success:^(id responseObject) {
            [[TIoTCoreUserManage shared] signInClear];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
        
    }
    else if (self.registerType == PhoneResetPwd){
        NSDictionary *tmpDic = @{@"CountryCode":self.sendDataDic[@"CountryCode"],@"PhoneNumber":self.sendDataDic[@"PhoneNumber"],@"VerificationCode":self.sendDataDic[@"VerificationCode"],@"Password":self.passWordTF.text};
        [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppResetPasswordByCellphone Param:tmpDic success:^(id responseObject) {
            [MBProgressHUD dismissInView:self.view];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
        
    }
    else if (self.registerType == EmailRegister){
        NSDictionary *tmpDic = @{@"Email":self.sendDataDic[@"Email"],@"VerificationCode":self.sendDataDic[@"VerificationCode"],@"Password":self.passWordTF.text};
        [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppCreateEmailUser Param:tmpDic success:^(id responseObject) {
            [[TIoTCoreUserManage shared] signInClear];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }
    else if (self.registerType == EmailResetPwd){
        NSDictionary *tmpDic = @{@"Email":self.sendDataDic[@"Email"],@"VerificationCode":self.sendDataDic[@"VerificationCode"],@"Password":self.passWordTF.text};
        [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppResetPasswordByEmail Param:tmpDic success:^(id responseObject) {
            [MBProgressHUD dismissInView:self.view];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
        
    }
}

- (void)changePasswordTextShow:(UIButton *)button {
    
    if (button.selected) {
        self.passWordTF.secureTextEntry = YES;
        [button setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    }else {
        self.passWordTF.secureTextEntry = NO;
        [button setImage:[UIImage imageNamed:@"password_show"] forState:UIControlStateNormal];
    }
    
    button.selected = !button.selected;
    
}

- (void)changePasswordConfirmTextShow:(UIButton *)button {
    
    if (button.selected) {
        self.passWordTF2.secureTextEntry = YES;
        [button setImage:[UIImage imageNamed:@"password_hide"] forState:UIControlStateNormal];
    }else {
        self.passWordTF2.secureTextEntry = NO;
        [button setImage:[UIImage imageNamed:@"password_show"] forState:UIControlStateNormal];
    }
    
    button.selected = !button.selected;
    
}

#pragma mark - lazy laoding
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

@end
