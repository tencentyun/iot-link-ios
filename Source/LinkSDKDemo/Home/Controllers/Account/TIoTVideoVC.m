//
//  TIoTVideoVC.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/13.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTVideoVC.h"
#import "TIoTVideoConfigNetVC.h"
#import "TIoTPlayConfigVC.h"
#import "TIoTPlayListVC.h"
#import "TIoTCoreXP2PBridge.h"
#import "TIoTPlayConfigVC.h"

@interface TIoTVideoVC ()
@property (weak, nonatomic) IBOutlet UILabel *versionLB;
@end

@implementation TIoTVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *appVersion = [TIoTCoreXP2PBridge getSDKVersion];
    _versionLB.text = [NSString stringWithFormat:@"v%@",appVersion];
}
- (IBAction)jumpDistributeNet:(id)sender {
    TIoTVideoConfigNetVC *configNetVC = [[TIoTVideoConfigNetVC alloc]init];
    [self.navigationController pushViewController:configNetVC animated:YES];
    
}
- (IBAction)jumpPlaying:(id)sender {
    TIoTPlayConfigVC *playListVC = [[TIoTPlayConfigVC alloc]init];
    [self.navigationController pushViewController:playListVC animated:YES];
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
