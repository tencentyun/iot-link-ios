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
    
    NSMutableDictionary *accessParam = [NSMutableDictionary dictionaryWithDictionary:param];
    [accessParam setValue:urlStr forKey:@"Action"];
    [accessParam setValue:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    [accessParam setValue:[TIoTCoreUserManage shared].accessToken forKey:@"AccessToken"];
    
    QCLog(@"请求action==%@==%@",urlStr,[NSString objectToJson:accessParam]);
    
    NSURL *url = [NSURL URLWithString:[TIoTCoreAppEnvironment shareEnvironment].baseUrlForLogined];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    if (self.configH5CookieBlock != nil) {
        self.configH5CookieBlock(request);
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:accessParam options:NSJSONWritingFragmentsAllowed error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        QCLog(@"收到action==%@==%@",urlStr,[[NSString alloc] initWithData:data encoding:4]);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *jsonerror = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
            if (jsonerror == nil) {
                if ([dic[kCode] integerValue] == 0) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (self.tipsDismissBlock != nil) {
                            self.tipsDismissBlock();
                        }
                        success(dic[kData]);
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (self.tipsErrorShowBlock != nil) {
                            self.tipsErrorShowBlock(dic[kMsg]);
                        }
                        failure(dic[kMsg],nil);
                    });
                    
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.tipsErrorShowBlock != nil) {
                        self.tipsErrorShowBlock(@"json解析失败");
                    }
                   failure(nil,jsonerror);
                });
                
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.tipsErrorShowBlock != nil) {
                    self.tipsErrorShowBlock(error.localizedDescription);
                }
                failure(nil,error);
            });
            
        }
    }];
    [task resume];
}


- (void)postWithoutToken:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
    
    NSMutableDictionary *accessParam = [NSMutableDictionary dictionaryWithDictionary:param];
    [accessParam setValue:urlStr forKey:@"Action"];
    [accessParam setValue:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    [accessParam setValue:[TIoTCoreAppEnvironment shareEnvironment].appKey forKey:@"AppKey"];
    [accessParam setValue:@([[NSString getNowTimeString] integerValue]) forKey:@"Timestamp"];
    [accessParam setValue:@(arc4random()) forKey:@"Nonce"];
    [accessParam setValue:[TIoTCoreAppEnvironment shareEnvironment].platform forKey:@"Platform"];
    
//    [accessParam setValue:[self getSignatureWithParam:accessParam] forKey:@"Signature"];
    
    QCLog(@"请求action==%@==%@",urlStr,[NSString objectToJson:accessParam]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[TIoTCoreAppEnvironment shareEnvironment].baseUrl,urlStr]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:accessParam options:NSJSONWritingFragmentsAllowed error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        QCLog(@"收到action==%@==%@",urlStr,[[NSString alloc] initWithData:data encoding:4]);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *jsonerror = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
            if (jsonerror == nil) {
                if ([dic[kCode] integerValue] == 0) {
                    success(dic[kData]);
                }
                else
                {
                    failure(dic[kMsg],nil);
                }
            }
            else
            {
                failure(nil,jsonerror);
            }
        }
        else
        {
            failure(nil,error);
        }
    }];
    [task resume];
}


- (NSString *)getSignatureWithParam:(NSDictionary *)param
{
    NSStringCompareOptions comparisonOptions = NSLiteralSearch;
    NSArray *keys = [[param allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSRange range = NSMakeRange(0,((NSString *)obj1).length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    }];
//    NSArray *keys=  [[param allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    QCLog(@"%@",keys);
    
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




//上传图片
- (void)getSigForUpload:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
    
    NSMutableDictionary *accessParam = [NSMutableDictionary dictionaryWithDictionary:param];
    [accessParam setValue:urlStr forKey:@"Action"];
    [accessParam setValue:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    [accessParam setValue:[TIoTCoreUserManage shared].accessToken forKey:@"AccessToken"];
    
    NSURL *url = [NSURL URLWithString:@"https://iot.cloud.tencent.com/api/studioapp/AppCosAuth"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:accessParam options:NSJSONWritingFragmentsAllowed error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        QCLog(@"收到action==%@==%@",urlStr,[[NSString alloc] initWithData:data encoding:4]);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *jsonerror = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
            if (jsonerror == nil) {
                if ([dic[kCode] integerValue] == 0) {
                    success(dic[kData]);
                }
                else
                {
                    failure(dic[kMsg],nil);
                }
            }
            else
            {
                failure(nil,jsonerror);
            }
        }
        else
        {
            failure(nil,error);
        }
    }];
    [task resume];
}

@end
