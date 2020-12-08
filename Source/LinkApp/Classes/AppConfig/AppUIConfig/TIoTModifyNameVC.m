//
//  TIoTModifyNameVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/12/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTModifyNameVC.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTSingleCustomButton.h"
@interface TIoTModifyNameVC ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) NSString *nameTypeString;
@end

@implementation TIoTModifyNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI {
    
    self.nameTypeString = @"";
    [self setNameStringWithType:self.modifyType];
    
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
    
    self.nameField = [[UITextField alloc]init];
    self.nameField.textColor = [UIColor colorWithHexString:@"#6C7078"];
    self.nameField.font = [UIFont wcPfRegularFontOfSize:14];
    self.nameField.text = self.defaultText?:@"";
    self.nameField.placeholder = self.nameTypeString;
    self.nameField.returnKeyType = UIReturnKeyDone;
    self.nameField.delegate = self;
    [backgroundView addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleTipText.mas_right);
        make.centerY.equalTo(titleTipText);
        make.right.equalTo(backgroundView.mas_right);
    }];
    
    TIoTSingleCustomButton *saveButton = [[TIoTSingleCustomButton alloc]init];
    saveButton.kLeftRightPadding = kLeftPadding * 2;
    [saveButton singleCustomButtonStyle:SingleCustomButtonConfirm withTitle:NSLocalizedString(@"save", @"保存")];
    saveButton.singleAction = ^{
        [self.nameField resignFirstResponder];
        
        if ([NSString isNullOrNilWithObject:self.nameField.text] || [NSString isFullSpaceEmpty:self.nameField.text]) {
            [MBProgressHUD showMessage:self.nameTypeString icon:@""];
        }else {
            
            if (self.modifyType == ModifyTypeNickName) {
                if (self.nameField.text.length > 10) {
                    [MBProgressHUD showError:NSLocalizedString(@"nickName_overLenght", @"名称不能超过10个字符")];
                }else {
                    [self modifyName:self.nameField.text];
                }
            }else {
                if (self.nameField.text.length >20) {
                    [MBProgressHUD showError:NSLocalizedString(@"sceneName_overLenght", @"名称不能超过20个字符")];
                }else {
                    [self modifyName:self.nameField.text];
                }
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
    switch (self.modifyType) {
        case ModifyTypeNickName: {
            [self modifyNickName:name];
            break;
        }
        case ModifyTypeFamilyName: {
            if (self.modifyNameBlock) {
                self.modifyNameBlock(name);
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        }
        default:
            break;
    }
}

- (void)modifyNickName:(NSString *)name {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];

    [[TIoTRequestObject shared] post:AppUpdateUser Param:@{@"NickName":name,@"Avatar":[TIoTCoreUserManage shared].avatar} success:^(id responseObject) {
        if (self.modifyNameBlock) {
            self.modifyNameBlock(name);
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

    }];
}

- (void)setNameStringWithType:(ModifyType)nameType {
    switch (nameType) {
        case ModifyTypeNickName: {
            self.nameTypeString = NSLocalizedString(@"please_input_nickName", @"请输入昵称名称");
            break;
        }
        case ModifyTypeFamilyName: {
            self.nameTypeString = NSLocalizedString(@"fill_family_name", @"请输入家庭名称");
            break;;
        }
        default:
            break;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.nameField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nameField resignFirstResponder];
    return YES;
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
