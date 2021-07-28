//
//  LoginVC.m
//  QCFrameworkDemo
//
//

#import "LoginVC.h"
#import "TIoTCoreUserManage.h"

@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)signIn:(id)sender {
    
    if (0 == self.segment.selectedSegmentIndex) {
        [[TIoTCoreAccountSet shared] signInWithCountryCode:@"86" phoneNumber:self.account.text password:self.password.text success:^(id  _Nonnull responseObject) {
            NSLog(@"登录==%@",responseObject);
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [sb instantiateInitialViewController];
            [UIApplication sharedApplication].keyWindow.rootViewController = vc;
            
            [self getUserInfo];
            
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
            NSLog(@"登录错==%@",reason);
        }];
    }
    else if (1 == self.segment.selectedSegmentIndex)
    {
        [[TIoTCoreAccountSet shared] signInWithEmail:self.account.text password:self.password.text success:^(id  _Nonnull responseObject) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [sb instantiateInitialViewController];
            [UIApplication sharedApplication].keyWindow.rootViewController = vc;
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
            
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

@end
