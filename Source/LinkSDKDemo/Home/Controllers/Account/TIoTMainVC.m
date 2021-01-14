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

@end

@implementation TIoTMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
