//
//  TIoTVideoVC.m
//  LinkSDKDemo
//
//

#import "TIoTVideoVC.h"
#import "TIoTVideoConfigNetVC.h"
#import "TIoTPlayConfigVC.h"
#import "TIoTPlayListVC.h"
#import "TIoTCoreXP2PBridge.h"
#import "TIoTPlayConfigVC.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTVideoVC ()
//@property (weak, nonatomic) IBOutlet UILabel *versionLB;
@end

@implementation TIoTVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    NSString *appVersion = [TIoTCoreXP2PBridge getSDKVersion];
//    _versionLB.text = [NSString stringWithFormat:@"v%@",appVersion];
    
    [self initVideoUI];
}
//- (IBAction)jumpDistributeNet:(id)sender {
//    TIoTVideoConfigNetVC *configNetVC = [[TIoTVideoConfigNetVC alloc]init];
//    [self.navigationController pushViewController:configNetVC animated:YES];
//
//}
//- (IBAction)jumpPlaying:(id)sender {
//    TIoTPlayConfigVC *playListVC = [[TIoTPlayConfigVC alloc]init];
//    [self.navigationController pushViewController:playListVC animated:YES];
//}

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
}

- (void)jumpPlaying {
    TIoTPlayConfigVC *playListVC = [[TIoTPlayConfigVC alloc]init];
    [self.navigationController pushViewController:playListVC animated:YES];
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
