//
//  WCRequestObj.m
//  TenextCloud
//
//

#import "TIoTRequestObject.h"
#import "TIoTAppEnvironment.h"
#import "TIoTAppConfig.h"
#import "TIoTNavigationController.h"
#import "TIoTMainVC.h"
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

- (void)get:(NSString *)urlString isNormalRequest:(BOOL)normal success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure {
    [[TIoTCoreRequestObject shared] getRequestURLString:urlString noH5Render:normal success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        failure(reason, error,nil);
    }];
}

- (void)post:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
    
    [TIoTCoreRequestObject shared].customEnvrionmentAppSecretStirng = [TIoTCoreAppEnvironment shareEnvironment].appKey;
    [TIoTCoreRequestObject shared].customEnvrionmenPlatform = [TIoTCoreAppEnvironment shareEnvironment].platform;
    
    [[TIoTCoreRequestObject shared]postRequestWithAction:urlStr url:nil isWithoutToken:NO param:param urlAndBodySetting:^NSURL *(NSMutableDictionary *accessParam, NSURL *requestUrl) {
        
        TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
        NSURL *url = nil;
        if ([TIoTAppConfig appTypeWithModel:model] == 0){
            //公版和开源
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?uin=%@",[TIoTCoreAppEnvironment shareEnvironment].studioBaseUrlForLogined,urlStr, TIoTAPPConfig.GlobalDebugUin]];
            [accessParam setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] forKey:@"AppID"];
            [accessParam setValue:@"iOS" forKey:@"Platform"];
            [accessParam setValue:@"iOS" forKey:@"Agent"];
//            NSNumber *timstamp = [NSNumber numberWithInteger:[[NSDate date]timeIntervalSince1970]];
//            [accessParam setValue:timstamp forKey:@"Timestamp"];
        }else {
            //OEM
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[TIoTCoreAppEnvironment shareEnvironment].oemTokenApi,urlStr]];
        }
        
        return url;
    } isShowHelpCenter:^NSMutableURLRequest *(NSMutableURLRequest *request) {
        TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
        if ([TIoTAppConfig appTypeWithModel:model] == 0){
            [request setValue:[NSString stringWithFormat:@"uin=%@",TIoTAPPConfig.GlobalDebugUin] forHTTPHeaderField:@"Cookie"];
        }
        return request;
    } success:^(id responseObject) {

        [MBProgressHUD dismissInView:[[UIApplication sharedApplication] delegate].window];
        success(responseObject);
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
        if (reason != nil) {
            [MBProgressHUD showError:reason toView:[[UIApplication sharedApplication] delegate].window];
            
            if (![dic isEqualToDictionary:@{}]) {
                [self judgeUserSignoutWithReturnToken:dic];
            }
            
            failure(reason, error, dic);
        }else {
            if ([urlStr isEqualToString:AppGetDeviceBindTokenState]) {
                
            } else {
                [MBProgressHUD showError:error.localizedDescription toView:[[UIApplication sharedApplication] delegate].window];
            }
            failure(reason, error,nil);
        }
        
    }];
    
}

//MARK: 重要
#pragma mark -  ***此处仅供参考, 需自建后台服务进行替换***

- (void)postWithoutToken:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
    
    [TIoTCoreRequestObject shared].customEnvrionmentAppSecretStirng = [TIoTCoreAppEnvironment shareEnvironment].appKey;
    [TIoTCoreRequestObject shared].customEnvrionmenPlatform = [TIoTCoreAppEnvironment shareEnvironment].platform;
    
    [[TIoTCoreRequestObject shared] postRequestWithAction:urlStr url:nil isWithoutToken:YES param:param urlAndBodySetting:^NSURL *(NSMutableDictionary *accessParam, NSURL *requestUrl) {
        TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
        NSURL *url = nil;
        
        if ([TIoTAppConfig appTypeWithModel:model] == 0){
            //公版和开源
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?uin=%@",[TIoTCoreAppEnvironment shareEnvironment].studioBaseUrl,urlStr, TIoTAPPConfig.GlobalDebugUin]];
            [accessParam setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] forKey:@"AppID"];
        }else {
//            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[TIoTCoreAppEnvironment shareEnvironment].oemAppApi,urlStr]];
            url = [NSURL URLWithString:[TIoTCoreAppEnvironment shareEnvironment].oemAppApi];
            if (![TIoTAppConfig isOriginAppkeyAndSecret:model]) {
                [accessParam setValue:[self getSignatureWithParam:accessParam] forKey:@"Signature"];
            }
        }
        return url;
    } isShowHelpCenter:^NSMutableURLRequest *(NSMutableURLRequest *request) {
        TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
        if ([TIoTAppConfig appTypeWithModel:model] == 0){
            [request setValue:[NSString stringWithFormat: @"uin=%@",TIoTAPPConfig.GlobalDebugUin] forHTTPHeaderField:@"Cookie"];
        }
        return request;
    } success:^(id responseObject) {
        
        [MBProgressHUD dismissInView:[[UIApplication sharedApplication] delegate].window];
        success(responseObject);
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
        if (reason != nil) {
            [MBProgressHUD showError:reason toView:[[UIApplication sharedApplication] delegate].window];
            if (![dic isEqualToDictionary:@{}]) {
                [self judgeUserSignoutWithReturnToken:dic];
            }
            failure(reason, error, dic);
        }else {
            [MBProgressHUD showError:error.localizedDescription toView:[[UIApplication sharedApplication] delegate].window];
            failure(reason, error,nil);
        }
        
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
    DDLogDebug(@"%@",keys);
    
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
    if ([NSString matchSinogram:[TIoTCoreAppEnvironment shareEnvironment].appSecret]) {
        return @"";
    }
    return [NSString HmacSha1:[TIoTCoreAppEnvironment shareEnvironment].appSecret data:keyValue];
}




//上传图片
- (void)getSigForUpload:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{

    [[TIoTCoreRequestObject shared] getSigForUpload:urlStr Param:param success:^(id responseObject) {
        [MBProgressHUD dismissInView:[[UIApplication sharedApplication] delegate].window];
        success(responseObject);
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
        if (reason != nil) {
            [MBProgressHUD showError:reason toView:[[UIApplication sharedApplication] delegate].window];
            if (![dic isEqualToDictionary:@{}]) {
                [self judgeUserSignoutWithReturnToken:dic];
            }
            failure(reason, error, dic);
        }else {
            [MBProgressHUD showError:error.localizedDescription toView:[[UIApplication sharedApplication] delegate].window];
            failure(reason, error,nil);
        }
        
    }];
    
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
    TIoTNavigationController *nav = [[TIoTNavigationController alloc] initWithRootViewController:[[TIoTMainVC alloc] init]];
    [UIViewController getCurrentViewController].view.window.rootViewController = nav;
}

@end
