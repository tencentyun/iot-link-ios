//
//  WCBingPasswordViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTBingPasswordViewController.h"

@interface TIoTBingPasswordViewController ()

@property (nonatomic, strong) UITextField *passWordTF;
@property (nonatomic, strong) UITextField *passWordTF2;
@property (nonatomic, strong) UIButton *downBtn;

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
    self.title = @"设置密码";
    
    
    self.passWordTF = [[UITextField alloc] init];
    self.passWordTF.placeholder = @"密码";
    self.passWordTF.textColor = kFontColor;
    self.passWordTF.clearButtonMode = UITextFieldViewModeAlways;
    self.passWordTF.secureTextEntry = YES;
    self.passWordTF.font = [UIFont wcPfRegularFontOfSize:14];
    [self.passWordTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.passWordTF];
    [self.passWordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(24);
        make.top.mas_equalTo([TIoTUIProxy shareUIProxy].navigationBarHeight + 52 * kScreenAllHeightScale);
        make.trailing.equalTo(self.view).offset(-24);
        make.height.mas_equalTo(48);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = kLineColor;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passWordTF.mas_bottom).offset(0);
        make.left.equalTo(self.view).offset(24);
        make.right.equalTo(self.view).offset(-24);
        make.height.mas_equalTo(1);
    }];
    
    self.passWordTF2 = [[UITextField alloc] init];
    self.passWordTF2.placeholder = @"请再次输入密码";
    self.passWordTF2.textColor = kFontColor;
    self.passWordTF2.secureTextEntry = YES;
    self.passWordTF2.clearButtonMode = UITextFieldViewModeAlways;
    self.passWordTF2.font = [UIFont wcPfRegularFontOfSize:14];
    [self.passWordTF2 addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.passWordTF2];
    [self.passWordTF2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(24);
        make.top.equalTo(lineView.mas_bottom).offset(20);
        make.trailing.equalTo(self.view).offset(-24);
        make.height.mas_equalTo(48);
    }];
    
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = kLineColor;
    [self.view addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passWordTF2.mas_bottom).offset(0);
        make.left.equalTo(self.view).offset(24);
        make.right.equalTo(self.view).offset(-24);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.text = @"密码8～16位需包含字母和数字";
    tipLab.textColor = kRGBColor(153, 153, 153);
    tipLab.font = [UIFont wcPfRegularFontOfSize:12];
    [self.view addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(lineView2.mas_bottom).offset(40 * kScreenAllHeightScale);
    }];
    
    self.downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.downBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.downBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateDisabled];
    self.downBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.downBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    self.downBtn.backgroundColor = kMainColorDisable;
    self.downBtn.enabled = NO;
    self.downBtn.layer.cornerRadius = 3;
    [self.view addSubview:self.downBtn];
    [self.downBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(tipLab.mas_bottom).offset(114 * kScreenAllHeightScale);
        make.right.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(50);
    }];
}

#pragma mark eventResponse
-(void)changedTextField:(UITextField *)textField{
    if (self.passWordTF.text.length >= 8 && self.passWordTF2.text.length >= 8) {
        self.downBtn.backgroundColor = kMainColor;
        self.downBtn.enabled = YES;
    }
    else
    {
        self.downBtn.backgroundColor = kMainColorDisable;
        self.downBtn.enabled = NO;
    }
//    BOOL isPass = [NSString judgePassWordLegal:textField.text];
//    if (isPass) {
//        self.downBtn.backgroundColor = kMainColor;
//        self.downBtn.enabled = YES;
//    }
//    else{
//        self.downBtn.backgroundColor = kRGBColor(230, 230, 230);
//        self.downBtn.enabled = NO;
//    }
}


- (void)sureClick:(id)sender{
    
    if (![self.passWordTF.text isEqualToString:self.passWordTF2.text]) {
        [MBProgressHUD showMessage:@"两次输入的密码不一致" icon:@"" toView:self.view];
        return;
    }
    
    BOOL isPass = [NSString judgePassWordLegal:self.passWordTF.text];
    if (!isPass) {
        [MBProgressHUD showMessage:@"密码不合规" icon:@"" toView:self.view];
        return;
    }
    
    if (self.registerType == PhoneRegister) {
        NSDictionary *tmpDic = @{@"CountryCode":self.sendDataDic[@"CountryCode"],@"PhoneNumber":self.sendDataDic[@"PhoneNumber"],@"VerificationCode":self.sendDataDic[@"VerificationCode"],@"Password":self.passWordTF.text};
        [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppCreateCellphoneUser Param:tmpDic success:^(id responseObject) {
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



@end
