//
//  WCInvitationVC.m
//  TenextCloud
//
//  Created by Wp on 2020/3/13.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTInvitationVC.h"
#import "XWCountryCodeController.h"
#import "TIoTChooseRegionVC.h"
#import "UILabel+TIoTExtension.h"

static CGFloat const kLeftRightPadding = 20; //左右边距
static CGFloat const kHeightCell = 48; //每一项高度
static CGFloat const kWidthTitle = 90; //左侧title 提示宽度

@interface TIoTInvitationVC ()
{
    BOOL _emailStyle;//false:手机，true:邮箱
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *areaCodeBtn;
@property (nonatomic, strong) UILabel *phoneAreaLabel;
@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UIButton *sendCodeBtn;
@property (nonatomic, copy) NSString *conturyCode;

@property (nonatomic, strong) UIView *contentView2;//邮箱登录的
@property (nonatomic, strong) UITextField *emailTF;
@property (nonatomic, strong) UIButton *areaCodeBtn2;
@property (nonatomic, strong) UILabel *phoneAreaLabel2;
@property (nonatomic, copy) NSString *conturyCode2;

@end

@implementation TIoTInvitationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.conturyCode = @"86";
    self.conturyCode2 = @"86";
    
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(16);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64 +16);
        }
        make.height.mas_equalTo(kHeightCell*2); //30为顶部空白 2两条分割线
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
    emailRegisterBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.view addSubview:emailRegisterBtn];
    [emailRegisterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24);
        make.top.equalTo(self.scrollView.mas_bottom).offset(10);
    }];
    
    
    self.sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendCodeBtn setTitle:NSLocalizedString(@"confirm", @"确定") forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.sendCodeBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    self.sendCodeBtn.backgroundColor = kMainColorDisable;
    self.sendCodeBtn.enabled = NO;
    self.sendCodeBtn.layer.cornerRadius = 20;
    [self.view addSubview:self.sendCodeBtn];
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kLeftRightPadding);
        make.top.equalTo(emailRegisterBtn.mas_bottom).offset(60 * kScreenAllHeightScale);
        make.right.equalTo(self.view).offset(-kLeftRightPadding);
        make.height.mas_equalTo(40);
    }];
}


//是否可发送验证码
- (void)checkSendCode{
    
    if (_emailStyle) {
        if ([NSString judgeEmailLegal:self.emailTF.text]) {
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
        if ([NSString judgePhoneNumberLegal:self.phoneTF.text withRegionID:[TIoTCoreUserManage shared].userRegionId]) {
            self.sendCodeBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
            self.sendCodeBtn.enabled = YES;
        }
        else{
            self.sendCodeBtn.backgroundColor = kMainColorDisable;
            self.sendCodeBtn.enabled = NO;
        }
    }
}

#pragma mark - action

- (void)registStyleChange:(UIButton *)sender
{
    [self.view endEditing:YES];
    self.sendCodeBtn.backgroundColor = kMainColorDisable;
    self.sendCodeBtn.enabled = NO;
    if ([sender.titleLabel.text containsString:@"手机"]) {
        _emailStyle = NO;
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        self.emailTF.text = @"";
        [sender setTitle:NSLocalizedString(@"email_forgot", @"使用邮箱账号") forState:UIControlStateNormal];
    }
    else
    {
        _emailStyle = YES;
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
        self.phoneTF.text = @"";
        [sender setTitle:NSLocalizedString(@"phone_forgot", @"使用手机账号") forState:UIControlStateNormal];
    }
}

- (void)done:(UIButton *)btn
{
    
    NSDictionary *param;
    if (_emailStyle) param = @{@"Type":@"email",@"Email":self.emailTF.text};
    else param = @{@"Type":@"phone",@"CountryCode":self.conturyCode,@"PhoneNumber":self.phoneTF.text};
    
    [[TIoTRequestObject shared] post:AppFindUser Param:param success:^(id responseObject) {
        NSDictionary *data = responseObject[@"Data"];
        NSString *userId = data[@"UserID"];
        
        [self sendMessageToUser:userId];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
    }];
}

- (void)selectAreaCode
{
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
            
            self.phoneAreaLabel.text = [NSString stringWithFormat:@"(+%@)",CountryCode];
        }else {
            self.conturyCode2 = CountryCode;
            [self.areaCodeBtn2 setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
            
            self.phoneAreaLabel2.text = [NSString stringWithFormat:@"(+%@)",CountryCode];
        }
        
    };
    [self.navigationController pushViewController:regionVC animated:YES];
}

-(void)changedTextField:(UITextField *)textField{
    [self checkSendCode];
}

#pragma mark - other

- (void)sendMessageToUser:(NSString *)userId
{
    if ([self.title isEqualToString:NSLocalizedString(@"device_share_to_user", @"分享用户")]) {
        NSDictionary *param = @{@"FamilyId":self.familyId,@"ProductId":self.productId,@"DeviceName":self.deviceName,@"ToUserID":userId};
        [[TIoTRequestObject shared] post:AppSendShareDeviceInvite Param:param success:^(id responseObject) {
            [MBProgressHUD showSuccess:NSLocalizedString(@"send_invitation_success", @"发送邀请成功")];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [MBProgressHUD showError:reason];
        }];
    }
    else if ([self.title isEqualToString:NSLocalizedString(@"invite_member", @"邀请成员")])
    {
        NSDictionary *param = @{@"FamilyId":self.familyId,@"ToUserID":userId};
        [[TIoTRequestObject shared] post:AppSendShareFamilyInvite Param:param success:^(id responseObject) {
            [MBProgressHUD showSuccess:NSLocalizedString(@"send_invitation_success", @"发送邀请成功")];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [MBProgressHUD showError:reason];
        }];
    }
}


#pragma mark - getter

- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = NO;
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
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(kHeightCell);
            make.width.mas_equalTo(kWidthTitle);
        }];
        
        self.areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
        [self.areaCodeBtn setTitleColor:[UIColor colorWithHexString:kRegionHexColor] forState:UIControlStateNormal];
        self.areaCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.areaCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        //    self.areaCodeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 13);
        [self.areaCodeBtn addTarget:self action:@selector(selectAreaCode) forControlEvents:UIControlEventTouchUpInside];
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
        [chooseContryAreaBtn addTarget:self action:@selector(selectAreaCode) forControlEvents:UIControlEventTouchUpInside];
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
        self.phoneTF.textColor = [UIColor blackColor];
        self.phoneTF.font = [UIFont wcPfSemiboldFontOfSize:14];
        NSAttributedString *ap = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"please_input_phonenumber", @"请输入手机号") attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224),NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
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
        
        UILabel *contryLabel = [[UILabel alloc]init];
        [contryLabel setLabelFormateTitle:NSLocalizedString(@"contry_region", @"国家/地区") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
        [_contentView2 addSubview:contryLabel];
        [contryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kLeftRightPadding);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(kHeightCell);
            make.width.mas_equalTo(kWidthTitle);
        }];
        
        self.areaCodeBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.areaCodeBtn2 setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
        [self.areaCodeBtn2 setTitleColor:[UIColor colorWithHexString:kRegionHexColor] forState:UIControlStateNormal];
        self.areaCodeBtn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.areaCodeBtn2.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        //    self.areaCodeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 13);
        [self.areaCodeBtn2 addTarget:self action:@selector(selectAreaCode) forControlEvents:UIControlEventTouchUpInside];
        [_contentView2 addSubview:self.areaCodeBtn2];
        [self.areaCodeBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(contryLabel);
            make.left.equalTo(contryLabel.mas_right);
            make.height.mas_equalTo(kHeightCell);
        }];
        
        self.phoneAreaLabel2 = [[UILabel alloc]init];
        [self.phoneAreaLabel2 setLabelFormateTitle:@"(+86)" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kRegionHexColor textAlignment:NSTextAlignmentLeft];
        [_contentView2 addSubview:self.phoneAreaLabel2];
        [self.phoneAreaLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.areaCodeBtn2.mas_right).offset(5);
            make.centerY.equalTo(contryLabel);
            make.height.mas_equalTo(kHeightCell);
        }];
        
        UIImageView *imgV = [UIImageView new];
        imgV.image = [UIImage imageNamed:@"mineArrow"];
        [_contentView2 addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-kLeftRightPadding);
            make.centerY.equalTo(contryLabel);
            make.width.height.mas_equalTo(18);
        }];
        
        UIView *lineViewOne = [[UIView alloc]init];
        lineViewOne.backgroundColor = kLineColor;
        [_contentView2 addSubview:lineViewOne];
        [lineViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.bottom.equalTo(contryLabel.mas_bottom).offset(-1);
            make.leading.mas_equalTo(kLeftRightPadding);
            make.trailing.mas_equalTo(0);
        }];
        
        UIButton *chooseContryAreaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [chooseContryAreaBtn addTarget:self action:@selector(selectAreaCode) forControlEvents:UIControlEventTouchUpInside];
        [_contentView2 addSubview:chooseContryAreaBtn];
        [chooseContryAreaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.mas_equalTo(0);
            make.top.equalTo(contryLabel.mas_top);
            make.bottom.equalTo(contryLabel.mas_bottom);
        }];
        
        UILabel *emailLabel = [[UILabel alloc]init];
        [emailLabel setLabelFormateTitle:NSLocalizedString(@"email_account", @"邮箱账号") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
        [_contentView2 addSubview:emailLabel];
        [emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kLeftRightPadding);
            make.top.equalTo(lineViewOne.mas_bottom);
            make.height.mas_equalTo(kHeightCell);
            make.width.mas_equalTo(kWidthTitle);
        }];
        
        self.emailTF = [[UITextField alloc] init];
        self.emailTF.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTF.textColor = kFontColor;
        self.emailTF.font = [UIFont wcPfSemiboldFontOfSize:14];
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"email_null", @"请输入邮箱地址") attributes:@{NSForegroundColorAttributeName:kRGBColor(224, 224, 224),NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14]}];
        self.emailTF.attributedPlaceholder = as;
        self.emailTF.clearButtonMode = UITextFieldViewModeAlways;
        [self.emailTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
        [_contentView2 addSubview:self.emailTF];
        [self.emailTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(emailLabel.mas_trailing);
            make.trailing.mas_equalTo(-kLeftRightPadding);
            make.top.equalTo(emailLabel);
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
