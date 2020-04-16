//
//  WCPhoneResetPwdViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/8.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCPhoneResetPwdViewController.h"
#import "XWCountryCodeController.h"
#import "WCSendPhoneCodeViewController.h"
#import "WCWebVC.h"

@interface WCPhoneResetPwdViewController ()<UITextViewDelegate>
{
    BOOL _emailStyle;//false:手机，true:邮箱
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *areaCodeBtn;
@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UIButton *procolBtn;
@property (nonatomic, strong) UIButton *sendCodeBtn;

@property (nonatomic, strong) UIView *contentView2;//邮箱登录的
@property (nonatomic, strong) UITextField *emailTF;

@property (nonatomic, copy) NSString *conturyCode;

@end

@implementation WCPhoneResetPwdViewController

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
    self.title = @"找回密码";
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.mas_equalTo(64);
        }
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
    [emailRegisterBtn setTitle:@"使用邮箱账号" forState:UIControlStateNormal];
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
    [self.sendCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
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
}

- (NSMutableAttributedString *)protolStr {
    NSString *str1 = @"同意遵守腾讯云";
    NSString *str2 = @"用户协议";
    NSString *str3 = @"及";
    NSString *str4= @"隐私政策";
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

#pragma mark eventResponse
-(void)changedTextField:(UITextField *)textField{
    [self checkSendCode];
}

- (void)choseAreaCode:(id)sender{
    XWCountryCodeController *countryCodeVC = [[XWCountryCodeController alloc] init];
    countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
        
        self.conturyCode = code;
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",countryName] forState:UIControlStateNormal];
    };
    
    [self.navigationController pushViewController:countryCodeVC animated:YES];
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
        [sender setTitle:@"使用邮箱账号" forState:UIControlStateNormal];
    }
    else
    {
        _emailStyle = YES;
        self.phoneTF.text = @"";
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
        [sender setTitle:@"使用手机账号" forState:UIControlStateNormal];
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
        
        [[WCRequestObject shared] postWithoutToken:AppSendEmailVerificationCode Param:tmpDic success:^(id responseObject) {
            WCSendPhoneCodeViewController *vc = [[WCSendPhoneCodeViewController alloc] init];
            vc.registerType = EmailResetPwd;
            vc.sendCodeDic = tmpDic;
            [self.navigationController pushViewController:vc animated:YES];
        } failure:^(NSString *reason, NSError *error) {
            
        }];
        
    }
    else
    {
        NSDictionary *tmpDic = @{@"Type":@"resetpass",@"CountryCode":self.conturyCode,@"PhoneNumber":self.phoneTF.text};
        [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
        
        [[WCRequestObject shared] postWithoutToken:AppSendVerificationCode Param:tmpDic success:^(id responseObject) {
            [MBProgressHUD dismissInView:self.view];
            WCSendPhoneCodeViewController *vc = [[WCSendPhoneCodeViewController alloc] init];
            vc.registerType = PhoneResetPwd;
            vc.sendCodeDic = tmpDic;
            [self.navigationController pushViewController:vc animated:YES];
        } failure:^(NSString *reason, NSError *error) {
            [MBProgressHUD dismissInView:self.view];
        }];
    }
}


#pragma mark uitextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    if ([[URL scheme] isEqualToString:@"Terms1"]) {
       
        WCLog(@"用户协议");
        NSString *path = [[NSBundle mainBundle] pathForResource:@"腾讯连连用户服务协议V1.0(1)" ofType:@"docx"];
        WCWebVC *vc = [WCWebVC new];
        vc.title = @"用户协议";
        vc.filePath = path;
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
        
    }
    else if ([[URL scheme] isEqualToString:@"Privacy1"]) {
        
        WCLog(@"隐私");
        WCWebVC *vc = [WCWebVC new];
        vc.title = @"隐私政策";
        vc.urlPath = @"https://privacy.qq.com";
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
        
        self.areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"中国大陆"] forState:UIControlStateNormal];
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
        self.phoneTF.textColor = kFontColor;
        self.phoneTF.font = [UIFont wcPfSemiboldFontOfSize:18];
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:@"手机号码" attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224),NSFontAttributeName:[UIFont systemFontOfSize:18]}];
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
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:@"邮箱账号" attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224),NSFontAttributeName:[UIFont systemFontOfSize:18]}];
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

@end
