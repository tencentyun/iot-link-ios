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
    [self.view endEditing:YES];
    [[TIoTCoreDeviceSet shared] getVirtualBindDeviceListWithAccessToken:self.accessTokenTextField.text platformId:self.platformIdTextField.text offset:0 limit:0 success:^(id  _Nonnull responseObject) {

        DDLogVerbose(@"getVirtualBindDeviceList==%@",responseObject);
        NSArray *devicesArr = [responseObject objectForKey:@"VirtualBindDeviceList"];
        if (devicesArr) {
            NSString *content = @"";
            for (NSDictionary *device in devicesArr) {
                content = [content stringByAppendingString:[NSString stringWithFormat:@"%@\n", [device objectForKey:@"DeviceName"]]];
            }
            self.devicesLabel.text = content;
        } else {
            [MBProgressHUD showError:@"没有设备"];
        }

    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        if (dic) {
            [MBProgressHUD showError:[NSString stringWithFormat:@"code: %@, msg: %@", [dic objectForKey:@"code"], [dic objectForKey:@"msg"]]];
        }
    }];
}


@end
