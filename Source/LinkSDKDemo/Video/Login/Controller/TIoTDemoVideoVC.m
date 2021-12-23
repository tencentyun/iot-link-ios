//
//  TIoTDemoVideoVC.m
//  LinkSDKDemo
//

#import "TIoTDemoVideoVC.h"
#import "TIoTDemoPlayConfigVC.h"
#import "TIoTCoreXP2PBridge.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTAreaNetworkConfigVC.h"
@interface TIoTDemoVideoVC ()

@end

@implementation TIoTDemoVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initVideoUI];
    
    NSString *appVersion = [TIoTCoreXP2PBridge getSDKVersion];
    UILabel *versionLB = [[UILabel alloc]init];
    versionLB.text = [NSString stringWithFormat:@"%@",appVersion];
    [self.view addSubview:versionLB];
    [versionLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-16);
        make.left.equalTo(self.view).offset(16);
    }];
    
}

- (void)initVideoUI {
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    CGFloat kTopPadding = 90;
    CGFloat kLogoWidthOrHeight = 128;
    CGFloat kWidthPadding = 30;
    
    UIImageView *videoLogo = [[UIImageView alloc]init];
    videoLogo.image = [UIImage imageNamed:@"videoLoginLogo"];
    [self.view addSubview:videoLogo];
    [videoLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kTopPadding);
        }else {
            make.top.equalTo(self.view.mas_top).offset(64+kTopPadding);
        }
        make.width.height.mas_equalTo(kLogoWidthOrHeight);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UILabel *videoTitile = [[UILabel alloc]init];
    [videoTitile setLabelFormateTitle:@"IoT Video" font:[UIFont wcPfMediumFontOfSize:25] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:videoTitile];
    [videoTitile mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(videoLogo.mas_bottom).offset(12);
        make.left.right.equalTo(self.view);
    }];
    
    UILabel *videoSubtitle = [[UILabel alloc]init];
    [videoSubtitle setLabelFormateTitle:@"欢迎使用腾讯云 IoT Video" font:[UIFont wcPfRegularFontOfSize:20] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentCenter];
    videoSubtitle.alpha = 0.5l;
    [self.view addSubview:videoSubtitle];
    [videoSubtitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(videoTitile.mas_bottom).offset(16);
        make.left.right.equalTo(self.view);
    }];
    
    
    UIButton *consumerVersionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [consumerVersionBtn setButtonFormateWithTitlt:@"IoT Video（消费版）" titleColorHexString:kVideoDemoMainThemeColor font:[UIFont wcPfRegularFontOfSize:17]];
    consumerVersionBtn.layer.borderColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor].CGColor;
    consumerVersionBtn.layer.borderWidth = 1;
    [consumerVersionBtn addTarget:self action:@selector(jumpPlaying) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:consumerVersionBtn];
    [consumerVersionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(videoSubtitle.mas_bottom).offset(68);
        make.left.equalTo(self.view.mas_left).offset(kWidthPadding);
        make.right.equalTo(self.view.mas_right).offset(-kWidthPadding);
    }];
    
    UIButton *industryVersionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [industryVersionBtn setButtonFormateWithTitlt:@"IoT Video（行业版）" titleColorHexString:kVideoDemoMainThemeColor font:[UIFont wcPfRegularFontOfSize:17]];
    industryVersionBtn.layer.borderColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor].CGColor;
    industryVersionBtn.layer.borderWidth = 1;
    [self.view addSubview:industryVersionBtn];
    [industryVersionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(consumerVersionBtn);
        make.top.equalTo(consumerVersionBtn.mas_bottom).offset(20);
    }];
    
    UIButton *localAreaNetworkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [localAreaNetworkBtn setButtonFormateWithTitlt:@"IoT Video（局域网）" titleColorHexString:kVideoDemoMainThemeColor font:[UIFont wcPfRegularFontOfSize:17]];
    localAreaNetworkBtn.layer.borderColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor].CGColor;
    localAreaNetworkBtn.layer.borderWidth = 1;
    [localAreaNetworkBtn addTarget:self action:@selector(jumpLocalAreaNetwork) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:localAreaNetworkBtn];
    [localAreaNetworkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(consumerVersionBtn);
        make.top.equalTo(industryVersionBtn.mas_bottom).offset(20);
    }];
}

- (void)jumpPlaying {
    TIoTDemoPlayConfigVC *demoPlayListVC = [[TIoTDemoPlayConfigVC alloc]init];
    [self.navigationController pushViewController:demoPlayListVC animated:YES];
}

- (void)jumpLocalAreaNetwork {
    TIoTAreaNetworkConfigVC *areaNetVC = [[TIoTAreaNetworkConfigVC alloc]init];
    [self.navigationController pushViewController:areaNetVC animated:YES];
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
