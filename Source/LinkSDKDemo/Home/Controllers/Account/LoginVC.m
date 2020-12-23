//
//  LoginVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/3.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "LoginVC.h"

#import "RTSPPlayer.h"

@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;


@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic, strong) RTSPPlayer *video;
@property (nonatomic, strong) NSTimer *nextFrameTimer;
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


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
    [_nextFrameTimer invalidate];
    self.nextFrameTimer = nil;
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    self.video = nil;
}



//#############Video##################//
- (IBAction)showVideo:(id)sender {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width * 320 / 426)];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    self.imageView.userInteractionEnabled = YES;
    
    self.video = [[RTSPPlayer alloc] initWithVideo:@"http://zhibo.hkstv.tv/livestream/mutfysrq.flv" usesTcp:YES];
    self.video.outputWidth = 426;
    self.video.outputHeight = 320;
    
    self.nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                                           target:self
                                                         selector:@selector(displayNextFrame:)
                                                         userInfo:nil
                                                          repeats:YES];
}


- (void)viewDidDisappear:(BOOL)animated {
    [_nextFrameTimer invalidate];
    self.nextFrameTimer = nil;
}
-(void)displayNextFrame:(NSTimer *)timer{
    if (![self.video stepFrame]) {
        [timer invalidate];
        [self.video closeAudio];
        return;
    }
    self.imageView.image = self.video.currentImage;
}
//#############Video##################//

@end
