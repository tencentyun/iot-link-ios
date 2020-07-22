//
//  WCRequestObj.h
//  TenextCloud
//
//  Created by Wp on 2019/12/25.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 请求失败响应
 */
typedef void (^FailureResponseBlock)(NSString *reason,NSError *error);

/**
 请求成功响应
 */
typedef void (^SuccessResponseBlock)(id responseObject);

/**
 创建网络请求URL
 */
typedef NSURL *(^UrlRequestCreateBlock)(void);

/**
 H5传参添加到cookie
 */
typedef NSMutableURLRequest *(^ConfigModelH5CookieBlock)(NSMutableURLRequest *request);

/**
 提示隐藏处理
 */
typedef void(^TipDissmissBlock)(void);

/**
 错误提示处理
 */
typedef void(^TipShowBlock)(NSString *errorTipsString, NSDictionary *resposeDic);

/**
 请求返回失败
 */
typedef void(^TipsNetWorkBlock)(NSString *localizedDescription);

/**
  url和请求body设置
 */
typedef NSURL *(^UrlAndBodyParamCustomSettingBlock)(NSMutableDictionary *accessParam,NSURL *requestUrl);


@interface TIoTCoreRequestObject : NSObject
+ (TIoTCoreRequestObject *)shared;
- (void)post:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
failure:(FailureResponseBlock)failure;
- (void)postWithoutToken:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success failure:(FailureResponseBlock)failure;


- (void)getSigForUpload:(NSString *)urlStr Param:(NSDictionary *)param success:(SuccessResponseBlock)success
                failure:(FailureResponseBlock)failure;

@property (nonatomic, copy) ConfigModelH5CookieBlock configH5CookieBlock;
@property (nonatomic, copy) TipDissmissBlock tipsDismissBlock;
@property (nonatomic, copy) UrlRequestCreateBlock urlCreateBlock;
@property (nonatomic, copy) TipShowBlock tipsErrorShowBlock;
@property (nonatomic, copy) TipsNetWorkBlock tipsNetWorkErrorBlock;
@property (nonatomic, copy) UrlAndBodyParamCustomSettingBlock urlAndBodyCustomSettingBlock;


//MARK: 重要
/**
  *******对于自定义 TIoTCoreAppEnvironment 文件，此属性必须赋值********
 */
@property (nonatomic, copy) NSString *customEnvrionmentAppSecretStirng;
@property (nonatomic, copy) NSString *customEnvrionmenPlatform;

@end

