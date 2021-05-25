//
//  TIoTMainVC.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/13.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTMainVC.h"
#import "LoginVC.h"
#import "TIoTVideoVC.h"

@interface TIoTMainVC ()
@property (weak, nonatomic) IBOutlet UILabel *versionLB;

@end

@implementation TIoTMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _versionLB.text = [NSString stringWithFormat:@"v%@",appVersion];
}
- (IBAction)jumpLinkSDK:(id)sender {
    LoginVC *loginVC = [[LoginVC alloc]init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (IBAction)jumpVideo:(id)sender {
    TIoTVideoVC *videoVC = [[TIoTVideoVC alloc]init];
    [self.navigationController pushViewController:videoVC animated:YES];
}

- (IBAction)jumpRTC:(id)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
