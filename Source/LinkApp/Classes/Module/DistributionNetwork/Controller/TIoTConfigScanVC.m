//
//  TIoTConfigScanVC.m
//  TIoTLinkKit
//
//  Created by ccharlesren on 2020/12/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTConfigScanVC.h"
#import "TIoTSingleCustomButton.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTChoseFamilyVC.h"
#import "UIImageView+TIoTWebImageView.h"

@interface TIoTConfigScanVC ()
//@property (nonatomic, strong) UIImageView *productImageView; //顶部产品image
//@property (nonatomic, strong) UILabel *productTipLabel; //欢迎提示语
//@property (nonatomic, strong) UILabel *productName; //产品名称
//@property (nonatomic, strong) UILabel *productRemark;   //产品别名
//@property (nonatomic, strong) TIoTSingleCustomButton *bindingButton; //绑定按钮
//@property (nonatomic, strong) UIImageView *logoIconImageView; //底部logo
@end

@implementation TIoTConfigScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViewsUI];
}

- (void)setupViewsUI {
    
    self.title = NSLocalizedString(@"binding_device", @"绑定设备");
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat kWidthHeightProImage = 128; //产品宽高
    CGFloat kProImageTopPadding = 70; //产品image顶部距离
    CGFloat kProTipInterval = 45; //欢迎语顶部距离
    CGFloat kBottomPadding = 32;
    
    //顶部产品image
    UIImageView *productImageView = [[UIImageView alloc]init];
    [productImageView setImageWithURLStr:self.welConfigDic[@"Icon"]?:@"" placeHolder:@"default_config_scan"];
    [self.view addSubview:productImageView];
    [productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.width.mas_equalTo(kWidthHeightProImage);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kProImageTopPadding);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64*kScreenAllHeightScale +kProImageTopPadding);
        }
    }];
    
    //欢迎提示语
    UILabel *productTipLabel = [[UILabel alloc]init];
    [productTipLabel setLabelFormateTitle:NSLocalizedString(@"welcome_use", @"欢迎使用") font:[UIFont wcPfMediumFontOfSize:20] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    productTipLabel.numberOfLines = 0;
    [self.view addSubview:productTipLabel];
    [productTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(productImageView.mas_bottom).offset(kProTipInterval);
        make.left.right.equalTo(self.view);
    }];
    
    //产品名称
    UILabel *productName = [[UILabel alloc]init];
    [productName setLabelFormateTitle:self.welConfigDic[@"Name"]?:@"" font:[UIFont wcPfMediumFontOfSize:20] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    productName.numberOfLines = 0;
    [self.view addSubview:productName];
    [productName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(productTipLabel.mas_bottom);
        make.left.right.equalTo(self.view);
    }];
    
    //产品别名
    UILabel *productRemark = [[UILabel alloc]init];
    NSString *remarkString = NSLocalizedString(@"scan_experience", @"扫一扫体验一下");
    if (![NSString isNullOrNilWithObject:self.welConfigDic[@"HintMsg"]]) {
        remarkString = self.welConfigDic[@"HintMsg"];
    }
    [productRemark setLabelFormateTitle:remarkString font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kRegionHexColor textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:productRemark];
    [productRemark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(productName.mas_bottom).offset(12);
    }];
    
    //绑定按钮
    TIoTSingleCustomButton *bindingButton = [[TIoTSingleCustomButton alloc]init];
    bindingButton.kLeftRightPadding = 40;
    [bindingButton singleCustomButtonStyle:SingleCustomButtonConfirm withTitle:NSLocalizedString(@"binding_immediately", @"立即绑定")];
    bindingButton.singleAction = ^{
        TIoTChoseFamilyVC *choseFamilyVC = [[TIoTChoseFamilyVC alloc]init];
        choseFamilyVC.productID = self.productID?:@"";
        choseFamilyVC.roomId = self.roomId;
        [self.navigationController pushViewController:choseFamilyVC animated:YES];
    };
    [self.view addSubview:bindingButton];
    [bindingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(productRemark.mas_bottom).offset(40);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    
    UIImageView *logoImag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"product_logo"]];
    [self.view addSubview:logoImag];
    [logoImag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(40);
        make.centerX.equalTo(self.view);
        if ([TIoTUIProxy shareUIProxy].iPhoneX) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-kBottomPadding);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self.view.mas_bottom).offset(-kBottomPadding);
            }
        }else {
            make.bottom.equalTo(self.view.mas_bottom).offset(-kBottomPadding);
        }
        
    }];
}

#pragma mark - lazy loading

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
