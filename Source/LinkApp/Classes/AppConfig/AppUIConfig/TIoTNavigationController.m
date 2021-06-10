//
//  WCNavigationController.m
//  TenextCloud
//
//

#import "TIoTNavigationController.h"
#import "UIImage+Ex.h"

@interface TIoTNavigationController ()

@end

@implementation TIoTNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    
//    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20]}];
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:17]}];
}

@end
