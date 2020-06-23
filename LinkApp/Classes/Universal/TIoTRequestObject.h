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

@interface TIoTRequestObject : NSObject
+ (TIoTRequestObject *)shared;
- (void)post:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure;
- (void)postWithoutToken:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success failure:(FailureResponseBlock)failure;

/// 登录前，要通过相关用户接口换取 accesstoken 完成登录，调用url 为 ..../appapi，accesstoken 用于标识一个用户。当用户登录完毕后，使用 url 为 .../tokenapi 的相关 API 完成其他操作
/// @param urlStr AppGetToken
/// @param param 公共参数
/// @param success success 回调
/// @param failure failure 回调
- (void)postSignatureBeforeLoginWithoutToken:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
                                     failure:(FailureResponseBlock)failure;

- (void)getSigForUpload:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
                failure:(FailureResponseBlock)failure;
@end

