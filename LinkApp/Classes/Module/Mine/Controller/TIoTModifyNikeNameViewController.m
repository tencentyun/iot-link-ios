//
//  WCModifyNikeNameViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/10.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTModifyNikeNameViewController.h"
#import "KeyboardManage.h"

@interface TIoTModifyNikeNameViewController ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation TIoTModifyNikeNameViewController

#pragma mark lifeCircle

- (void)dealloc
{
    WCLog(@"释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [KeyboardManage disableIQKeyboard];
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [KeyboardManage openIQKeyboard];
}

#pragma mark - private

- (void)setupUI{
    self.view.backgroundColor = kBgColor;
    self.title = @"修改昵称";
    
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    [right setTitleTextAttributes:@{NSForegroundColorAttributeName:kFontColor,NSFontAttributeName:[UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = right;
    
    UIView *bgview = [UIView new];
    bgview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgview];
    [bgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10 + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(48);
    }];
    
    [bgview addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.top.bottom.mas_equalTo(0);
    }];
}


- (void)done
{
    if (self.textField.text.length > 20) {
        [MBProgressHUD showError:@"昵称请勿超过20字符"];
        return;
    }
    
    if (![self.textField.text isEqualToString:[TIoTCoreUserManage shared].nickName]) {
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        
        [[TIoTRequestObject shared] post:AppUpdateUser Param:@{@"NickName":self.textField.text,@"Avatar":[TIoTCoreUserManage shared].avatar} success:^(id responseObject) {
            [MBProgressHUD showSuccess:@"修改成功"];
            [[TIoTCoreUserManage shared] saveUserInfo:@{@"UserID":[TIoTCoreUserManage shared].userId,@"Avatar":[TIoTCoreUserManage shared].avatar,@"NickName":self.textField.text,@"PhoneNumber":[TIoTCoreUserManage shared].phoneNumber}];
            [HXYNotice addModifyUserInfoPost];
        } failure:^(NSString *reason, NSError *error) {
            
        }];
    }
    else
    {
        [MBProgressHUD showMessage:@"您还未做更改" icon:@""];
    }
}

#pragma mark - getter

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.placeholder = @"请输入昵称";
        _textField.text = [TIoTCoreUserManage shared].nickName;
        _textField.textColor = kRGBColor(51, 51, 51);
        _textField.font = [UIFont wcPfRegularFontOfSize:16];
        _textField.textContentType = UITextContentTypeNickname;
    }
    return _textField;
}

@end
