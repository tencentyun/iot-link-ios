//
//  XDPAppEnvironment.h
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/4/2.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,WCAppEnvironmentType){
    WCAppEnvironmentTypeRelease,
    WCAppEnvironmentTypeDebug,
    WCAppEnvironmentTypeTest
};

@interface TIoTAppEnvironment : NSObject

@property (nonatomic , assign) WCAppEnvironmentType type;

+ (instancetype)shareEnvironment;

- (void)selectEnvironmentType:(WCAppEnvironmentType)type;

- (void)loginOut;

/**
 已登录baseurl
 */
@property (nonatomic , copy) NSString *baseUrlForLogined;

/**
 登录前需要签名baseurl
 */
@property (nonatomic, copy) NSString *signatureBaseUrlBeforeLogined;

/**
 未登录baseurl
 */
@property (nonatomic , copy) NSString *baseUrl;

/**
长连接
*/
@property (nonatomic , copy) NSString *wsUrl;

/**
h5
*/
@property (nonatomic , copy) NSString *h5Url;

/**
 微信分享要的type
 */
@property (nonatomic , assign) NSInteger wxShareType;

/**
 action
 */
@property (nonatomic , copy) NSString *action;

/**
 appKey
 */
@property (nonatomic , copy) NSString *appKey;

/**
 appSecret
 */
@property (nonatomic , copy) NSString *appSecret;

/**
 platform
 */
@property (nonatomic , copy) NSString *platform;


@end

NS_ASSUME_NONNULL_END
