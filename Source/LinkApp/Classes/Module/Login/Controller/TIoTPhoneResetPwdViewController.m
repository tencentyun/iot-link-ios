//
//  WCPhoneResetPwdViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/8.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTPhoneResetPwdViewController.h"
#import "XWCountryCodeController.h"
#import "TIoTSendPhoneCodeViewController.h"
#import "TIoTWebVC.h"
#import "TIoTChooseRegionVC.h"
#import "UILabel+TIoTExtension.h"

static CGFloat const kLeftRightPadding = 20; //左右边距
static CGFloat const kHeightCell = 48; //每一项高度
static CGFloat const kWidthTitle = 90; //左侧title 提示宽度

@interface TIoTPhoneResetPwdViewController ()<UITextViewDelegate>
{
    BOOL _emailStyle;//false:手机，true:邮箱
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *areaCodeBtn;
@property (nonatomic, strong) UILabel *phoneAreaLabel;
@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UIButton *procolBtn;
@property (nonatomic, strong) UIButton *sendCodeBtn;

@property (nonatomic, strong) UIView *contentView2;//邮箱登录的
@property (nonatomic, strong) UITextField *emailTF;

@property (nonatomic, copy) NSString *conturyCode;

@end

@implementation TIoTPhoneResetPwdViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}


#pragma mark privateMethods
- (void)setupUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.conturyCode = @"86";
    self.title = NSLocalizedString(@"find_bank_the_password", @"找回密码");
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.mas_equalTo(64);
        }
        make.height.mas_equalTo(kHeightCell*2 + 30); //30 距离顶部高度
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
    
    
    UIButton *emailRegisterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [emailRegisterBtn setTitle:NSLocalizedString(@"email_forgot", @"使用邮箱账号") forState:UIControlStateNormal];
    [emailRegisterBtn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    [emailRegisterBtn addTarget:self action:@selector(registStyleChange:) forControlEvents:UIControlEventTouchUpInside];
    emailRegisterBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
    [self.view addSubview:emailRegisterBtn];
    [emailRegisterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.equalTo(self.scrollView.mas_bottom).offset(20);
    }];
    
    UITextView *procolTV = [[UITextView alloc] init];
    procolTV.attributedText = [self protolStr];;
    procolTV.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:kIntelligentMainHexColor]}; //
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
    [self.procolBtn setImage:[UIImage imageNamed:@"agree_selected"] forState:UIControlStateSelected];
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
    self.sendCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
    [self.sendCodeBtn addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    self.sendCodeBtn.backgroundColor = kMainColorDisable;
    self.sendCodeBtn.enabled = NO;
    self.sendCodeBtn.layer.cornerRadius = 20;
    [self.view addSubview:self.sendCodeBtn];
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kLeftRightPadding);
        make.top.equalTo(procolTV.mas_bottom).offset(40 * kScreenAllHeightScale);
        make.right.equalTo(self.view).offset(-kLeftRightPadding);
        make.height.mas_equalTo(40);
    }];
}

- (NSMutableAttributedString *)protolStr {
    NSString *str1 = NSLocalizedString(@"register_agree_1", @"同意并遵守腾讯云");
    NSString *str2 = NSLocalizedString(@"register_agree_2", @"用户协议");
    NSString *str3 = NSLocalizedString(@"register_agree_3", @"及");
    NSString *str4=  NSLocalizedString(@"register_agree_4", @"隐私政策");
    NSString *showStr = [NSString stringWithFormat:@"%@%@%@%@",str1,str2,str3,str4];
    
    NSRange range1 = [showStr rangeOfString:str2];
    NSRange range2 = [showStr rangeOfString:str4];
    NSMutableParagraphStyle *pstype = [[NSMutableParagraphStyle alloc] init];
    [pstype setAlignment:NSTextAlignmentCenter];
    NSMutableAttributedString *mastring = [[NSMutableAttributedString alloc] initWithString:showStr attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:pstype}];
    
    NSString *valueString1 = [[NSString stringWithFormat:@"Terms1://%@",str2] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *valueString2 = [[NSString stringWithFormat:@"Privacy1://%@",str4] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    [mastring addAttributes:@{NSLinkAttributeName:valueString1,/*NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],*/NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],} range:range1];
    [mastring addAttributes:@{NSLinkAttributeName:valueString2,/*NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],*/NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],} range:range2];
    return mastring;
}

//是否可发送验证码
- (void)checkSendCode{
    if (_emailStyle) {
        if ([NSString judgeEmailLegal:self.emailTF.text] && self.procolBtn.selected) {
            self.sendCodeBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
            self.sendCodeBtn.enabled = YES;
        }
        else{
            self.sendCodeBtn.backgroundColor = kMainColorDisable;
            self.sendCodeBtn.enabled = NO;
        }
    }
    else
    {
        if ([NSString judgePhoneNumberLegal:self.phoneTF.text withRegionID:[TIoTCoreUserManage shared].userRegionId] && self.procolBtn.selected) {
            self.sendCodeBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
            self.sendCodeBtn.enabled = YES;
        }
        else{
            self.sendCodeBtn.backgroundColor = kMainColorDisable;
            self.sendCodeBtn.enabled = NO;
        }
    }
}

#pragma mark eventResponse
-(void)changedTextField:(UITextField *)textField{
    [self checkSendCode];
}

- (void)choseAreaCode{
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
        self.conturyCode = CountryCode;
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
        self.phoneAreaLabel.text = [NSString stringWithFormat:@"(+%@)",CountryCode];
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
        self.emailTF.text = @"";
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [sender setTitle:NSLocalizedString(@"email_forgot", @"使用邮箱账号") forState:UIControlStateNormal];
    }
    else
    {
        _emailStyle = YES;
        self.phoneTF.text = @"";
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
        [sender setTitle:NSLocalizedString(@"phone_forgot", @"使用手机账号") forState:UIControlStateNormal];
    }
}

- (void)procolClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    [self checkSendCode];
}

- (void)sendCode:(id)sender{
    
    if (_emailStyle) {
        NSDictionary *tmpDic = @{@"Type":@"resetpass",@"Email":self.emailTF.text};
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppSendEmailVerificationCode Param:tmpDic success:^(id responseObject) {
            TIoTSendPhoneCodeViewController *vc = [[TIoTSendPhoneCodeViewController alloc] init];
            vc.registerType = EmailResetPwd;
            vc.sendCodeDic = tmpDic;
            [self.navigationController pushViewController:vc animated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
        
    }
    else
    {
        NSDictionary *tmpDic = @{@"Type":@"resetpass",@"CountryCode":self.conturyCode,@"PhoneNumber":self.phoneTF.text};
        [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppSendVerificationCode Param:tmpDic success:^(id responseObject) {
            [MBProgressHUD dismissInView:self.view];
            TIoTSendPhoneCodeViewController *vc = [[TIoTSendPhoneCodeViewController alloc] init];
            vc.registerType = PhoneResetPwd;
            vc.sendCodeDic = tmpDic;
            [self.navigationController pushViewController:vc animated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [MBProgressHUD dismissInView:self.view];
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
    }
    return _scrollView;
}

- (UIView *)contentView{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        
        UILabel *contryLabel = [[UILabel alloc]init];
        [contryLabel setLabelFormateTitle:NSLocalizedString(@"contry_region", @"国家/地区") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
        [_contentView addSubview:contryLabel];
        [contryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kLeftRightPadding);
            make.top.mas_equalTo(30*kScreenAllHeightScale);
            make.height.mas_equalTo(kHeightCell);
            make.width.mas_equalTo(kWidthTitle);
        }];
        
        self.areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
        [self.areaCodeBtn setTitleColor:[UIColor colorWithHexString:kRegionHexColor] forState:UIControlStateNormal];
        self.areaCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.areaCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        //    self.areaCodeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 13);
        [self.areaCodeBtn addTarget:self action:@selector(choseAreaCode) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:self.areaCodeBtn];
        [self.areaCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(contryLabel);
            make.left.equalTo(contryLabel.mas_right);
            make.height.mas_equalTo(kHeightCell);
        }];
        
        self.phoneAreaLabel = [[UILabel alloc]init];
        [self.phoneAreaLabel setLabelFormateTitle:@"(+86)" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kRegionHexColor textAlignment:NSTextAlignmentLeft];
        [_contentView addSubview:self.phoneAreaLabel];
        [self.phoneAreaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.areaCodeBtn.mas_right).offset(5);
            make.centerY.equalTo(contryLabel);
            make.height.mas_equalTo(kHeightCell);
        }];
        
        UIImageView *imgV = [UIImageView new];
        imgV.image = [UIImage imageNamed:@"mineArrow"];
        [_contentView addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-kLeftRightPadding);
            make.centerY.equalTo(contryLabel);
            make.width.height.mas_equalTo(18);
        }];
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = kLineColor;
        [_contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.bottom.equalTo(contryLabel.mas_bottom).offset(-1);
            make.leading.mas_equalTo(kLeftRightPadding);
            make.trailing.mas_equalTo(0);
        }];
        
        UIButton *chooseContryAreaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [chooseContryAreaBtn addTarget:self action:@selector(choseAreaCode) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:chooseContryAreaBtn];
        [chooseContryAreaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.mas_equalTo(0);
            make.top.equalTo(contryLabel.mas_top);
            make.bottom.equalTo(contryLabel.mas_bottom);
        }];
        
        UILabel *phoneLabel = [[UILabel alloc]init];
        [phoneLabel setLabelFormateTitle:NSLocalizedString(@"phone_number", @"手机号码") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
        [_contentView addSubview:phoneLabel];
        [phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kLeftRightPadding);
            make.top.equalTo(lineView.mas_bottom);
            make.height.mas_equalTo(kHeightCell);
            make.width.mas_equalTo(kWidthTitle);
        }];
        
        self.phoneTF = [[UITextField alloc] init];
        self.phoneTF.keyboardType = UIKeyboardTypePhonePad;
        self.phoneTF.textColor = [UIColor colorWithHexString:kTemperatureHexColor];;
        self.phoneTF.font = [UIFont wcPfSemiboldFontOfSize:14];
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_input_phonenumber", @"请输入手机号") attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224),NSFontAttributeName:[UIFont wcPfSemiboldFontOfSize:14]}];
        self.phoneTF.attributedPlaceholder = ap;
        self.phoneTF.clearButtonMode = UITextFieldViewModeAlways;
        [self.phoneTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
        [_contentView addSubview:self.phoneTF];
        [self.phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(phoneLabel.mas_trailing);
            make.trailing.mas_equalTo(-kLeftRightPadding);
            make.top.equalTo(phoneLabel);
            make.height.mas_equalTo(kHeightCell);
        }];
        
        UIView *lineView2 = [[UIView alloc] init];
        lineView2.backgroundColor = kLineColor;
        [_contentView addSubview:lineView2];
        [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneTF.mas_bottom);
            make.height.mas_equalTo(1);
            make.leading.mas_equalTo(kLeftRightPadding);
            make.trailing.mas_equalTo(0);
        }];
    }
    return _contentView;
}

- (UIView *)contentView2
{
    if (!_contentView2) {
        _contentView2 = [[UIView alloc] init];
        _contentView2.backgroundColor = [UIColor whiteColor];
        
        UILabel *emailLaebl = [[UILabel alloc]init];
        [emailLaebl setLabelFormateTitle:NSLocalizedString(@"email_account", @"邮箱账号") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
        [_contentView2 addSubview:emailLaebl];
        [emailLaebl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(kLeftRightPadding);
            make.width.mas_equalTo(kWidthTitle);
            make.top.mas_equalTo(70*kScreenAllHeightScale);
            make.height.mas_equalTo(kHeightCell);
            
        }];
        
        self.emailTF = [[UITextField alloc] init];
        
        self.emailTF.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTF.textColor = [UIColor colorWithHexString:kTemperatureHexColor];
        self.emailTF.font = [UIFont wcPfRegularFontOfSize:14];
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"email_null", @"请输入邮箱地址") attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224),NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        self.emailTF.attributedPlaceholder = as;
        self.emailTF.clearButtonMode = UITextFieldViewModeAlways;
        [self.emailTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
        [_contentView2 addSubview:self.emailTF];
        [self.emailTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(emailLaebl.mas_trailing);
            make.trailing.mas_equalTo(-kLeftRightPadding);
            make.top.equalTo(emailLaebl);
            make.height.mas_equalTo(kHeightCell);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = kLineColor;
        [_contentView2 addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.emailTF.mas_bottom);
            make.height.mas_equalTo(1);
            make.leading.mas_equalTo(kLeftRightPadding);
            make.trailing.mas_equalTo(0);
        }];
    }
    return _contentView2;
}

@end
