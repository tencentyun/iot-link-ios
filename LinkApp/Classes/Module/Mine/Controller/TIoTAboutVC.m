//
//  WCAboutVC.m
//  TenextCloud
//
//  Created by Wp on 2020/3/2.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTAboutVC.h"
#import "TIoTWebVC.h"
#import <QuickLook/QLPreviewController.h>

@interface TIoTAboutVC ()

@property (weak, nonatomic) IBOutlet UILabel *versionLab;

@end

@implementation TIoTAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"关于我们";
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [info objectForKey:@"CFBundleShortVersionString"];
    self.versionLab.text = [NSString stringWithFormat:@"v%@",appVersion];
}


- (IBAction)privacyPolicy:(UITapGestureRecognizer *)sender {
    TIoTWebVC *vc = [TIoTWebVC new];
    vc.title = @"隐私政策";
    vc.urlPath = @"https://iot.cloud.tencent.com/explorer-h5/about-policy/#?type=privacy";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)protocol:(UITapGestureRecognizer *)sender {
    
    TIoTWebVC *vc = [TIoTWebVC new];
    vc.title = @"用户协议";
    vc.urlPath = @"https://docs.qq.com/doc/DY3ducUxmYkRUd2x2?pub=1&dver=2.1.0";
    [self.navigationController pushViewController:vc animated:YES];
}

@end
