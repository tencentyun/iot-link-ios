//
//  QCRequestClient.h
//  QCApiClient
//
//  Created by Wp on 2020/2/27.
//  Copyright © 2020 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^FailureResponseHandler)(NSString *reason,NSError *error);
typedef void (^SuccessResponseHandler)(id responseObject);

@interface QCRequestClient : NSObject

+ (void)sendRequestWithBuild:(NSDictionary *)build success:(SuccessResponseHandler)success
failure:(FailureResponseHandler)failure;

@end

NS_ASSUME_NONNULL_END
