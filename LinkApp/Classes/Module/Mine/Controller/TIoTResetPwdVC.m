//
//  WCResetPwdVC.m
//  TenextCloud
//
//  Created by Wp on 2019/11/5.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTResetPwdVC.h"
#import "TIoTNavigationController.h"
#import "TIoTLoginVC.h"
#import "TIoTAppEnvironment.h"

@interface TIoTResetPwdVC ()
@property (nonatomic, strong) UITextField *oldPwdTF;
@property (nonatomic, strong) UITextField *passWordTF;
@property (nonatomic, strong) UITextField *passWordTF2;
@property (nonatomic, strong) UIButton *downBtn;

@end

@implementation TIoTResetPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpUI];
}

#pragma mark - event
-(void)changedTextField:(UITextField *)textField{
    if (self.oldPwdTF.text.length >= 8 && self.passWordTF.text.length >= 8 && self.passWordTF2.text.length >= 8) {
        self.downBtn.backgroundColor = kMainColor;
        self.downBtn.enabled = YES;
    }
    else
    {
        self.downBtn.backgroundColor = kRGBColor(230, 230, 230);
        self.downBtn.enabled = NO;
    }
}


- (void)sureClick:(id)sender{
    
    if (![self.passWordTF.text isEqualToString:self.passWordTF2.text]) {
        [MBProgressHUD showMessage:@"两次输入的新密码不一致" icon:@"" toView:self.view];
        return;
    }
    
    BOOL isPass = [NSString judgePassWordLegal:self.passWordTF.text];
    if (!isPass) {
        [MBProgressHUD showMessage:@"密码不合规" icon:@"" toView:self.view];
        return;
    }
    
    if ([self.oldPwdTF.text isEqualToString:self.passWordTF.text]) {
        [MBProgressHUD showMessage:@"新密码不能与旧密码相同" icon:@"" toView:self.view];
        return;
    }
    
    NSDictionary *tmpDic = @{@"Password":self.oldPwdTF.text,@"NewPassword":self.passWordTF.text};
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] post:AppUserResetPassword Param:tmpDic success:^(id responseObject) {
        [MBProgressHUD showSuccess:@"修改成功，请重新登录"];
        [[TIoTAppEnvironment shareEnvironment] loginOut];
        TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTLoginVC alloc] init]];
        self.view.window.rootViewController = nav;
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

#pragma mark - other

- (void)setUpUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"修改密码";
    
    self.oldPwdTF = [[UITextField alloc] init];
    self.oldPwdTF.placeholder = @"旧密码";
    self.oldPwdTF.textColor = kFontColor;
    self.oldPwdTF.clearButtonMode = UITextFieldViewModeAlways;
    self.oldPwdTF.font = [UIFont wcPfRegularFontOfSize:14];
    self.oldPwdTF.secureTextEntry = YES;
    [self.oldPwdTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.oldPwdTF];
    [self.oldPwdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(24);
        make.top.mas_equalTo(52 * kScreenAllHeightScale + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.trailing.equalTo(self.view).offset(-24);
        make.height.mas_equalTo(48);
    }];
    
    UIView *lineView0 = [[UIView alloc] init];
    lineView0.backgroundColor = kLineColor;
    [self.view addSubview:lineView0];
    [lineView0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.oldPwdTF.mas_bottom).offset(0);
        make.left.equalTo(self.view).offset(24);
        make.right.equalTo(self.view).offset(-24);
        make.height.mas_equalTo(1);
    }];
    
    self.passWordTF = [[UITextField alloc] init];
    self.passWordTF.placeholder = @"密码";
    self.passWordTF.textColor = kFontColor;
    self.passWordTF.secureTextEntry = YES;
    self.passWordTF.clearButtonMode = UITextFieldViewModeAlways;
    self.passWordTF.font = [UIFont wcPfRegularFontOfSize:14];
    [self.passWordTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.passWordTF];
    [self.passWordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(24);
        make.top.equalTo(lineView0.mas_bottom).offset(20);
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
    [self.downBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateDisabled];
    self.downBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.downBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    self.downBtn.backgroundColor = kRGBColor(230, 230, 230);
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

@end
