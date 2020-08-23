//
//  WCRequestObj.m
//  TenextCloud
//
//  Created by Wp on 2019/12/25.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTCoreRequestObject.h"
#import "TIoTCoreAppEnvironment.h"
#import "TIoTCoreUserManage.h"
#import "NSString+Extension.h"
#import "TIoTCoreQMacros.h"
#import "NSObject+additions.h"

#define kCode @"code"
#define kMsg @"msg"
#define kData @"data"

@implementation TIoTCoreRequestObject

+ (TIoTCoreRequestObject *)shared {
    
    static TIoTCoreRequestObject *_xonet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _xonet = [[TIoTCoreRequestObject alloc] init];
    });
    return _xonet;
}

- (void)post:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
    NSURL *url  = [NSURL URLWithString:[TIoTCoreAppEnvironment shareEnvironment].baseUrlForLogined];
        
    [self postRequestWithAction:urlStr url:url isWithoutToken:NO param:param urlAndBodySetting:nil isShowHelpCenter:nil success:success failure:failure];

}

//MARK: 重要
#pragma mark -  ***此处仅供参考, 需自建后台服务进行替换***

- (void)postWithoutToken:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[TIoTCoreAppEnvironment shareEnvironment].baseUrl,urlStr]];
    
    [self postRequestWithAction:urlStr url:url isWithoutToken:YES param:param urlAndBodySetting:nil isShowHelpCenter:nil success:success failure:failure];
}


//上传图片
- (void)getSigForUpload:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
    NSURL *url = [NSURL URLWithString:@"https://iot.cloud.tencent.com/api/studioapp/AppCosAuth"];
    
    [self postRequestWithAction:urlStr url:url isWithoutToken:NO param:param urlAndBodySetting:nil isShowHelpCenter:nil success:success failure:failure];
    
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
    WCLog(@"%@",keys);
    
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
    
    return [NSString HmacSha1:[TIoTCoreAppEnvironment shareEnvironment].appSecret data:keyValue];
    
}

- (void)postRequestWithAction:(NSString *)actionStr url:(NSURL *)url  isWithoutToken:(BOOL)withoutToken param:(NSDictionary *)baseAccessParam urlAndBodySetting:(UrlAndBodyParamCustomSettingBlock )urlAndBodyCustomSettingBlock isShowHelpCenter:(ConfigModelH5CookieBlock )configH5CookieBlock success:(SuccessResponseBlock)success
                      failure:(FailureResponseBlock)failure {
    
    NSMutableDictionary *accessParam = nil;
    if (withoutToken == YES) {
        accessParam = [NSMutableDictionary dictionaryWithDictionary:baseAccessParam];
        [accessParam setValue:actionStr forKey:@"Action"];
        [accessParam setValue:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
        [accessParam setValue:self.customEnvrionmentAppSecretStirng ? self.customEnvrionmentAppSecretStirng : [TIoTCoreAppEnvironment shareEnvironment].appKey forKey:@"AppKey"];
        [accessParam setValue:@([[NSString getNowTimeString] integerValue]) forKey:@"Timestamp"];
        [accessParam setValue:@(arc4random()) forKey:@"Nonce"];
        [accessParam setValue:self.customEnvrionmenPlatform ? self.customEnvrionmenPlatform : [TIoTCoreAppEnvironment shareEnvironment].platform forKey:@"Platform"];
        
    }else {
        accessParam = [NSMutableDictionary dictionaryWithDictionary:baseAccessParam];
        [accessParam setValue:actionStr forKey:@"Action"];
        [accessParam setValue:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
        [accessParam setValue:[TIoTCoreUserManage shared].accessToken forKey:@"AccessToken"];
        
    }
    
    if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].userRegionId]) {
        [accessParam setValue:[TIoTCoreUserManage shared].userRegionId forKey:@"RegionId"];
    }
    
    NSURL *urlString = nil;
    
    if (urlAndBodyCustomSettingBlock != nil) {
        urlString = urlAndBodyCustomSettingBlock(accessParam, nil);
    }else {
        urlString = url;
    }
    
    WCLog(@"请求action==%@==%@",actionStr,[NSString objectToJson:accessParam]);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlString cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    if (configH5CookieBlock != nil) {
        request =  configH5CookieBlock(request);
    }
    
    if ([accessParam.allKeys containsObject:@"Keys"]) {
        [request setValue:@"vscode-restclient" forHTTPHeaderField:@"user-agent"];
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:accessParam options:NSJSONWritingFragmentsAllowed error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        WCLog(@"收到action==%@==%@",urlString,[[NSString alloc] initWithData:data encoding:4]);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *jsonerror = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
            if (jsonerror == nil) {
                if ([dic[kCode] integerValue] == 0) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(dic[kData]);
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failure(dic[kMsg],nil,dic);
                    });
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(nil,jsonerror,@{});
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(nil,error,@{});
            });
        }
    }];
    [task resume];
}

- (void)getRequestURLString:(NSString *)requestString success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure {
    
    NSURL *urlString = [NSURL URLWithString:requestString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlString cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        WCLog(@"收到action==%@==%@",urlString,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *jsonerror = nil;

            if (jsonerror == nil) {
                
                if (jsonString != nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *responseString = (NSString *)jsonString;
                        NSMutableString *resultSubString = [[NSMutableString alloc]initWithString:[NSString interceptingString:responseString withFrom:@"[" end:@"]"]];
                        [resultSubString insertString:@"[" atIndex:0];
                        NSDictionary *regionListDic = [NSJSONSerialization JSONObjectWithData:[resultSubString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        success(regionListDic);
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failure(jsonString,nil,@{});
                    });
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(nil,jsonerror,@{});
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(nil,error,@{});
            });
        }
    }];
    [task resume];
}

@end
