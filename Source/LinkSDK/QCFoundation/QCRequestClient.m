//
//  QCRequestClient.m
//  QCApiClient
//
//  Created by Wp on 2020/2/27.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "QCRequestClient.h"
#import "WCRequestObject.h"

@implementation QCRequestClient

+ (void)sendRequestWithBuild:(NSDictionary *)build success:(SuccessResponseHandler)success
failure:(FailureResponseHandler)failure
{
    BOOL useToken = [build[@"useToken"] boolValue];
    NSString *action = build[@"action"];
    NSDictionary *params = build[@"params"];
    
    if ([action isEqualToString:@"AppCosAuth"]) {
        
        [[WCRequestObject shared] getSigForUpload:action Param:params success:^(id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(responseObject);
            });
        } failure:^(NSString *reason, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(reason,error);
            });
        }];
        
        return;
    }
    
    if (useToken) {
        [[WCRequestObject shared] post:action Param:params success:^(id responseObject) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(responseObject);
            });
            
        } failure:^(NSString *reason, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(reason,error);
            });
        }];
    }
    else
    {
        [[WCRequestObject shared] postWithoutToken:action Param:params success:^(id responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(responseObject);
            });
        } failure:^(NSString *reason, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(reason,error);
            });
        }];
    }
}

@end
