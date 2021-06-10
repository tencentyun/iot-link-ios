//
//  TIoTDemoNavController.m
//  LinkApp
//
//

#import "TIoTDemoNavController.h"
#import "UIImage+TIoTDemoExtension.h"

@interface TIoTDemoNavController ()

@end

@implementation TIoTDemoNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:17]}];
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
