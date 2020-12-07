//
//  TIoTModifyDeviceNameVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/12/7.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTModifyDeviceNameVC.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTSigleCustomButton.h"

@interface TIoTModifyDeviceNameVC ()
@property (nonatomic, strong) UITextField *deviceNameField;
@end

@implementation TIoTModifyDeviceNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    CGFloat kLeftPadding = 15;
    CGFloat kBackViewHeight = 48;
    
    UIView *backgroundView = [[UIView alloc]init];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kBackViewHeight);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64 * kScreenAllHeightScale).offset(20);
        }
        
    }];
    
    UILabel *titleTipText = [[UILabel alloc]init];
    [titleTipText setLabelFormateTitle:self.titleText?:@"" font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [backgroundView addSubview:titleTipText];
    [titleTipText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backgroundView.mas_left).offset(kLeftPadding);
        make.centerY.equalTo(backgroundView.mas_centerY);
        make.width.mas_equalTo(100);
    }];
    
    self.deviceNameField = [[UITextField alloc]init];
    self.deviceNameField.textColor = [UIColor colorWithHexString:@"#6C7078"];
    self.deviceNameField.font = [UIFont wcPfRegularFontOfSize:14];
    self.deviceNameField.text = self.defaultText?:@"";
    self.deviceNameField.placeholder = NSLocalizedString(@"please_input_devicename", @"请输入设备名称");
    [backgroundView addSubview:self.deviceNameField];
    [self.deviceNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleTipText.mas_right);
        make.centerY.equalTo(titleTipText);
        make.right.equalTo(backgroundView.mas_right);
    }];
    
    TIoTSigleCustomButton *saveButton = [[TIoTSigleCustomButton alloc]init];
    saveButton.kLeftRightPadding = kLeftPadding * 2;
    [saveButton singleCustomButtonStyle:SingleCustomButtonConfirm withTitle:NSLocalizedString(@"save", @"保存")];
    saveButton.singleAction = ^{
        [self.deviceNameField resignFirstResponder];
        
        if ([NSString isNullOrNilWithObject:self.deviceNameField.text] || [NSString isFullSpaceEmpty:self.deviceNameField.text]) {
            [MBProgressHUD showMessage:NSLocalizedString(@"please_input_devicename", @"请输入设备名称") icon:@""];
        }else {
            
            if (self.deviceNameField.text.length >20) {
                [MBProgressHUD showError:NSLocalizedString(@"sceneName_overLenght", @"名称不能超过20个字符")];
            }else {
                [self modifyName:self.deviceNameField.text];
            }
        }
    };
    [self.view addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.top.equalTo(backgroundView.mas_bottom).offset(30);
    }];
}

- (void)modifyName:(NSString *)name
{
    [[TIoTRequestObject shared] post:AppUpdateDeviceInFamily Param:@{@"ProductID":self.deviceDic[@"ProductId"],@"DeviceName":self.deviceDic[@"DeviceName"],@"AliasName":name} success:^(id responseObject) {
        if (self.modifyDeviceNameBlcok) {
            self.modifyDeviceNameBlcok(name);
            [self.navigationController popViewControllerAnimated:YES];
        }

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
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
