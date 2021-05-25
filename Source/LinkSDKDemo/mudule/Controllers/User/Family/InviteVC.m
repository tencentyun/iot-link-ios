//
//  InviteVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/18.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "InviteVC.h"

@interface InviteVC ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *seg;
@property (weak, nonatomic) IBOutlet UITextField *tf;

@end

@implementation InviteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)send:(id)sender {
    if ([self.title isEqualToString:NSLocalizedString(@"invite_member", @"邀请成员")]) {
        if (self.seg.selectedSegmentIndex) {
            [[TIoTCoreFamilySet shared] sendInvitationToEmail:self.tf.text withFamilyId:self.familyId success:^(id  _Nonnull responseObject) {
                [MBProgressHUD showSuccess:NSLocalizedString(@"send_success", @"发送成功")];
            } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                
            }];
        }
        else
        {
            [[TIoTCoreFamilySet shared] sendInvitationToPhoneNum:self.tf.text withCountryCode:@"86" familyId:self.familyId success:^(id  _Nonnull responseObject) {
                [MBProgressHUD showSuccess:NSLocalizedString(@"send_success", @"发送成功")];
            } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                [MBProgressHUD showError:reason];
            }];
        }
    }
    else if ([self.title isEqualToString:NSLocalizedString(@"device_share", @"设备分享")])
    {
        if (self.seg.selectedSegmentIndex) {
            [[TIoTCoreDeviceSet shared] sendInvitationToEmail:self.tf.text withFamilyId:self.familyId productId:self.productId deviceName:self.deviceName success:^(id  _Nonnull responseObject) {
                [MBProgressHUD showSuccess:NSLocalizedString(@"send_success", @"发送成功")];
            } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                
            }];
        }
        else
        {
            [[TIoTCoreDeviceSet shared] sendInvitationToPhoneNum:self.tf.text withCountryCode:@"86" familyId:self.familyId productId:self.productId deviceName:self.deviceName success:^(id  _Nonnull responseObject) {
                [MBProgressHUD showSuccess:NSLocalizedString(@"send_success", @"发送成功")];
            } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                
            }];
        }
        
    }
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
