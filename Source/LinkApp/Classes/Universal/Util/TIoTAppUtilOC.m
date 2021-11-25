//
//  TIoTAppUtil.m
//  LinkApp
//
//

#import "TIoTAppUtilOC.h"
#import "TIoTNewVersionTipView.h"
#import "NSString+Extension.h"
#import "TIoTMainVC.h"
#import "UIViewController+GetController.h"
#import "TIoTCoreUtil.h"
#import "UIDevice+Until.h"

@implementation TIoTAppUtilOC

+ (void)checkNewVersion {
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    appVersion = [NSString matchVersionNum:appVersion];
    if (appVersion.length) { //满足要求，必须是三位，x.x.x的形式  每位x的范围分别为1-99,0-99,0-99。
        NSDictionary *tmpDic = @{@"ClientVersion": appVersion, @"Channel":@(0), @"AppPlatform": @"ios"};
        [[TIoTRequestObject shared] postWithoutToken:AppGetLatestVersion Param:tmpDic success:^(id responseObject) {
            NSDictionary *versionInfo = responseObject[@"VersionInfo"];
            if (versionInfo) {
                NSString *theVersion = [versionInfo objectForKey:@"AppVersion"];
                NSInteger upgradeType = [[versionInfo objectForKey:@"UpgradeType"] integerValue];
                if (theVersion.length && [self isTheVersion:theVersion laterThanLocalVersion:appVersion] && upgradeType!= 2) {//upgradeType为2时是静默升级在home页不显示，在关于页面的版本一栏点击可显示
                    [self showNewVersionViewWithDict:versionInfo];
                }
            }
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }
    
}

+ (BOOL)isTheVersion:(NSString *)theVersion laterThanLocalVersion:(NSString *)localVersion {
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
        } else if (theIndex < localIndex) {
            return NO;
        }
    }
    return NO;
}

+ (void)showNewVersionViewWithDict:(NSDictionary *)versionInfo {
    TIoTNewVersionTipView *newVersionView = [[TIoTNewVersionTipView alloc] initWithVersionInfo:versionInfo];
    [TIoTAPPConfig.iot_window addSubview:newVersionView];
    [newVersionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(TIoTAPPConfig.iot_window);
    }];
}

+ (void)handleOpsenUrl:(NSString *)result {
    
    
    
    if ([result hasPrefix:@"http"]) {
        
        NSURL *url = [NSURL URLWithString:result];
        NSString *signature = @"";//result;
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
                
            }
            
        }
        if (signature.length) {
            [self bindDevice:signature];
        }
    }
}
    
    //绑定设备
+ (void)bindDevice:(NSString *)signature{
    
    NSString *roomId = [TIoTCoreUserManage shared].currentRoomId ?: @"";
    NSDictionary *param = @{@"FamilyId":[TIoTCoreUserManage shared].familyId,@"DeviceSignature":signature,@"RoomId":roomId};
        
    [[TIoTRequestObject shared] post:AppSecureAddDeviceInFamily Param:param success:^(id responseObject) {
            
        [HXYNotice addUpdateFamilyListPost];
            
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
    }];
}

// 判断是否登录
+ (BOOL)checkLogin {
    if ([[TIoTCoreUserManage shared].expireAt integerValue] <= [[NSString getNowTimeString] integerValue] && [TIoTCoreUserManage shared].accessToken.length > 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"warm_prompt", @"温馨提示") message:NSLocalizedString(@"login_timeout", @"登录已过期") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:NSLocalizedString(@"relogin", @"重新登录") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
            [[TIoTAppEnvironment shareEnvironment] loginOut];
            TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTMainVC alloc] init]];
            [UIViewController getCurrentViewController].view.window.rootViewController = nav;
        }];
        [alert addAction:alertA];
        [[UIViewController getCurrentViewController] presentViewController:alert animated:YES completion:nil];
        return YES;
    }
    return NO;
}

+ (NSString *)getLangParameter {
    NSString *langAndRegionStr = [[NSLocale currentLocale] localeIdentifier];
    
    NSString *regionStr = [[langAndRegionStr componentsSeparatedByString:@"_"] objectAtIndex:1];
    
    NSString *langStr = [[langAndRegionStr componentsSeparatedByString:@"_"] objectAtIndex:0];
    
    NSString *langValueString = [NSString stringWithFormat:@"%@-%@",langStr,regionStr];
    
    return langValueString?:@"";
}

@end
