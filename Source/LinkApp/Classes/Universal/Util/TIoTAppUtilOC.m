//
//  TIoTAppUtil.m
//  LinkApp
//
//  Created by eagleychen on 2020/11/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAppUtilOC.h"
#import "TIoTNewVersionTipView.h"
#import "NSString+Extension.h"

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

@end
