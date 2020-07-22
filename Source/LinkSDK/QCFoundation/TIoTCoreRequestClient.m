//
//  QCRequestClient.m
//  QCApiClient
//
//  Created by Wp on 2020/2/27.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "TIoTCoreRequestClient.h"
#import "TIoTCoreRequestObject.h"

@implementation TIoTCoreRequestClient

+ (void)sendRequestWithBuild:(NSDictionary *)build success:(SuccessResponseHandler)success
failure:(FailureResponseHandler)failure
{
    BOOL useToken = [build[@"useToken"] boolValue];
    NSString *action = build[@"action"];
    NSDictionary *params = build[@"params"];
    
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

@end
