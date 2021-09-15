//
//  TIoTAllDevicesVC.m
//  TIoTAllDevicesVC
//
//  Created by whalensun on 2021/9/14.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTAllDevicesVC.h"

@interface TIoTAllDevicesVC ()

@property (weak, nonatomic) IBOutlet UITextField *accessTokenTextField;
@property (weak, nonatomic) IBOutlet UITextField *platformIdTextField;
@property (weak, nonatomic) IBOutlet UILabel *devicesLabel;

@end

@implementation TIoTAllDevicesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)showAllDevices:(UIButton *)sender {
    
}


@end
