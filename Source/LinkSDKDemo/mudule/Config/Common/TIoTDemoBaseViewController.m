//
//  TIoTDemoBaseViewController.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoBaseViewController.h"
#import "UIImage+TIoTDemoExtension.h"

@interface TIoTDemoBaseViewController ()

@end

@implementation TIoTDemoBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavPattarn];
}


- (void)setupNavPattarn {
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#FFFFFF"],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:17]}];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage getGradientImageWithColors:@[[UIColor colorWithHexString:@"#ffffff"],[UIColor colorWithHexString:@"#ffffff"]] imgSize:CGSizeMake(kScreenWidth, 44)] forBarMetrics:UIBarMetricsDefault];
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
