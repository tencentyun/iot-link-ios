//
//  TIoTDemoSameScreenVC.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/27.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoSameScreenVC.h"

@interface TIoTDemoSameScreenVC ()

@end

@implementation TIoTDemoSameScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSameScreenSubviews];
}

- (void)setupSameScreenSubviews {
    self.view.backgroundColor = [UIColor blackColor];
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
