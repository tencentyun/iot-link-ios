//
//  TIoTChooseIntelligentDeviceVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTChooseIntelligentDeviceVC.h"
#import "TIoTDeviceSettingVC.h"
#import "UIButton+LQRelayout.h"

@interface TIoTChooseIntelligentDeviceVC ()

@end

@implementation TIoTChooseIntelligentDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *deviceSetting = [UIButton buttonWithType:UIButtonTypeCustom];
    deviceSetting.frame = CGRectMake(200, 300, 150, 100);
    [deviceSetting setButtonFormateWithTitlt:@"设备设置" titleColorHexString:@"#15161A" font:[UIFont wcPfRegularFontOfSize:16]];
    [deviceSetting addTarget:self action:@selector(jumpDeviceSetting) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deviceSetting];
}

- (void)jumpDeviceSetting {
    TIoTDeviceSettingVC *settingVC = [[TIoTDeviceSettingVC alloc]init];
    [self.navigationController pushViewController:settingVC animated:YES];
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
