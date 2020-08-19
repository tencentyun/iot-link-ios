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

@interface TIoTInvitationVC ()
{
    BOOL _emailStyle;//false:手机，true:邮箱
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *areaCodeBtn;
@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UIButton *sendCodeBtn;

@property (nonatomic, strong) UIView *contentView2;//邮箱登录的
@property (nonatomic, strong) UITextField *emailTF;

@property (nonatomic, copy) NSString *conturyCode;

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
    
    
    self.sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendCodeBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.sendCodeBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    self.sendCodeBtn.backgroundColor = kMainColorDisable;
    self.sendCodeBtn.enabled = NO;
    self.sendCodeBtn.layer.cornerRadius = 3;
    [self.view addSubview:self.sendCodeBtn];
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(24);
        make.top.equalTo(emailRegisterBtn.mas_bottom).offset(40 * kScreenAllHeightScale);
        make.right.equalTo(self.view).offset(-24);
        make.height.mas_equalTo(48);
    }];
}


//是否可发送验证码
- (void)checkSendCode{
    
    if (_emailStyle) {
        if ([NSString judgeEmailLegal:self.emailTF.text]) {
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
        if ([NSString judgePhoneNumberLegal:self.phoneTF.text]) {
            self.sendCodeBtn.backgroundColor = kMainColor;
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
        [sender setTitle:@"使用邮箱账号" forState:UIControlStateNormal];
    }
    else
    {
        _emailStyle = YES;
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth, 0) animated:YES];
        self.phoneTF.text = @"";
        [sender setTitle:@"使用手机账号" forState:UIControlStateNormal];
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

- (void)selectAreaCode:(id)sender
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
    regionVC.returnRegionBlock = ^(NSString * _Nonnull Title, NSString * _Nonnull region, NSString * _Nonnull RegionID) {
        [[TIoTCoreUserManage shared] saveUserInfo:@{@"RegionID":RegionID,@"Region":region}];
        if ([region isEqualToString:@"ap-guangzhou"]) {
            self.conturyCode = @"86";
        }else if ([region isEqualToString:@"na-ashburn"]) {
            self.conturyCode = @"1";
        }
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:regionVC animated:YES];
}

-(void)changedTextField:(UITextField *)textField{
    [self checkSendCode];
}

#pragma mark - other

- (void)sendMessageToUser:(NSString *)userId
{
    if ([self.title isEqualToString:@"分享用户"]) {
        NSDictionary *param = @{@"FamilyId":self.familyId,@"ProductId":self.productId,@"DeviceName":self.deviceName,@"ToUserID":userId};
        [[TIoTRequestObject shared] post:AppSendShareDeviceInvite Param:param success:^(id responseObject) {
            [MBProgressHUD showSuccess:@"发送邀请成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [MBProgressHUD showError:reason];
        }];
    }
    else if ([self.title isEqualToString:@"邀请成员"])
    {
        NSDictionary *param = @{@"FamilyId":self.familyId,@"ToUserID":userId};
        [[TIoTRequestObject shared] post:AppSendShareFamilyInvite Param:param success:^(id responseObject) {
            [MBProgressHUD showSuccess:@"发送邀请成功"];
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
        
        self.areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"中国大陆"] forState:UIControlStateNormal];
        [self.areaCodeBtn setTitleColor:kFontColor forState:UIControlStateNormal];
        self.areaCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.areaCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:18];
        //    self.areaCodeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 13);
        [self.areaCodeBtn addTarget:self action:@selector(selectAreaCode:) forControlEvents:UIControlEventTouchUpInside];
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
