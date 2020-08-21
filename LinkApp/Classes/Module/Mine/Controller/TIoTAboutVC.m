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

@property (nonatomic, assign) BOOL showLastestVerion;

@property (nonatomic, strong) NSDictionary *versionInfo;

@end

@implementation TIoTAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.showLastestVerion = NO;
    self.title = @"关于我们";
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [info objectForKey:@"CFBundleShortVersionString"];
    self.versionLab.numberOfLines = 2;
    self.versionLab.textAlignment = NSTextAlignmentCenter;
    self.versionLab.text = [NSString stringWithFormat:@"v%@",appVersion];
    [self checkNewVersion];
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
    
    if (self.showLastestVerion && self.versionInfo) {
        [self showNewVersionViewWithDict:self.versionInfo];
    } else {
        [MBProgressHUD showError:@"您的应用为最新版本" toView:self.view];
    }
}

- (void)showNewVersionViewWithDict:(NSDictionary *)versionInfo {
    TIoTNewVersionTipView *newVersionView = [[TIoTNewVersionTipView alloc] initWithVersionInfo:versionInfo];
    [[UIApplication sharedApplication].keyWindow addSubview:newVersionView];
    [newVersionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([UIApplication sharedApplication].keyWindow);
    }];
}

- (void)checkNewVersion {
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
#warning TODU: 持续集成的包master+git形式没有x.x.x的版本号 为了方便产品体验 手动维护版本号 2.1.0
    if ([appVersion containsString:@"master"]) {
        [self getLatestVersionRequestWithVersion:@"2.1.0"];
    } else {
        appVersion = [NSString matchVersionNum:appVersion];
        if (appVersion.length) { //满足要求，必须是三位，x.x.x的形式  每位x的范围分别为1-99,0-99,0-99。
            [self getLatestVersionRequestWithVersion:appVersion];
        }
    }
}
    
- (void)getLatestVersionRequestWithVersion:(NSString *)version {
    NSDictionary *tmpDic = @{@"ClientVersion": version, @"Channel":@(0), @"AppPlatform": @"ios"};
    [[TIoTRequestObject shared] postWithoutToken:AppGetLatestVersion Param:tmpDic success:^(id responseObject) {
        NSDictionary *versionInfo = responseObject[@"VersionInfo"];
        if (versionInfo) {
            self.versionInfo = versionInfo;
            NSString *theVersion = [versionInfo objectForKey:@"AppVersion"];
            if (theVersion.length && [self isTheVersion:theVersion laterThanLocalVersion:version]) {
                self.showLastestVerion = YES;
                self.versionLab.text = [NSString stringWithFormat:@"当前版本\nv%@",version];
            }
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (BOOL)isTheVersion:(NSString *)theVersion laterThanLocalVersion:(NSString *)localVersion {
    NSArray *localArr = [localVersion componentsSeparatedByString:@"."];
    NSArray *theArr = [theVersion componentsSeparatedByString:@"."];
    for (int i = 0; i<localArr.count; i++) {
        NSInteger localIndex = [localArr[i] integerValue];
        NSInteger theIndex;
        if (i < theArr.count) {
            theIndex = [theArr[i] integerValue];
        } else {
            theIndex = 0;
        }
        if (theIndex > localIndex) {
            return YES;
        }
    }
    return NO;
}


@end
