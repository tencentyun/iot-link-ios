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
@property NSString *TencentIotLinkAppSecrecy;

@property NSString *XgAccessId;
@property NSString *XgAccessKey;

@property NSString *TencentMapSDKValue;
@end

@interface TIoTAppConfig : NSObject

+ (TIoTAppConfigModel *)loadLocalConfigList;
@end

NS_ASSUME_NONNULL_END
