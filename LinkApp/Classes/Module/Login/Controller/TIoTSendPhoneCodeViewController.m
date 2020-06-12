//
//  WCSendPhoneCodeViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTSendPhoneCodeViewController.h"
#import "JHVerificationCodeView.h"
#import "TIoTUserManage.h"

@interface TIoTSendPhoneCodeViewController ()

@property (nonatomic, strong) UIButton *registerBtn;
@property (nonatomic, strong) JHVerificationCodeView *codeView;
@property (nonatomic, strong) UIButton *sendCodeBtn;

@property (nonatomic, copy) NSString *code;

@end

@implementation TIoTSendPhoneCodeViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.codeView.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

#pragma mark lifeCircle
- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"验证码";
    
    
    JHVCConfig *config     = [[JHVCConfig alloc] init];
    config.inputBoxNumber  = 6;
    config.inputBoxSpacing = 4;
    config.inputBoxWidth   = 34;
    config.inputBoxHeight  = 40;
    config.tintColor       = kFontColor;
    config.secureTextEntry = NO;
    config.inputBoxColor   = [UIColor clearColor];
    config.font            = [UIFont wcPfRegularFontOfSize:24];
    config.textColor       = kFontColor;
    config.inputType       = JHVCConfigInputType_Number;
    config.keyboardType = UIKeyboardTypeNumberPad;
    config.inputBoxBorderWidth  = 1;
    config.showUnderLine = YES;
    config.underLineSize = CGSizeMake(30, 1);
    config.underLineColor = [UIColor blackColor];
    config.underLineHighlightedColor = [UIColor blackColor];
    
    [self.view addSubview:({
        WeakObj(self)
        self.codeView = [[JHVerificationCodeView alloc] initWithFrame:CGRectMake(kHorEdge, [TIoTUIProxy shareUIProxy].navigationBarHeight + 70* kScreenAllHeightScale, 246, 40) config:config];
        CGPoint center = self.codeView.center;
        center.x = self.view.center.x;
        self.codeView.center = center;
        self.codeView.finishBlock = ^(NSString *code) {
            
            selfWeak.code = code;
            [selfWeak checkSendCode];
        };
        self.codeView.inputBlock = ^(NSString *code) {
            selfWeak.code = code;
            [selfWeak checkSendCode];
        };
        self.codeView;
    })];
    
    
    UILabel *tipLab = [[UILabel alloc] init];
    if (self.registerType == PhoneRegister || self.registerType == PhoneResetPwd) {
        tipLab.text = [NSString stringWithFormat:@"验证码已经发送到您的手机:%@-%@",self.sendCodeDic[@"CountryCode"]?:@"",self.sendCodeDic[@"PhoneNumber"]?:@""];
    }
    else{
        tipLab.text = [NSString stringWithFormat:@"验证码已经发送到您的邮箱:%@",self.sendCodeDic[@"Email"]?:@""];
    }
    
    tipLab.textColor = kRGBColor(153, 153, 153);
    tipLab.font = [UIFont wcPfRegularFontOfSize:12];
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.numberOfLines = 0;
    [self.view addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kHorEdge);
        make.top.equalTo(self.codeView.mas_bottom).offset(40 * kScreenAllHeightScale);
        make.right.equalTo(self.view).offset(-kHorEdge);
    }];

    self.sendCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendCodeBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:12];
    [self.sendCodeBtn setTitle:@"重新发送(60s)" forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateNormal];
    [self.sendCodeBtn addTarget:self action:@selector(sendCode:) forControlEvents:UIControlEventTouchUpInside];
    [self openCountdown];
    [self.view addSubview:self.sendCodeBtn];
    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(tipLab.mas_bottom);
    }];
    
    
    self.registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.registerBtn setTitle:self.registerType == LoginedResetPwd ? @"确定" : @"下一步" forState:UIControlStateNormal];
    [self.registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.registerBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateDisabled];
    self.registerBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.registerBtn addTarget:self action:@selector(registerClick:) forControlEvents:UIControlEventTouchUpInside];
    self.registerBtn.backgroundColor = kMainColorDisable;
    self.registerBtn.enabled = NO;
    self.registerBtn.layer.cornerRadius = 3;
    [self.view addSubview:self.registerBtn];
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(self.sendCodeBtn.mas_bottom).offset(114 * kScreenAllHeightScale);
        make.right.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(50);
    }];
}

//是否可进行下一步
- (void)checkSendCode{
    if (self.code.length == 6) {
        self.registerBtn.backgroundColor = kMainColor;
        self.registerBtn.enabled = YES;
    }
    else{
        self.registerBtn.backgroundColor = kMainColorDisable;
        self.registerBtn.enabled = NO;
    }
}

- (void)openCountdown{
    WeakObj(self)
    __block NSInteger time = 59; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                [selfWeak.sendCodeBtn setTitle:@"重新发送验证码" forState:UIControlStateNormal];
                selfWeak.sendCodeBtn.userInteractionEnabled = YES;
                [selfWeak.sendCodeBtn setTitleColor:kMainColor forState:UIControlStateNormal];
            });
            
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [selfWeak.sendCodeBtn setTitle:[NSString stringWithFormat:@"重新发送(%.2ds)", seconds] forState:UIControlStateNormal];
                selfWeak.sendCodeBtn.userInteractionEnabled = NO;
                [selfWeak.sendCodeBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateNormal];
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}

#pragma mark eventResponse
- (void)registerClick:(id)sender{
    if (self.registerType == PhoneRegister || self.registerType == PhoneResetPwd) {
        NSDictionary *tmpDic = @{@"Type":self.sendCodeDic[@"Type"],@"CountryCode":self.sendCodeDic[@"CountryCode"],@"PhoneNumber":self.sendCodeDic[@"PhoneNumber"],@"VerificationCode":self.code};
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppCheckVerificationCode Param:tmpDic success:^(id responseObject) {
            TIoTBingPasswordViewController *vc = [[TIoTBingPasswordViewController alloc] init];
            vc.sendDataDic = tmpDic;
            vc.registerType = self.registerType;
            [self.navigationController pushViewController:vc animated:YES];
        } failure:^(NSString *reason, NSError *error) {
            
        }];
        
    }
    else if (self.registerType == EmailRegister || self.registerType == EmailResetPwd) {
        NSDictionary *tmpDic = @{@"Type":self.sendCodeDic[@"Type"],@"Email":self.sendCodeDic[@"Email"],@"VerificationCode":self.code};
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppCheckEmailVerificationCode Param:tmpDic success:^(id responseObject) {
            TIoTBingPasswordViewController *vc = [[TIoTBingPasswordViewController alloc] init];
            vc.sendDataDic = tmpDic;
            vc.registerType = self.registerType;
            [self.navigationController pushViewController:vc animated:YES];
        } failure:^(NSString *reason, NSError *error) {
            
        }];
        
    }
    else
    {
        NSDictionary *tmpDic = @{@"Type":self.sendCodeDic[@"Type"],@"CountryCode":self.sendCodeDic[@"CountryCode"],@"PhoneNumber":self.sendCodeDic[@"PhoneNumber"],@"VerificationCode":self.code};
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppCheckVerificationCode Param:tmpDic success:^(id responseObject) {
            
            [[TIoTRequestObject shared] post:AppUpdateUser Param:@{@"phoneNumber":self.sendCodeDic[@"PhoneNumber"],@"VerificationCode":self.code,@"CountryCode":self.sendCodeDic[@"CountryCode"]} success:^(id responseObject) {
                UIViewController *userInfoVC = self.navigationController.viewControllers[1];
                [self.navigationController popToViewController:userInfoVC animated:YES];
                [MBProgressHUD showSuccess:@"修改成功"];
                [TIoTUserManage shared].phoneNumber = self.sendCodeDic[@"PhoneNumber"];
                [HXYNotice addModifyUserInfoPost];
            } failure:^(NSString *reason, NSError *error) {
                
            }];
            
        } failure:^(NSString *reason, NSError *error) {
            
        }];
    }
    
}

- (void)sendCode:(id)sender{
    if (self.registerType == PhoneRegister || self.registerType == PhoneResetPwd || self.registerType == LoginedResetPwd) {
        NSDictionary *tmpDic = @{@"Type":self.sendCodeDic[@"Type"],@"CountryCode":self.sendCodeDic[@"CountryCode"],@"PhoneNumber":self.sendCodeDic[@"PhoneNumber"]};
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        [[TIoTRequestObject shared] postWithoutToken:AppSendVerificationCode Param:tmpDic success:^(id responseObject) {
            [MBProgressHUD showSuccess:@"发送成功"];
            [self openCountdown];
        } failure:^(NSString *reason, NSError *error) {
            
        }];
        
    }
    else if (self.registerType == EmailRegister || self.registerType == EmailResetPwd)
    {
        NSDictionary *tmpDic = @{@"Type":self.sendCodeDic[@"Type"],@"Email":self.sendCodeDic[@"Email"]};
        [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
        
        
        [[TIoTRequestObject shared] postWithoutToken:AppSendEmailVerificationCode Param:tmpDic success:^(id responseObject) {
            [MBProgressHUD dismissInView:self.view];
            [MBProgressHUD showSuccess:@"发送成功"];
            [self openCountdown];
        } failure:^(NSString *reason, NSError *error) {
            
        }];
    }
}

@end
