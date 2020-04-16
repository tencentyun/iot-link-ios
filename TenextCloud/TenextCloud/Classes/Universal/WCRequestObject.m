//
//  WCRequestObj.m
//  TenextCloud
//
//  Created by Wp on 2019/12/25.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCRequestObject.h"
#import "WCAppEnvironment.h"


#define kCode @"code"
#define kMsg @"msg"
#define kData @"data"

@implementation WCRequestObject

+ (WCRequestObject *)shared {
    
    static WCRequestObject *_xonet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _xonet = [[WCRequestObject alloc] init];
    });
    return _xonet;
}

- (void)post:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
    
    NSMutableDictionary *accessParam = [NSMutableDictionary dictionaryWithDictionary:param];
    [accessParam setValue:urlStr forKey:@"Action"];
    [accessParam setValue:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    [accessParam setValue:[WCUserManage shared].accessToken forKey:@"AccessToken"];
    
    WCLog(@"请求action==%@==%@",urlStr,[NSString objectToJson:accessParam]);
    
    NSURL *url = [NSURL URLWithString:[WCAppEnvironment shareEnvironment].baseUrlForLogined];
    
    WCLog(@"连接==%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:accessParam options:NSJSONWritingFragmentsAllowed error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        WCLog(@"收到action==%@==%@",urlStr,[[NSString alloc] initWithData:data encoding:4]);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *jsonerror = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
            if (jsonerror == nil) {
                if ([dic[kCode] integerValue] == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD dismissInView:[UIApplication sharedApplication].keyWindow];
                        success(dic[kData]);
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD showError:dic[kMsg] toView:[UIApplication sharedApplication].keyWindow];
                        failure(dic[kMsg],nil);
                    });
                    
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showError:@"json解析失败" toView:[UIApplication sharedApplication].keyWindow];
                    failure(nil,jsonerror);
                });
                
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:error.localizedDescription toView:[UIApplication sharedApplication].keyWindow];
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
    [accessParam setValue:[WCAppEnvironment shareEnvironment].appKey forKey:@"AppKey"];
    [accessParam setValue:@([[NSString getNowTimeString] integerValue]) forKey:@"Timestamp"];
    [accessParam setValue:@(arc4random()) forKey:@"Nonce"];
    [accessParam setValue:[WCAppEnvironment shareEnvironment].platform forKey:@"Platform"];
    
//    [accessParam setValue:[self getSignatureWithParam:accessParam] forKey:@"Signature"];
    
    WCLog(@"请求action==%@==%@",urlStr,[NSString objectToJson:accessParam]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[WCAppEnvironment shareEnvironment].baseUrl,urlStr]];
    
    WCLog(@"连接==%@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:accessParam options:NSJSONWritingFragmentsAllowed error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        WCLog(@"收到action==%@==%@",urlStr,[[NSString alloc] initWithData:data encoding:4]);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *jsonerror = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
            if (jsonerror == nil) {
                if ([dic[kCode] integerValue] == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD dismissInView:[UIApplication sharedApplication].keyWindow];
                        success(dic[kData]);
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD showError:dic[kMsg] toView:[UIApplication sharedApplication].keyWindow];
                        failure(dic[kMsg],nil);
                    });
                    
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showError:@"json解析失败" toView:[UIApplication sharedApplication].keyWindow];
                    failure(nil,jsonerror);
                });
                
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:error.localizedDescription toView:[UIApplication sharedApplication].keyWindow];
                failure(nil,error);
            });
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
    
    return [NSString HmacSha1:[WCAppEnvironment shareEnvironment].appSecret data:keyValue];
}




//上传图片
- (void)getSigForUpload:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure
{
    
    NSMutableDictionary *accessParam = [NSMutableDictionary dictionaryWithDictionary:param];
    [accessParam setValue:urlStr forKey:@"Action"];
    [accessParam setValue:[[NSUUID UUID] UUIDString] forKey:@"RequestId"];
    [accessParam setValue:[WCUserManage shared].accessToken forKey:@"AccessToken"];
    
    NSURL *url = [NSURL URLWithString:@"https://iot.cloud.tencent.com/api/studioapp/AppCosAuth"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:accessParam options:NSJSONWritingFragmentsAllowed error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        WCLog(@"收到action==%@==%@",urlStr,[[NSString alloc] initWithData:data encoding:4]);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSError *jsonerror = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
            if (jsonerror == nil) {
                if ([dic[kCode] integerValue] == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD dismissInView:[UIApplication sharedApplication].keyWindow];
                        success(dic[kData]);
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD showError:dic[kMsg] toView:[UIApplication sharedApplication].keyWindow];
                        failure(dic[kMsg],nil);
                    });
                    
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showError:@"json解析失败" toView:[UIApplication sharedApplication].keyWindow];
                    failure(nil,jsonerror);
                });
                
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:error.localizedDescription toView:[UIApplication sharedApplication].keyWindow];
                failure(nil,error);
            });
        }
    }];
    [task resume];
}

@end
