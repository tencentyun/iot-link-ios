//
//  TIoTSettingIntelligentNameVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTSettingIntelligentNameVC.h"
#import "UILabel+TIoTExtension.h"
#import "UIButton+LQRelayout.h"

@interface TIoTSettingIntelligentNameVC ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *nameTextTield;
@property (nonatomic, strong) UIButton *saveModifyName;
@end

@implementation TIoTSettingIntelligentNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI {
    
    self.title = NSLocalizedString(@"change_Intelligent_Name", @"填写智能名称");
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    CGFloat kNameViewHeight = 48;
    
    UIView *nameView = [[UIView alloc]init];
    nameView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:nameView];
    [nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(16);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset( 64 + 16);
        }
        make.height.mas_equalTo(kNameViewHeight);
    }];
    
     self.titleLabel = [[UILabel alloc]init];
    [self.titleLabel setLabelFormateTitle:NSLocalizedString(@"setting_Intelligent_Name", @"智能名称") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [nameView addSubview:self.titleLabel];
     [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(nameView.mas_left).offset(16);
         make.centerY.equalTo(nameView);
         make.width.mas_equalTo(60);
    }];
    
    self.nameTextTield = [[UITextField alloc]init];
    self.nameTextTield.textColor = [UIColor colorWithHexString:@"#6C7078"];
    self.nameTextTield.font = [UIFont wcPfRegularFontOfSize:14];
    self.nameTextTield.placeholder = NSLocalizedString(@"please_input_sceneName", @"请输入智能名称");
    if (![NSString isNullOrNilWithObject:self.defaultSceneString]) {
        self.nameTextTield.text = self.defaultSceneString;
    }
    [nameView addSubview:self.nameTextTield];
    [self.nameTextTield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(28);
        make.centerY.equalTo(nameView);
        make.right.equalTo(nameView.mas_right);
    }];
    
    self.saveModifyName = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveModifyName setButtonFormateWithTitlt:NSLocalizedString(@"save", @"保存") titleColorHexString:@"ffffff" font:[UIFont wcPfRegularFontOfSize:16]];
    [self.saveModifyName setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
    self.saveModifyName.layer.cornerRadius = 20;
    [self.saveModifyName addTarget:self action:@selector(modifyName) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveModifyName];
    [self.saveModifyName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.top.equalTo(self.nameTextTield.mas_bottom).offset(50);
        make.height.mas_equalTo(40);
    }];
}

- (void)modifyName {
    
    [self.nameTextTield resignFirstResponder];
    
    if ([NSString isNullOrNilWithObject:self.nameTextTield.text] || [NSString isFullSpaceEmpty:self.nameTextTield.text]) {
        [MBProgressHUD showMessage:NSLocalizedString(@"error_setting_Intelligent_Name", @"请设置智能名称") icon:@""];
    }else {
        
        if (self.nameTextTield.text.length >20) {
            [MBProgressHUD showError:NSLocalizedString(@"sceneName_overLenght", @"名称不能超过20个字符")];
        }else {
            if (self.saveIntelligentNameBlock) {
                self.saveIntelligentNameBlock(self.nameTextTield.text);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
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
