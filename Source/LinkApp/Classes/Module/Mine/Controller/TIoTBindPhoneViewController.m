//
//  WCBindPhoneViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/10.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTBindPhoneViewController.h"
#import "XWCountryCodeController.h"
#import "TIoTSendPhoneCodeViewController.h"
#import "TIoTChooseRegionVC.h"

@interface TIoTBindPhoneViewController ()

@property (nonatomic, strong) UIButton *areaCodeBtn;
@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UILabel *tip;
@property (nonatomic, strong) UIButton *sendCodeBtn;

@property (nonatomic, copy) NSString *conturyCode;

@end

@implementation TIoTBindPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.conturyCode = @"86";
    self.title = NSLocalizedString(@"bind_phone", @"手机绑定");
    
    self.areaCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"china_main_land", @"中国大陆")] forState:UIControlStateNormal];
    [self.areaCodeBtn setTitleColor:kFontColor forState:UIControlStateNormal];
    self.areaCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.areaCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
    [self.areaCodeBtn addTarget:self action:@selector(choseAreaCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.areaCodeBtn];
    [self.areaCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.mas_equalTo(40*kScreenAllHeightScale + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.height.mas_equalTo(30);
    }];
    
    UIImageView *imgV = [UIImageView new];
    imgV.image = [UIImage imageNamed:@"mineArrow"];
    [self.view addSubview:imgV];
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.areaCodeBtn.mas_trailing);
        make.centerY.equalTo(self.areaCodeBtn);
    }];
    
    self.phoneTF = [[UITextField alloc] init];
    self.phoneTF.placeholder = NSLocalizedString(@"phone_number", @"手机号码");
    self.phoneTF.keyboardType = UIKeyboardTypePhonePad;
    self.phoneTF.textColor = kFontColor;
    self.phoneTF.font = [UIFont wcPfSemiboldFontOfSize:14];
//    self.phoneTF.rightViewMode = UITextFieldViewModeAlways;
    self.phoneTF.clearButtonMode = UITextFieldViewModeAlways;
    [self.phoneTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.phoneTF];
    [self.phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.equalTo(self.areaCodeBtn.mas_bottom).offset(20);
        make.height.mas_equalTo(48);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = kLineColor;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneTF.mas_bottom);
        make.height.mas_equalTo(1);
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
    }];
    
    self.tip = [[UILabel alloc] init];
    _tip.textColor =  kRGBColor(229, 69, 69);
    _tip.font = [UIFont wcPfRegularFontOfSize:12];
    [self.view addSubview:_tip];
    [self.tip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.equalTo(lineView.mas_bottom).offset(5);
        make.height.mas_equalTo(16);
    }];
    
    
    self.sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendCodeBtn setTitle:NSLocalizedString(@"register_get_code", @"获取验证码") forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateDisabled];
    self.sendCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
    [self.sendCodeBtn addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    self.sendCodeBtn.backgroundColor = kRGBColor(230, 230, 230);
    self.sendCodeBtn.enabled = NO;
    self.sendCodeBtn.layer.cornerRadius = 3;
    [self.view addSubview:self.sendCodeBtn];
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(lineView.mas_bottom).offset(120 * kScreenAllHeightScale);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(48);
    }];
}

//是否可发送验证码
- (void)checkSendCode{
    if (self.phoneTF.text.length > 0) {
        self.sendCodeBtn.backgroundColor = kMainColor;
        self.sendCodeBtn.enabled = YES;
    }
    else{
        self.sendCodeBtn.backgroundColor = kRGBColor(230, 230, 230);
        self.sendCodeBtn.enabled = NO;
    }
}

#pragma mark eventResponse

-(void)changedTextField:(UITextField *)textField{
    [self checkSendCode];
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
    
        self.conturyCode = CountryCode;
        [self.areaCodeBtn setTitle:[NSString stringWithFormat:@"%@",Title] forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:regionVC animated:YES];
}

- (void)sendCode:(id)sender{
    NSDictionary *tmpDic = @{@"Type":@"register",@"CountryCode":self.conturyCode,@"PhoneNumber":self.phoneTF.text};
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] postWithoutToken:AppSendVerificationCode Param:tmpDic success:^(id responseObject) {
        TIoTSendPhoneCodeViewController *vc = [[TIoTSendPhoneCodeViewController alloc] init];
        vc.registerType = LoginedResetPwd;
        vc.sendCodeDic = tmpDic;
        [self.navigationController pushViewController:vc animated:YES];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
    
}

@end
