//
//  TIoTAppConfig.h
//  LinkApp
//
//  Created by eagleychen on 2020/6/18.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Model:
@interface TIoTAppConfigModel : NSObject
@property NSString *WXAccessAppId;

@property NSString *TencentIotLinkAppkey;
@property NSString *TencentIotLinkAppSecret;

@property NSString *XgAccessId;
@property NSString *XgAccessKey;
@property NSString *XgUSAAccessId;
@property NSString *XgUSAAccessKey;

@property NSString *TencentMapSDKValue;

@property NSString *HEweatherKey;
@end

@interface TIoTAppConfig : NSObject

+ (TIoTAppConfigModel *)loadLocalConfigList;
+ (NSInteger)appTypeWithModel:(TIoTAppConfigModel *)model ;

+ (BOOL)isOriginAppkeyAndSecret:(TIoTAppConfigModel *)model;
+ (BOOL)weixinLoginWithModel:(TIoTAppConfigModel *)model;

@end

NS_ASSUME_NONNULL_END
