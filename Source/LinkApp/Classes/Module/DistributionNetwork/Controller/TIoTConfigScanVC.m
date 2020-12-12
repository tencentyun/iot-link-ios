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
#import "UIImageView+TIoTWebImageView.h"
#import "TIoTConfigHardwareViewController.h"

@interface TIoTConfigScanVC ()
@property (nonatomic, strong) NSDictionary *configData;
@property (nonatomic, strong) UILabel *productName;
@end

@implementation TIoTConfigScanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViewsUI];
    
    [self getProductName];
}

- (void)getProductName {
    
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];

    [[TIoTRequestObject shared] post:AppGetProducts Param:@{@"ProductIds":@[self.productID?:@""]} success:^(id responseObject) {
        NSArray *tmpArr = responseObject[@"Products"];
        if (tmpArr.count > 0) {
            NSDictionary *configDic = tmpArr[0]?:@{};
            if (![NSString isNullOrNilWithObject:configDic[@"Name"]]) {
                self.productName.text = configDic[@"Name"];
                [self.view reloadInputViews];
            }
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

    }];

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
    [productImageView setImageWithURLStr:self.welConfigDic[@"IconUrlAdvertise"]?:@"" placeHolder:@"default_config_scan"];
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
    self.productName = [[UILabel alloc]init];
    NSString *productNameString = NSLocalizedString(@"product_name", @"(产品的名称)");
    [self.productName setLabelFormateTitle:productNameString font:[UIFont wcPfMediumFontOfSize:20] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    self.productName.numberOfLines = 0;
    [self.view addSubview:self.productName];
    [self.productName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(productTipLabel.mas_bottom);
        make.left.right.equalTo(self.view);
    }];
    
    //产品别名
    UILabel *productRemark = [[UILabel alloc]init];
    NSString *remarkString = @"";
    if (![NSString isNullOrNilWithObject:self.welConfigDic[@"AddDeviceHintMsg"]]) {
        remarkString = self.welConfigDic[@"AddDeviceHintMsg"];
    }
    [productRemark setLabelFormateTitle:remarkString font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kRegionHexColor textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:productRemark];
    [productRemark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.productName.mas_bottom).offset(12);
    }];
    
    __weak typeof(self)weakSelf = self;
    //绑定按钮
    TIoTSingleCustomButton *bindingButton = [[TIoTSingleCustomButton alloc]init];
    bindingButton.kLeftRightPadding = 40;
    [bindingButton singleCustomButtonStyle:SingleCustomButtonConfirm withTitle:NSLocalizedString(@"binding_immediately", @"立即绑定")];
    bindingButton.singleAction = ^{
        
        [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":@[weakSelf.productID?:@""]} success:^(id responseObject) {
            
            NSArray *data = responseObject[@"Data"];
            if (data.count > 0) {
                NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
                weakSelf.configData = [[NSDictionary alloc]initWithDictionary:config];
                WCLog(@"AppGetProductsConfig config%@", config);
                NSArray *wifiConfTypeList = config[@"WifiConfTypeList"];
                if (wifiConfTypeList.count > 0) {
                    NSString *configType = wifiConfTypeList.firstObject;
                    if ([configType isEqualToString:@"softap"]) {
                        [weakSelf jumpConfigVC:NSLocalizedString(@"soft_ap", @"自助配网")];
                        return;
                    }
                }
            }
            [weakSelf jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
            WCLog(@"AppGetProductsConfig responseObject%@", responseObject);
            
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [weakSelf jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
        }];
        
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

- (void)jumpConfigVC:(NSString *)title{
    TIoTConfigHardwareViewController *vc = [[TIoTConfigHardwareViewController alloc] init];
    vc.configurationData = self.configData;
    if ([title isEqualToString:NSLocalizedString(@"smart_config", @"智能配网")]) {
        vc.configHardwareStyle = TIoTConfigHardwareStyleSmartConfig;
    } else {
        vc.configHardwareStyle = TIoTConfigHardwareStyleSoftAP;
    }
    vc.roomId = self.roomId?:@"";
    [self.navigationController pushViewController:vc animated:YES];
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
