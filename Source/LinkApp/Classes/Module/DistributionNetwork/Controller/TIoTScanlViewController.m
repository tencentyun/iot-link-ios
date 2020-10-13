//
//  WCScanlViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/17.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTScanlViewController.h"
#import "SGQRCode.h"
#import "TIoTConfigHardwareViewController.h"

@interface TIoTScanlViewController (){
    SGQRCodeObtain *obtain;
}
@property (nonatomic, strong) SGQRCodeScanView *scanView;
@property (nonatomic, strong) UIButton *flashlightBtn;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) NSDictionary *configData;
@end

@implementation TIoTScanlViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /// 二维码开启方法
    [obtain startRunningWithBefore:nil completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scanView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanView removeTimer];
    [self removeFlashlightBtn];
    [obtain stopRunning];
}

- (void)dealloc {
    [self removeScanningView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blackColor];
    obtain = [SGQRCodeObtain QRCodeObtain];
    
    [self setupQRCodeScan];
    [self setupNavigationBar];
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.promptLabel];
    /// 为了 UI 效果
    [self.view addSubview:self.bottomView];
}

//绑定设备
- (void)bindDevice:(NSString *)signature{
    
    [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
    
    NSString *roomId = self.roomId ?: @"";
    NSDictionary *param = @{@"FamilyId":[TIoTCoreUserManage shared].familyId,@"DeviceSignature":signature,@"RoomId":roomId};
    
    [[TIoTRequestObject shared] post:AppSecureAddDeviceInFamily Param:param success:^(id responseObject) {
        
        [MBProgressHUD showSuccess:NSLocalizedString(@"add_sucess", @"添加成功")];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [HXYNotice addUpdateDeviceListPost];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD dismissInView:self.view];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)processQRCodeResult:(NSString *)result {
    if (result) {
        [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:NSLocalizedString(@"Processing", @"正在处理...")];
        [obtain stopRunning];
        [obtain playSoundName:@"SGQRCode.bundle/sound.caf"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD dismissInView:self.view];
            
            NSString *signature = @"";//result;
            NSString *productId = @"";//productId
            NSDictionary *param = [NSString jsonToObject:result];
            
            if (param) {
                signature = param[@"Signature"];
                [self bindDevice:signature];
            }
            else if ([result hasPrefix:@"http"]) {
                
                NSURL *url = [NSURL URLWithString:result];
                NSString *page = @"";
                
                if (url.query) {
                    NSArray *params = [url.query componentsSeparatedByString:@"&"];
                    
                    for (NSString *param in params) {
                        if ([param containsString:@"signature"]) {
                            signature = [[param componentsSeparatedByString:@"="] lastObject];
                        }
                        if ([param containsString:@"page"]) {
                            page = [[param componentsSeparatedByString:@"="] lastObject];
                        }
                        if ([param containsString:@"productId"]) {
                            productId =[[param componentsSeparatedByString:@"="] lastObject];
                        }
                    }
                    
                }
                if (signature.length) {
                    [self bindDevice:signature];
                } else {
                    if ([page isEqualToString:@"softap"]) {
                        [self.navigationController popViewControllerAnimated:YES];
                        [HXYNotice postChangeAddDeviceType:1];
                    } else if ([page isEqualToString:@"smartconfig"]) {
                        [self.navigationController popViewControllerAnimated:YES];
                        [HXYNotice postChangeAddDeviceType:0];
                    } else if ([page isEqualToString:@"adddevice"] && ![NSString isNullOrNilWithObject:productId]){ //设备批量生产的二维码扫描
                        [self getProductsConfig:productId];
                    }else {//未知page
                        [self bindDevice:signature];
                    }
                }
                
            }
            
        });
    }
}

#pragma mark - 配网请求流程
- (void)getProductsConfig:(NSString *)productId{
    [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":@[productId]} success:^(id responseObject) {
        
        NSArray *data = responseObject[@"Data"];
        if (data.count > 0) {
            NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
            self.configData = [[NSDictionary alloc]initWithDictionary:config];
            WCLog(@"AppGetProductsConfig config%@", config);
            NSArray *wifiConfTypeList = config[@"WifiConfTypeList"];
            if (wifiConfTypeList.count > 0) {
                NSString *configType = wifiConfTypeList.firstObject;
                if ([configType isEqualToString:@"softap"]) {
                    [self jumpConfigVC:NSLocalizedString(@"soft_ap", @"自助配网")];
                    return;
                }
            }
        }
        [self jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
        WCLog(@"AppGetProductsConfig responseObject%@", responseObject);
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [self jumpConfigVC:NSLocalizedString(@"smart_config", @"智能配网")];
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

- (void)setupQRCodeScan {
    WeakObj(self)
    SGQRCodeObtainConfigure *configure = [SGQRCodeObtainConfigure QRCodeObtainConfigure];
    configure.sampleBufferDelegate = YES;
    [obtain establishQRCodeObtainScanWithController:self configure:configure];
    [obtain setBlockWithQRCodeObtainScanResult:^(SGQRCodeObtain *obtain, NSString *result) {
        StrongObj(self)
        [selfstrong processQRCodeResult:result];
    }];
    [obtain setBlockWithQRCodeObtainScanBrightness:^(SGQRCodeObtain *obtain, CGFloat brightness) {
        StrongObj(self)
        if (brightness < - 1) {
            [selfstrong.view addSubview:selfstrong.flashlightBtn];
        } else {
            if (selfstrong.isSelectedFlashlightBtn == NO) {
                [selfstrong removeFlashlightBtn];
            }
        }
    }];
}

- (void)setupNavigationBar {
    self.navigationItem.title = NSLocalizedString(@"scan", @"扫一扫");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"photoalbum", @"相册") style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
}

- (void)rightBarButtonItenAction {
    
    [obtain establishAuthorizationQRCodeObtainAlbumWithController:nil];
    if (obtain.isPHAuthorization == YES) {
        [self.scanView removeTimer];
    }
    WeakObj(self)
    [obtain setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:^(SGQRCodeObtain *obtain) {
        StrongObj(self)
        [selfstrong.view addSubview:selfstrong.scanView];
    }];
    [obtain setBlockWithQRCodeObtainAlbumResult:^(SGQRCodeObtain *obtain, NSString *result) {
        StrongObj(self)
        [selfstrong processQRCodeResult:result];
    }];
}

- (SGQRCodeScanView *)scanView {
    if (!_scanView) {
        _scanView = [[SGQRCodeScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.9 * self.view.frame.size.height)];
    }
    return _scanView;
}
- (void)removeScanningView {
    [self.scanView removeTimer];
    [self.scanView removeFromSuperview];
    self.scanView = nil;
}

- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 0;
        CGFloat promptLabelY = 0.73 * self.view.frame.size.height;
        CGFloat promptLabelW = self.view.frame.size.width;
        CGFloat promptLabelH = 25;
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _promptLabel.text = NSLocalizedString(@"autoscan_QRcode", @"将二维码/条码放入框内, 即可自动扫描");
    }
    return _promptLabel;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.scanView.frame))];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _bottomView;
}

#pragma mark - - - 闪光灯按钮
- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        // 添加闪光灯按钮
        _flashlightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        CGFloat flashlightBtnW = 30;
        CGFloat flashlightBtnH = 30;
        CGFloat flashlightBtnX = 0.5 * (self.view.frame.size.width - flashlightBtnW);
        CGFloat flashlightBtnY = 0.55 * self.view.frame.size.height;
        _flashlightBtn.frame = CGRectMake(flashlightBtnX, flashlightBtnY, flashlightBtnW, flashlightBtnH);
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightOpenImage"] forState:(UIControlStateNormal)];
        [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"SGQRCodeFlashlightCloseImage"] forState:(UIControlStateSelected)];
        [_flashlightBtn addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashlightBtn;
}

- (void)flashlightBtn_action:(UIButton *)button {
    if (button.selected == NO) {
        [obtain openFlashlight];
        self.isSelectedFlashlightBtn = YES;
        button.selected = YES;
    } else {
        [self removeFlashlightBtn];
    }
}

- (void)removeFlashlightBtn {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->obtain closeFlashlight];
        self.isSelectedFlashlightBtn = NO;
        self.flashlightBtn.selected = NO;
        [self.flashlightBtn removeFromSuperview];
    });
}

@end
