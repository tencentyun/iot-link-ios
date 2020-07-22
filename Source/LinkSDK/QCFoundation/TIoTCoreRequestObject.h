//
//  WCRequestObj.h
//  TenextCloud
//
//  Created by Wp on 2019/12/25.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^FailureResponseBlock)(NSString *reason,NSError *error);
typedef void (^SuccessResponseBlock)(id responseObject);

typedef void(^ConfigModelH5CookieBlock)(NSMutableURLRequest *request);
typedef void(^TipDissmissBlock)(void);
typedef void(^TipShowBlock)(NSString *contentString);

@interface TIoTCoreRequestObject : NSObject
+ (TIoTCoreRequestObject *)shared;
- (void)post:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure;
- (void)postWithoutToken:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success failure:(FailureResponseBlock)failure;


- (void)getSigForUpload:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
                failure:(FailureResponseBlock)failure;

@property (nonatomic, copy) ConfigModelH5CookieBlock configH5CookieBlock;
@property (nonatomic, copy) TipDissmissBlock tipsDismissBlock;
@property (nonatomic, copy) TipShowBlock tipsErrorShowBlock;

@end

