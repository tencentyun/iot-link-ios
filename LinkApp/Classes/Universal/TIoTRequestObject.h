//
//  WCRequestObj.h
//  TenextCloud
//
//  Created by Wp on 2019/12/25.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^FailureResponseBlock)(NSString *reason,NSError *error,NSDictionary *dic);
typedef void (^SuccessResponseBlock)(id responseObject);

@interface TIoTRequestObject : NSObject
+ (TIoTRequestObject *)shared;
- (void)post:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure;
- (void)postWithoutToken:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success failure:(FailureResponseBlock)failure;

- (void)getSigForUpload:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
                failure:(FailureResponseBlock)failure;

- (void)getAccessTokenForWeiXin:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure;

@end

