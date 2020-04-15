//
//  WCNavigationController.m
//  TenextCloud
//
//  Created by Wp on 2019/11/4.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCNavigationController.h"
#import "UIImage+Ex.h"

@interface WCNavigationController ()

@end

@implementation WCNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
}

@end
