//
//  QCRequestClient.m
//  QCApiClient
//
//

#import "TIoTCoreRequestClient.h"
#import "TIoTCoreRequestObject.h"

@implementation TIoTCoreRequestClient

+ (void)sendRequestWithBuild:(NSDictionary *)build success:(SuccessResponseHandler)success
failure:(FailureResponseHandler)failure
{
    BOOL useToken = [build[@"useToken"] boolValue];
    NSString *action = build[@"action"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:build[@"params"]];
    
    //接口中英文语言国际化返回判断参数
    NSString *langAndRegionStr = [[NSLocale currentLocale] localeIdentifier];
    
    NSString *regionStr = [[langAndRegionStr componentsSeparatedByString:@"_"] objectAtIndex:1];
    
    NSString *langStr = [[langAndRegionStr componentsSeparatedByString:@"_"] objectAtIndex:0];
    
    NSString *langValueString = [NSString stringWithFormat:@"%@-%@",langStr,regionStr];
    [params setValue:langValueString forKey:@"lang"];
    [params setValue:@"iOS" forKey:@"Agent"];
    
    if ([action isEqualToString:@"AppCosAuth"]) {
        
        [[TIoTCoreRequestObject shared] getSigForUpload:action Param:params success:^(id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(responseObject);
            });
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(reason,error,dic);
            });
        }];
        
        return;
    }
    
    if (useToken) {
        [[TIoTCoreRequestObject shared] post:action Param:params success:^(id responseObject) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(responseObject);
            });
            
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(reason,error,dic);
            });
        }];
    }
    else
    {
        [[TIoTCoreRequestObject shared] postWithoutToken:action Param:params success:^(id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(responseObject);
            });
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(reason,error,dic);
            });
        }];
    }
}

+ (void)sendVideoOrExploreRequestWithBuild:(NSDictionary *)build urlString:(NSString *)urlString success:(SuccessResponseHandler)success failure:(FailureResponseHandler)failure {
    
    NSString *action = build[@"action"]?:@"";
    NSDictionary *params = build[@"params"]?:@{};

    [[TIoTCoreRequestObject shared] videoOrExplorePost:action Param:params withUrlString:urlString success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            success(responseObject);
        });
        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(reason,error,dic);
            });
        }];
}

@end
