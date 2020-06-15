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

@interface WCAppEnvironment : NSObject

+ (instancetype)shareEnvironment;


@property (nonatomic, assign) WCAppEnvironmentType environment;

/**
 已登录baseurl
 */
@property (nonatomic , copy) NSString *baseUrlForLogined;

/**
 未登录baseurl
 */
@property (nonatomic , copy) NSString *baseUrl;

/**
长连接
*/
@property (nonatomic , copy) NSString *wsUrl;

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
