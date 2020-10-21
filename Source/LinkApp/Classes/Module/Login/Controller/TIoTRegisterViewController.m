//
//  WCRegisterViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTRegisterViewController.h"
#import "TIoTSendPhoneCodeViewController.h"
#import "XWCountryCodeController.h"
#import "TIoTWebVC.h"
#import "TIoTChooseRegionVC.h"

@interface TIoTRegisterViewController ()<UITextViewDelegate>
{
    BOOL _emailStyle;//false:手机，true:邮箱
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *areaCodeBtn;
@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UIButton *procolBtn;
@property (nonatomic, strong) UIButton *sendCodeBtn;

@property (nonatomic, strong) UIButton *deletePhoneBtn;
@property (nonatomic, strong) UIButton *deleteEmailBtn;

@property (nonatomic, strong) UIView *contentView2;//邮箱登录的
@property (nonatomic, strong) UIButton *areaCodeBtn2;
@property (nonatomic, strong) UITextField *emailTF;

@property (nonatomic, copy) NSString *conturyCode;
@property (nonatomic, copy) NSString *conturyCode2;


@property (nonatomic, strong) UILabel *phoneTipLabel;
@property (nonatomic, strong) UILabel *emailTipLabel;
@end

@implementation TIoTRegisterViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    //不选地区列表赋默认值
    [TIoTCoreUserManage shared].userRegion = @"ap-guangzhou";
    [TIoTCoreUserManage shared].userRegionId = @"1";
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_emailStyle) {
        if (![NSString isNullOrNilWithObject:self.emailTF.text]) {
            [TIoTCoreUserManage shared].signIn_Email_Address = self.emailTF.text;
        }
    }else {
        if (![NSString isNullOrNilWithObject:self.phoneTF.text]) {
            [TIoTCoreUserManage shared].signIn_Phone_Numner = self.phoneTF.text;
        }
    }
}

#pragma mark privateMethods
- (void)setupUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"mobile_phone_register", @"手机注册");
    self.conturyCode = @"86";
    self.conturyCode2 = @"86";
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64);
        }
    }];
    
    if (self.defaultPhoneOrEmail != nil) {
        
        if ([NSString judgePhoneNumberLegal:self.defaultPhoneOrEmail]) {
            //手机号注册
            [self showPhoneRegisterStyle];
            self.phoneTF.text = self.defaultPhoneOrEmail;
        }else if ([NSString judgeEmailLegal:self.defaultPhoneOrEmail]) {
            //邮箱注册
            [self showEmailRegisterStyle];
            self.emailTF.text = self.defaultPhoneOrEmail;
        }
        
    }else {
        [self showPhoneRegisterStyle];
    }

    UIButton *emailRegisterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [emailRegisterBtn setTitle:NSLocalizedString(@"email_to_register", @"使用邮箱注册") forState:UIControlStateNormal];
    [emailRegisterBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    [emailRegisterBtn addTarget:self action:@selector(registStyleChange:) forControlEvents:UIControlEventTouchUpInside];
    emailRegisterBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.view addSubview:emailRegisterBtn];
    [emailRegisterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24);
        make.top.equalTo(self.scrollView.mas_bottom).offset(20);
    }];
    
    UITextView *procolTV = [[UITextView alloc] init];
    procolTV.attributedText = [self protolStr];;
    procolTV.linkTextAttributes = @{NSForegroundColorAttributeName:kMainColor}; //
    procolTV.textColor = kFontColor;
    procolTV.delegate = self;
    procolTV.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
    procolTV.scrollEnabled = NO;
    [self.view addSubview:procolTV];
    [procolTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(emailRegisterBtn.mas_bottom).offset(40 * kScreenAllHeightScale);
        make.centerX.equalTo(self.view).offset(15);
    }];
    
    self.procolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.procolBtn addTarget:self action:@selector(procolClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.procolBtn setImage:[UIImage imageNamed:@"procolDefault"] forState:UIControlStateNormal];
    [self.procolBtn setImage:[UIImage imageNamed:@"procolSelect"] forState:UIControlStateSelected];
    [self.view addSubview:self.procolBtn];
    [self.procolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(procolTV);
        make.width.height.mas_equalTo(30);
        make.right.equalTo(procolTV.mas_left);
    }];
    
    
    self.sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendCodeBtn setTitle:NSLocalizedString(@"register_get_code", @"获取验证码") forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.sendCodeBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateDisabled];
    self.sendCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.sendCodeBtn addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    self.sendCodeBtn.backgroundColor = kMainColorDisable;
    self.sendCodeBtn.enabled = NO;
    self.sendCodeBtn.layer.cornerRadius = 3;
    [self.view addSubview:self.sendCodeBtn];
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(24);
        make.top.equalTo(procolTV.mas_bottom).offset(40 * kScreenAllHeightScale);
        make.right.equalTo(self.view).offset(-24);
        make.height.mas_equalTo(48);
    }];
 
    [self refreshUserActionItems];
}

#pragma mark - 显示用户之前操作项
- (void)refreshUserActionItems {
    
    // 1、对区域和手机号、邮箱内容赋值或填充  2、对手机号、邮箱格式检测
    if (_emailStyle) {
        
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_countryCode]) {
            self.conturyCode2 = [TIoTCoreUserManage shared].signIn_countryCode;
        }
        
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_Title]) {
            [self.areaCodeBtn2 setTitle:[NSString stringWithFormat:@"%@",[TIoTCoreUserManage shared].signIn_Title] forState:UIControlStateNormal];
        }
        
    }else {
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_countryCode]) {
            self.conturyCode = [TIoTCoreUserManage shared].signIn_countryCode;
        }
        
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_Title]) {
            [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",[TIoTCoreUserManage shared].signIn_Title] forState:UIControlStateNormal];
        }
    }
    
    if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_Phone_Numner]) {
        self.phoneTF.text = [TIoTCoreUserManage shared].signIn_Phone_Numner;
        [self judgePhoneNumberQualifiedWithString:self.phoneTF.text];
    }
    
    if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].signIn_Email_Address]) {
        self.emailTF.text = [TIoTCoreUserManage shared].signIn_Email_Address;
    }
}

- (void)showPhoneRegisterStyle {
    //先显示手机注册
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
}

- (void)showEmailRegisterStyle {
    //先显示邮箱注册
    [self.scrollView addSubview:self.contentView2];
    [self.contentView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.equalTo(self.scrollView);
        make.width.height.equalTo(self.scrollView);
    }];
    
    [self.scrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.equalTo(self.scrollView);
        make.width.height.equalTo(self.scrollView);
        make.leading.equalTo(self.contentView2.mas_trailing);
    }];
}

- (NSMutableAttributedString *)protolStr {
    NSString *str1 = NSLocalizedString(@"register_agree_1", @"同意并遵守腾讯云");
    NSString *str2 = NSLocalizedString(@"register_agree_2", @"用户协议");
    NSString *str3 = NSLocalizedString(@"register_agree_3", @"及");
    NSString *str4= NSLocalizedString(@"register_agree_4", @"隐私政策");
    NSString *showStr = [NSString stringWithFormat:@"%@%@%@%@",str1,str2,str3,str4];
    
    NSRange range1 = [showStr rangeOfString:str2];
    NSRange range2 = [showStr rangeOfString:str4];
    NSMutableParagraphStyle *pstype = [[NSMutableParagraphStyle alloc] init];
    [pstype setAlignment:NSTextAlignmentCenter];
    NSMutableAttributedString *mastring = [[NSMutableAttributedString alloc] initWithString:showStr attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:12],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:pstype}];
    
    NSString *valueString1 = [[NSString stringWithFormat:@"Terms1://%@",str2] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *valueString2 = [[NSString stringWithFormat:@"Privacy1://%@",str4] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    [mastring addAttributes:@{NSLinkAttributeName:valueString1,/*NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],*/NSFontAttributeName:[UIFont wcPfRegularFontOfSize:12],} range:range1];
    [mastring addAttributes:@{NSLinkAttributeName:valueString2,/*NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],*/NSFontAttributeName:[UIFont wcPfRegularFontOfSize:12],} range:range2];
    return mastring;
}

//是否可发送验证码
- (void)checkSendCode{
    
    if (_emailStyle) {
        if ([NSString judgeEmailLegal:self.emailTF.text] && self.procolBtn.selected) {
            self.sendCodeBtn.backgroundColor = kMainColor;
            self.sendCodeBtn.enabled = YES;
        }
        else{
            self.sendCodeBtn.backgroundColor = kMainColorDisable;
            self.sendCodeBtn.enabled = NO;
        }
    }
    else
    {
        if ([NSString judgePhoneNumberLegal:self.phoneTF.text] && self.procolBtn.selected) {
            self.sendCodeBtn.backgroundColor = kMainColor;
            self.sendCodeBtn.enabled = YES;
        }
        else{
            self.sendCodeBtn.backgroundColor = kMainColorDisable;
            self.sendCodeBtn.enabled = NO;
        }
    }
}

#pragma mark - eventResponse

-(void)changedTextField:(UITextField *)textField{
    [self checkSendCode];
    
    //优化提示文案
    if (textField == self.phoneTF) {//手机号改密码
        
        [self judgePhoneNumberQualifiedWithString:textField.text];
        
    }else { //邮箱改密码
        
        [self judgeEmailAddressQualifiedWithString:textField.text];
    }
}


- (void)judgePhoneNumberQualifiedWithString:(NSString *)textFieldText {
    if ([NSString judgePhoneNumberLegal:textFieldText]) { //手机号合格
        self.phoneTipLabel.hidden = YES;
    }else{ //手机号不合格
        self.phoneTipLabel.hidden = NO;
        self.phoneTipLabel.text = NSLocalizedString(@"phoneNumber_error", "号码错误");
    }
}

- (void)judgeEmailAddressQualifiedWithString:(NSString *)textFieldText {
    if ([NSString judgeEmailLegal:textFieldText]) { //邮箱合格
        self.emailTipLabel.hidden = YES;
    }else{ //邮箱合格不合格
        self.emailTipLabel.hidden = NO;
        self.emailTipLabel.text = NSLocalizedString(@"email_invalid", @"邮箱地址格式不正确");
    }
}

- (void)choseAreaCode:(id)sender{
//    XWCountryCodeController *countryCodeVC = [[XWCountryCodeController alloc] init];
//    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
//
//        self.conturyCode = code;
//        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",countryName] forState:UIControlStateNormal];
//    };
//
//    [self.navigationController pushViewController:countryCodeVC animated:YES];
    
    TIoTChooseRegionVC *regionVC = [[TIoTChooseRegionVC alloc]init];
    
    regionVC.returnRegionBlock = ^(NSString * _Nonnull Title,NSString * _Nonnull region,NSString * _Nonnull RegionID,NSString *_Nullable CountryCode) {
    
        if (self->_emailStyle == NO) {
            self.conturyCode = CountryCode;
            [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
            [TIoTCoreUserManage shared].signIn_countryCode = CountryCode;
            [TIoTCoreUserManage shared].signIn_Title = Title;
        }else {
             self.conturyCode2 = CountryCode;
            [self.areaCodeBtn2 setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
            [TIoTCoreUserManage shared].signIn_countryCode = CountryCode;
            [TIoTCoreUserManage shared].signIn_Title = Title;
        }
        
    };
    [self.navigationController pushViewController:regionVC animated:YES];
}

- (void)registStyleChange:(UIButton *)sender
{
    [self.view endEditing:YES];
    self.sendCodeBtn.backgroundColor = kMainColorDisable;
    self.sendCodeBtn.enabled = NO;
    if ([sender.titleLabel.text containsString:@"手机"]) {
        _emailStyle = NO;
        self.title = NSLocalizedString(@"mobile_phone_register", @"手机注册");
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//        self.emailTF.text = @"";
        [sender setTitle:NSLocalizedString(@"email_to_register", @"使用邮箱注册") forState:UIControlStateNormal];
        [TIoTCoreUserManage shared].signIn_Email_Address = self.emailTF.text;
    }
    else
    {
        _emailStyle = YES;
        self.title = NSLocalizedString(@"email_register", @"邮箱注册");
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
//        self.phoneTF.text = @"";
        [sender setTitle:NSLocalizedString(@"mobile_phone_number_to_register", @"使用手机注册") forState:UIControlStateNormal];
        [TIoTCoreUserManage shared].signIn_Phone_Numner = self.phoneTF.text;
        if (![NSString isNullOrNilWithObject:self.emailTF.text]) {
            [self judgeEmailAddressQualifiedWithString:self.emailTF.text];
        }
        
        [self refreshUserActionItems];
        
    }
}

//- (void)deleteContent:(UIButton *)btn
//{
//    if ([btn isEqual:self.deletePhoneBtn])
//    {
//        self.phoneTF.text = @"";
//    }
//    else if ([btn isEqual:self.deleteEmailBtn])
//    {
//        self.emailTF.text = @"";
//    }
//}

- (void)procolClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    [self checkSendCode];
}

- (void)sendCode:(id)sender{
    
    if (_emailStyle) {
        
        [TIoTCoreUserManage shared].signIn_Email_Address = self.emailTF.text;
        
        NSDictionary *tmpDic = @{@"Type":@"register",@"Email":self.emailTF.text};
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppSendEmailVerificationCode Param:tmpDic success:^(id responseObject) {
            TIoTSendPhoneCodeViewController *vc = [[TIoTSendPhoneCodeViewController alloc] init];
            vc.registerType = EmailRegister;
            vc.sendCodeDic = tmpDic;
            [self.navigationController pushViewController:vc animated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
        
    }
    else
    {
        [TIoTCoreUserManage shared].signIn_Phone_Numner = self.phoneTF.text;
        
        NSDictionary *tmpDic = @{@"Type":@"register",@"CountryCode":self.conturyCode,@"PhoneNumber":self.phoneTF.text};
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppSendVerificationCode Param:tmpDic success:^(id responseObject) {
            TIoTSendPhoneCodeViewController *vc = [[TIoTSendPhoneCodeViewController alloc] init];
            vc.registerType = PhoneRegister;
            vc.sendCodeDic = tmpDic;
            [self.navigationController pushViewController:vc animated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }
    
}


#pragma mark uitextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    if ([[URL scheme] isEqualToString:@"Terms1"]) {
       
        WCLog(@"用户协议");
        TIoTWebVC *vc = [TIoTWebVC new];
        vc.title = NSLocalizedString(@"register_agree_2", @"用户协议");
        vc.urlPath = ServiceProtocolURl;
        [self.navigationController pushViewController:vc animated:YES];
        
        return NO;
        
    }
    else if ([[URL scheme] isEqualToString:@"Privacy1"]) {
        
        WCLog(@"隐私");
        TIoTWebVC *vc = [TIoTWebVC new];
        vc.title = NSLocalizedString(@"register_agree_4", @"隐私政策");
        vc.urlPath = PrivacyProtocolURL;
        [self.navigationController pushViewController:vc animated:YES];
        
        return NO;
    }
    return YES;
}

#pragma mark setter or getter
- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.clipsToBounds = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = NO;
    }
    return _scrollView;
}

- (UIView *)contentView{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        
        self.areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
        [self.areaCodeBtn setTitleColor:kFontColor forState:UIControlStateNormal];
        self.areaCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.areaCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:18];
        //    self.areaCodeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 13);
        [self.areaCodeBtn addTarget:self action:@selector(choseAreaCode:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:self.areaCodeBtn];
        [self.areaCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(20);
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
        
        self.phoneTF = [[UITextField alloc] init];
        self.phoneTF.keyboardType = UIKeyboardTypePhonePad;
        self.phoneTF.textColor = [UIColor blackColor];
        self.phoneTF.font = [UIFont wcPfSemiboldFontOfSize:18];
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"phone_number", @"手机号码") attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224),NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        self.phoneTF.attributedPlaceholder = ap;
        self.phoneTF.clearButtonMode = UITextFieldViewModeAlways;
        [self.phoneTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
        [_contentView addSubview:self.phoneTF];
        [self.phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(24);
            make.trailing.mas_equalTo(-24);
            make.top.equalTo(self.areaCodeBtn.mas_bottom).offset(20);
            make.height.mas_equalTo(48);
        }];
        
        self.phoneTipLabel = [[UILabel alloc] init];
        self.phoneTipLabel.font = [UIFont systemFontOfSize:12];
        self.phoneTipLabel.text = NSLocalizedString(@"phoneNumber_error", "号码错误");
        self.phoneTipLabel.textColor = UIColor.redColor;
        self.phoneTipLabel.hidden = YES;
        [self.contentView addSubview:self.phoneTipLabel];
        [self.phoneTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneTF.mas_bottom).offset(3);
            make.leading.equalTo(self.phoneTF.mas_leading);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = kLineColor;
        [_contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneTF.mas_bottom);
            make.height.mas_equalTo(0.5);
            make.bottom.mas_equalTo(0);
            make.leading.mas_equalTo(24);
            make.trailing.mas_equalTo(-24);
        }];
    }
    return _contentView;
}

- (UIView *)contentView2
{
    if (!_contentView2) {
        _contentView2 = [[UIView alloc] init];
        _contentView2.backgroundColor = [UIColor whiteColor];
        
        self.areaCodeBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.areaCodeBtn2 setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
        [self.areaCodeBtn2 setTitleColor:kFontColor forState:UIControlStateNormal];
        self.areaCodeBtn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.areaCodeBtn2.titleLabel.font = [UIFont wcPfRegularFontOfSize:18];
        //    self.areaCodeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 13);
        [self.areaCodeBtn2 addTarget:self action:@selector(choseAreaCode:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView2 addSubview:self.areaCodeBtn2];
        [self.areaCodeBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(20);
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
        
        UIButton *dodo = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contentView2 addSubview:dodo];
        [dodo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(20);
            make.top.mas_equalTo(40*kScreenAllHeightScale);
            make.height.mas_equalTo(30);
        }];
        
        self.emailTF = [[UITextField alloc] init];
        self.emailTF.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTF.textColor = kFontColor;
        self.emailTF.font = [UIFont wcPfSemiboldFontOfSize:18];
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"email_account", @"邮箱账号") attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224),NSFontAttributeName:[UIFont systemFontOfSize:18]}];
        self.emailTF.attributedPlaceholder = as;
        self.emailTF.clearButtonMode = UITextFieldViewModeAlways;
        [self.emailTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
        [_contentView2 addSubview:self.emailTF];
        [self.emailTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(24);
            make.trailing.mas_equalTo(-24);
            make.top.equalTo(dodo.mas_bottom).offset(20);
            make.height.mas_equalTo(48);
        }];
        
        
        self.emailTipLabel = [[UILabel alloc] init];
        self.emailTipLabel.font = [UIFont systemFontOfSize:12];
        self.emailTipLabel.text = NSLocalizedString(@"email_invalid", @"邮箱地址格式不正确");
        self.emailTipLabel.textColor = UIColor.redColor;
        self.emailTipLabel.hidden = YES;
        [self.contentView2 addSubview:self.emailTipLabel];
        [self.emailTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.emailTF.mas_bottom).offset(3);
            make.leading.equalTo(self.emailTF.mas_leading);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = kLineColor;
        [_contentView2 addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.emailTF.mas_bottom);
            make.height.mas_equalTo(0.5);
            make.bottom.mas_equalTo(0);
            make.leading.mas_equalTo(24);
            make.trailing.mas_equalTo(-24);
        }];
    }
    return _contentView2;
}

//- (UIView *)phoneRightView{
//    UIView *rightView = [[UIView alloc] init];
//    rightView.size = CGSizeMake(20, 20);
//    
//    self.deletePhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.deletePhoneBtn setImage:[UIImage imageNamed:@"tfdelete"] forState:UIControlStateNormal];
//    [self.deletePhoneBtn addTarget:self action:@selector(deleteContent:) forControlEvents:UIControlEventTouchUpInside];
//    self.deletePhoneBtn.frame = CGRectMake(0, 0, 20, 20);
//    [rightView addSubview:self.deletePhoneBtn];
//    
//    return rightView;
//}
//
//- (UIView *)emailRightView{
//    UIView *rightView = [[UIView alloc] init];
//    rightView.size = CGSizeMake(20, 20);
//    
//    self.deleteEmailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.deleteEmailBtn setImage:[UIImage imageNamed:@"tfdelete"] forState:UIControlStateNormal];
//    [self.deleteEmailBtn addTarget:self action:@selector(deleteContent:) forControlEvents:UIControlEventTouchUpInside];
//    self.deleteEmailBtn.frame = CGRectMake(0, 0, 20, 20);
//    [rightView addSubview:self.deleteEmailBtn];
//    
//    return rightView;
//}
@end
