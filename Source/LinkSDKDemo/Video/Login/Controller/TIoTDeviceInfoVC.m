//
//  TIoTAreaNetworkConfigVC.m
//  LinkSDKDemo

#import "TIoTDeviceInfoVC.h"
#import "TIoTDemoPreviewDeviceVC.h"
#import "TIoTAreaNetworkDeviceCell.h"
#import "TIoTLocalNetDetch.h"
#import "TIoTCoreAppEnvironment.h"
#import "TIoTCoreUserManage.h"
#import "NSString+Extension.h"
#import "UIImage+TIoTDemoExtension.h"

@interface TIoTDeviceInfoVC ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *productID;
@property (nonatomic, strong) UITextField *devicenname;
@property (nonatomic, strong) UITextField *xp2pinfo;
@end

@implementation TIoTDeviceInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    [self setupNavBarStyleWithNormal:NO];
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *barApp = [[UINavigationBarAppearance alloc] init];
        [barApp configureWithOpaqueBackground];
        barApp.backgroundColor = [UIColor whiteColor];
        barApp.shadowColor = [UIColor clearColor];
        barApp.shadowImage = [UIImage new];
        self.navigationController.navigationBar.standardAppearance = barApp;
        self.navigationController.navigationBar.scrollEdgeAppearance = barApp;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavBarStyleWithNormal:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setupNavBarStyleWithNormal:YES];
}

- (void)setupNavBarStyleWithNormal:(BOOL)isNormal {
    
    if (isNormal) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage getGradientImageWithColors:@[[UIColor colorWithHexString:@"#ffffff"],[UIColor colorWithHexString:@"#ffffff"]] imgSize:CGSizeMake(kScreenWidth, 44)] forBarMetrics:UIBarMetricsDefault];
    }else {
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#FFFFFF"],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:17]}];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage getGradientImageWithColors:@[[UIColor colorWithHexString:@"#3D8BFF"],[UIColor colorWithHexString:@"#1242FF"]] imgSize:CGSizeMake(kScreenWidth, 44)] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }
    
}
- (void)dealloc {
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"IoT Video (局域网)";
    
    CGFloat kWidthPadding = 16;
    CGFloat kItemHeight = 56;
    CGFloat kAPIBtnWidthHeight = 24;
    CGFloat kInputItemLeftPadding = 150;
    
    //第一行
    UILabel *productIDLabel = [[UILabel alloc]init];
    [productIDLabel setLabelFormateTitle:@"Product ID" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self.view addSubview:productIDLabel];
    [productIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64).offset(20);
        }
        make.left.equalTo(self.view.mas_left).offset(kWidthPadding);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    self.productID = [[UITextField alloc]init];
    self.productID.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
    self.productID.returnKeyType = UIReturnKeyDone;
    self.productID.placeholder = @"请输入Product ID";
    self.productID.delegate = self;
    self.productID.textAlignment = NSTextAlignmentLeft;
    self.productID.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.productID];
    [self.productID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kInputItemLeftPadding);
        make.centerY.equalTo(productIDLabel);
        make.height.equalTo(productIDLabel);
        make.right.equalTo(self.view.mas_right).offset(-kWidthPadding - kAPIBtnWidthHeight);
    }];
    
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [UIColor colorWithHexString:kVideoDemoPlaceColor];
    [self.view addSubview:line2];
    [line2  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kWidthPadding);
        make.right.equalTo(self.view);
        make.top.equalTo(productIDLabel.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    //第二行
    UILabel *clientTokenLabel = [[UILabel alloc]init];
    [clientTokenLabel setLabelFormateTitle:@"Device Name" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self.view addSubview:clientTokenLabel];
    [clientTokenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kWidthPadding);
        make.top.equalTo(line2.mas_bottom);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    self.devicenname = [[UITextField alloc]init];
    self.devicenname.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
    self.devicenname.placeholder = @"请输入Device Name";
    self.devicenname.delegate = self;
//    self.clientToken.secureTextEntry = YES;
    self.devicenname.textAlignment = NSTextAlignmentLeft;
    self.devicenname.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.devicenname];
    [self.devicenname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kInputItemLeftPadding);
        make.centerY.equalTo(clientTokenLabel);
        make.height.equalTo(clientTokenLabel);
        make.right.equalTo(self.view.mas_right).offset(-kWidthPadding);
    }];
    
    UIView *line3 = [[UIView alloc]init];
    line3.backgroundColor = [UIColor colorWithHexString:kVideoDemoPlaceColor];
    [self.view addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(clientTokenLabel.mas_bottom);
        make.height.mas_equalTo(1);
        make.left.right.equalTo(line2);
    }];
    
    //第三行
    UILabel *p2pinfoLabel = [[UILabel alloc]init];
    [p2pinfoLabel setLabelFormateTitle:@"XP2P Info" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self.view addSubview:p2pinfoLabel];
    [p2pinfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kWidthPadding);
        make.top.equalTo(line3.mas_bottom);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    self.xp2pinfo = [[UITextField alloc]init];
    self.xp2pinfo.textColor = [UIColor colorWithHexString:@"#7F7F7F"];
    self.xp2pinfo.placeholder = @"请输入XP2P Info";
    self.xp2pinfo.delegate = self;
//    self.clientToken.secureTextEntry = YES;
    self.xp2pinfo.textAlignment = NSTextAlignmentLeft;
    self.xp2pinfo.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:self.xp2pinfo];
    [self.xp2pinfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kInputItemLeftPadding);
        make.centerY.equalTo(p2pinfoLabel);
        make.height.equalTo(p2pinfoLabel);
        make.right.equalTo(self.view.mas_right).offset(-kWidthPadding);
    }];
    
    UIView *line4 = [[UIView alloc]init];
    line4.backgroundColor = [UIColor colorWithHexString:kVideoDemoPlaceColor];
    [self.view addSubview:line4];
    [line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(p2pinfoLabel.mas_bottom);
        make.height.mas_equalTo(1);
        make.left.right.equalTo(line2);
    }];
    
    UIButton *detectDeviceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    detectDeviceBtn.backgroundColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    [detectDeviceBtn setButtonFormateWithTitlt:@"连接设备" titleColorHexString:@"#FFFFFF" font:[UIFont wcPfRegularFontOfSize:17]];
    [detectDeviceBtn addTarget:self action:@selector(detectEquipment) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:detectDeviceBtn];
    [detectDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kWidthPadding);
        make.right.equalTo(self.view.mas_right).offset(-kWidthPadding);
        make.top.equalTo(line4.mas_bottom).offset(30);
        make.height.mas_equalTo(45);
    }];
    
    [self judgeAutoFillInputInfo];
}

- (void)judgeAutoFillInputInfo {
    
    self.productID.text = [TIoTCoreUserManage shared].demoAreaNetProductID;
    self.devicenname.text =  [TIoTCoreUserManage shared].demoAreaNetClientToken;
}

- (void)saveInputInfo {
    
    [TIoTCoreUserManage shared].demoAreaNetProductID = self.productID.text;
    [TIoTCoreUserManage shared].demoAreaNetClientToken = self.devicenname.text;
}

///MARK: 探测设备
- (void)detectEquipment {
    [self hideKeyBoard];
    [self saveInputInfo];
    
//    self.productID.text = @"";
//    self.devicenname.text = @"";
//    self.xp2pinfo.text = @"";
    
    TIoTDemoPreviewDeviceVC *previewDeviceVC = [[TIoTDemoPreviewDeviceVC alloc]init];
    
    TIoTExploreOrVideoDeviceModel *model = [TIoTExploreOrVideoDeviceModel new]; model.DeviceName = self.devicenname.text;
    TIoTCoreAppEnvironment *env = [TIoTCoreAppEnvironment shareEnvironment];
    env.cloudProductId = self.productID.text;
    previewDeviceVC.selectedModel = model;
    previewDeviceVC.mXp2pInfo = self.xp2pinfo.text;
    previewDeviceVC.isNVR = NO;
    [self.navigationController pushViewController:previewDeviceVC animated:YES];
}



#pragma mark - UITextField delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self hideKeyBoard];
    return YES;
}

- (void)hideKeyBoard {
    [self.productID resignFirstResponder];
    [self.devicenname resignFirstResponder];
    [self.xp2pinfo resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideKeyBoard];
    return YES;
}

@end
