//
//  WCAboutVC.m
//  TenextCloud
//
//  Created by Wp on 2020/3/2.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTAboutVC.h"
#import "TIoTWebVC.h"
#import <QuickLook/QLPreviewController.h>

#import "TIoTNewVersionTipView.h"

@interface TIoTAboutVC ()

@property (weak, nonatomic) IBOutlet UILabel *versionLab;

@end

@implementation TIoTAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"关于我们";
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [info objectForKey:@"CFBundleShortVersionString"];
    self.versionLab.numberOfLines = 2;
    self.versionLab.textAlignment = NSTextAlignmentCenter;
    self.versionLab.text = [NSString stringWithFormat:@"当前版本\nv%@",appVersion];
}


- (IBAction)privacyPolicy:(UITapGestureRecognizer *)sender {
    TIoTWebVC *vc = [TIoTWebVC new];
    vc.title = @"隐私政策";
    vc.urlPath = PrivacyProtocolURL;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)protocol:(UITapGestureRecognizer *)sender {
    
    TIoTWebVC *vc = [TIoTWebVC new];
    vc.title = @"用户协议";
    vc.urlPath = ServiceProtocolURl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)checkNewVersion:(UITapGestureRecognizer *)sender {
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *tmpDic = @{@"ClientVersion": appVersion, @"Channel":@(0), @"AppPlatform": @"ios"};
    [[TIoTRequestObject shared] postWithoutToken:AppGetLatestVersion Param:tmpDic success:^(id responseObject) {
        NSDictionary *versionInfo = responseObject[@"VersionInfo"];
        if (versionInfo) {
            [self showNewVersionViewWithDict:versionInfo];
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:@"您的应用为最新版本" toView:self.view];
    }];
}

- (void)showNewVersionViewWithDict:(NSDictionary *)versionInfo {
    TIoTNewVersionTipView *newVersionView = [[TIoTNewVersionTipView alloc] initWithVersionInfo:versionInfo];
    [[UIApplication sharedApplication].keyWindow addSubview:newVersionView];
    [newVersionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([UIApplication sharedApplication].keyWindow);
    }];
}


@end
