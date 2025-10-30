//
//  LoginVC.m
//  QCFrameworkDemo
//
//

#import "LoginVC.h"
#import "TIoTCoreUserManage.h"
#import "WxManager.h"
#import "LinkSDKDemo-Swift.h"
#import "AppDelegate.h"

@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (nonatomic, strong) UserManager *userManager;
@property (nonatomic, strong) UIViewController *loginSwiftUIVC;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    
    // 初始化UserManager
    self.userManager = [[UserManager alloc] init];
    
    // 设置登录成功回调
    __weak typeof(self) weakSelf = self;
    self.userManager.loginSuccessCallback = ^{
        NSLog(@"UserManager: 登录成功回调被触发");
        [weakSelf handleLoginSuccess];
    };
    
    // 设置注册成功回调
    self.userManager.registerSuccessCallback = ^{
        NSLog(@"UserManager: 注册成功回调被触发");
        [weakSelf handleLoginSuccess];
    };
    
    // 设置微信登录回调
    self.userManager.wechatLoginCallback = ^{
        [weakSelf handleWechatLogin];
    };
    
    // 使用SwiftUI的LoginView
    self.loginSwiftUIVC = [SwiftUIHelper createLoginViewControllerWithUserManager:self.userManager];
    [self addChildViewController:self.loginSwiftUIVC];
    [self.view addSubview:self.loginSwiftUIVC.view];
    
    // 设置约束
    self.loginSwiftUIVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.loginSwiftUIVC.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.loginSwiftUIVC.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.loginSwiftUIVC.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.loginSwiftUIVC.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    [self.loginSwiftUIVC didMoveToParentViewController:self];
}

// 处理登录成功
- (void)handleLoginSuccess {
    // 获取用户信息
    [self getUserInfo];
    
    // 跳转到DeviceListView
    [self navigateToDeviceList];
}

// 处理微信登录
- (void)handleWechatLogin {
    [[WxManager sharedWxManager] authFromWxComplete:^(id obj, NSError *error) {
        if (!error) {
            [self getTokenByOpenId:[NSString stringWithFormat:@"%@",obj]];
        }
    }];
}

- (IBAction)wechatLogin:(id)sender {
    [[WxManager sharedWxManager] authFromWxComplete:^(id obj, NSError *error) {
        if (!error) {
            [self getTokenByOpenId:[NSString stringWithFormat:@"%@",obj]];
        }
    }];
}

- (void)getTokenByOpenId:(NSString *)code
{
//    NSString *busivalue = @"studioappOpensource";
     
    [[TIoTCoreAccountSet shared] signInByWechatWithCode:code Success:^(id  _Nonnull responseObject) {
        DDLogDebug(@"登录==%@",responseObject);
        
        [self getUserInfo];
        
        // 跳转到DeviceListView
        [self navigateToDeviceList];
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        DDLogDebug(@"登录错==%@",reason);
    }];
}

- (IBAction)signIn:(id)sender {
    if (0 == self.segment.selectedSegmentIndex) {
        [[TIoTCoreAccountSet shared] signInWithCountryCode:@"86" phoneNumber:self.account.text password:self.password.text success:^(id  _Nonnull responseObject) {
            DDLogDebug(@"登录==%@",responseObject);
            
            [self getUserInfo];
            
            // 跳转到DeviceListView
            [self navigateToDeviceList];
            
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
            DDLogDebug(@"登录错==%@",reason);
        }];
    }
    else if (1 == self.segment.selectedSegmentIndex)
    {
        [[TIoTCoreAccountSet shared] signInWithEmail:self.account.text password:self.password.text success:^(id  _Nonnull responseObject) {
            DDLogDebug(@"登录==%@",responseObject);
            
            [self getUserInfo];
            
            // 跳转到DeviceListView
            [self navigateToDeviceList];
            
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
            DDLogDebug(@"登录错==%@",reason);
        }];
    }
}

- (IBAction)resetPassword:(id)sender {
    UIViewController *vc = [NSClassFromString(@"RegistVC") new];
    vc.title = NSLocalizedString(@"reset_password", @"重置密码");
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)regist:(id)sender {
    UIViewController *vc = [NSClassFromString(@"RegistVC") new];
    vc.title = NSLocalizedString(@"register", @"注册");
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)getUserInfo {
    [[TIoTCoreAccountSet shared] getUserInfoOnSuccess:^(id  _Nonnull responseObject) {
        
        [TIoTCoreUserManage shared].nickName = responseObject[@"Data"][@"NickName"];
        [TIoTCoreUserManage shared].userId = responseObject[@"Data"][@"UserID"];
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

// 跳转到设备列表页面
- (void)navigateToDeviceList {
    AppDelegate *dele = [UIApplication sharedApplication].delegate;
    [dele showDeviceListView];
}

@end
