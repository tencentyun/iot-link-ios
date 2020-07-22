//
//  WCRequestObj.m
//  TenextCloud
//
//  Created by Wp on 2019/12/25.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTRequestObject.h"
#import "TIoTAppEnvironment.h"
#import "TIoTAppConfig.h"
#import "TIoTNavigationController.h"
#import "TIoTLoginVC.h"
#import "UIViewController+GetController.h"

#import "TIoTCoreRequestObject.h"

#define kCode @"code"
#define kMsg @"msg"
#define kData @"data"

NSString  * const kInvalidParameterValueInvalidAccessToken = @"InvalidParameterValue.InvalidAccessToken";

@implementation TIoTRequestObject

+ (TIoTRequestObject *)shared {
    
    static TIoTRequestObject *_xonet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _xonet = [[TIoTRequestObject alloc] init];
    });
    return _xonet;
}

- (void)post:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
    
    [TIoTCoreRequestObject shared].urlCreateBlock = ^NSURL *{
        NSURL *url = [NSURL URLWithString:[TIoTAppEnvironment shareEnvironment].baseUrlForLogined];
        return url;
    };

    [TIoTCoreRequestObject shared].configH5CookieBlock = ^(NSMutableURLRequest *request) {
        TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
            if ([TIoTAppConfig appTypeWithModel:model] == 0){
        #ifdef DEBUG
                [request setValue:@"uin=help_center_h5_api" forHTTPHeaderField:@"Cookie"];
        #endif
            }
        return request;
    };

    [self invokeResponseBlock];

    [[TIoTCoreRequestObject shared] post:urlStr Param:param success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSString *reason, NSError *error) {
        failure(reason,error);
    }];
    
}

//MARK: 重要
#pragma mark -  ***此处仅供参考, 需自建后台服务进行替换***

- (void)postWithoutToken:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
    
    [TIoTCoreRequestObject shared].customEnvrionmentAppSecretStirng = [TIoTAppEnvironment shareEnvironment].appKey;
    [TIoTCoreRequestObject shared].customEnvrionmenPlatform = [TIoTAppEnvironment shareEnvironment].platform;

    [TIoTCoreRequestObject shared].urlAndBodyCustomSettingBlock = ^(NSMutableDictionary *accessParam, NSURL *requestUrl) {
        TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
            NSURL *url = nil;

            if ([TIoTAppConfig appTypeWithModel:model] == 0){
                //公版
        #ifdef DEBUG
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?uin=testReleaseID",[TIoTAppEnvironment shareEnvironment].baseUrl,urlStr]];
        #else
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[TIoTAppEnvironment shareEnvironment].baseUrl,urlStr]];
        #endif
                [accessParam setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] forKey:@"AppID"];
            }else {
                //开源
        #ifdef DEBUG
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?uin=testID",[TIoTAppEnvironment shareEnvironment].signatureBaseUrlBeforeLogined]];
        #else
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[TIoTAppEnvironment shareEnvironment].signatureBaseUrlBeforeLogined]];
        #endif

                if (![TIoTAppConfig isOriginAppkeyAndSecret:model]) {
                    [accessParam setValue:[self getSignatureWithParam:accessParam] forKey:@"Signature"];
                }
            }
        return url;
    };

    [TIoTCoreRequestObject shared].configH5CookieBlock = ^(NSMutableURLRequest *request) {
        TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
            if ([TIoTAppConfig appTypeWithModel:model] == 0){
        #ifdef DEBUG
                [request setValue:@"uin=help_center_h5_api" forHTTPHeaderField:@"Cookie"];
        #endif
            }
        return request;
    };

    [self invokeResponseBlock];

    [[TIoTCoreRequestObject shared] postWithoutToken:urlStr Param:param success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSString *reason, NSError *error) {
        failure(reason,error);
    }];

}


//MARK: 重要
#pragma mark -  ***签字函数请务必在服务端实现，此处仅为演示，如有泄露概不负责***

- (NSString *)getSignatureWithParam:(NSDictionary *)param
{
    NSStringCompareOptions comparisonOptions = NSLiteralSearch;
    NSArray *keys = [[param allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSRange range = NSMakeRange(0,((NSString *)obj1).length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    }];
//    NSArray *keys=  [[param allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSLog(@"%@",keys);
    
    NSMutableString *keyValue = [NSMutableString string];
    for (int i = 0; i < keys.count; i ++) {
        NSString *key = keys[i];
        if (i == 0) {
            [keyValue appendFormat:@"%@=%@",key,param[key]];
        }
        else
        {
            [keyValue appendFormat:@"&%@=%@",key,param[key]];
        }
    }
    if ([NSString matchSinogram:[TIoTAppEnvironment shareEnvironment].appSecret]) {
        return @"";
    }
    return [NSString HmacSha1:[TIoTAppEnvironment shareEnvironment].appSecret data:keyValue];
}




//上传图片
- (void)getSigForUpload:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
 
    [self invokeResponseBlock];

    [[TIoTCoreRequestObject shared] getSigForUpload:urlStr Param:param success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSString *reason, NSError *error) {
        failure(reason, error);
    }];
    
}

- (void)invokeResponseBlock {
    [TIoTCoreRequestObject shared].tipsDismissBlock = ^{
        [MBProgressHUD dismissInView:[UIApplication sharedApplication].keyWindow];
    };
    
    [TIoTCoreRequestObject shared].tipsErrorShowBlock = ^(NSString *errorTipsString, NSDictionary *resposeDic) {
        [MBProgressHUD showError:errorTipsString toView:[UIApplication sharedApplication].keyWindow];
        [self judgeUserSignoutWithReturnToken:resposeDic];
    };
    
    [TIoTCoreRequestObject shared].tipsNetWorkErrorBlock = ^(NSString *localizedDescription) {
        [MBProgressHUD showError:localizedDescription toView:[UIApplication sharedApplication].keyWindow];
    };
}

/// 根据token code 判断是否退出登录
- (void)judgeUserSignoutWithReturnToken:(NSDictionary *)descriptionDic {
                                
    if ([descriptionDic[kCode] isEqual:@(-1000)]) {
        if (descriptionDic[kData] != nil) {
            if (descriptionDic[kData][@"Error"] != nil) {
                NSString *errorMsg = descriptionDic[kData][@"Error"][@"Code"];
                if ([errorMsg isEqualToString:kInvalidParameterValueInvalidAccessToken]) {
                    [self logout];
                }
            }
        }
    }
    
}

/// token过期，强制用户退出到登录页面
- (void)logout {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTAppEnvironment shareEnvironment] loginOut];
    TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTLoginVC alloc] init]];
    [UIViewController getCurrentViewController].view.window.rootViewController = nav;
}

@end
