//
//  TIoTCoreXP2PBridge.h
//  TIoTLinkKitDemo
//
//  Created by eagleychen on 2020/12/14.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreXP2PBridge : NSObject

+ (instancetype)sharedInstance ;

- (void)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name ;
- (NSString *)getUrlForHttpFlv;

- (void)sendVoiceToServer;
- (void)stopVoiceToServer;

- (void)stopService;
@end

NS_ASSUME_NONNULL_END
