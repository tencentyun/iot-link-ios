//
//  TIoTCoreXP2PBridge.h
//  TIoTLinkKitDemo
//
//  Created by eagleychen on 2020/12/14.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TIoTCoreXP2PBridgeDelegate <NSObject>
- (void)getVideoPacket:(uint8_t *)data len:(size_t)len;
@end


@interface TIoTCoreXP2PBridge : NSObject
@property (nonatomic, weak)id<TIoTCoreXP2PBridgeDelegate> delegate;
@property (nonatomic, assign)BOOL writeFile; //是否将数据帧写入文档

+ (NSString *)getSDKVersion;
+ (instancetype)sharedInstance ;

- (void)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name ;
- (NSString *)getUrlForHttpFlv;
- (void)getCommandRequestWithAsync:(NSString *)cmd timeout:(uint64_t)timeout completion:(void (^ __nullable)(NSString * jsonList))completion;

- (void)startAvRecvService:(NSString *)cmd;
- (void)stopAvRecvService;

- (void)sendVoiceToServer;
- (void)stopVoiceToServer;

- (void)stopService;
@end

NS_ASSUME_NONNULL_END
