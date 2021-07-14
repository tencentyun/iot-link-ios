//
//  TIoTCoreXP2PBridge.h
//  TIoTLinkKitDemo
//
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

// 调试SDK功能可以使用此接口，OEM请使用下面的start xp2pinfo, 以防止sec_id ,sec_key泄露
- (void)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name ;

// OEM 版本推荐使用此接口，sec_id, sec_key 传@""即可。 此接口需传从自建服务获取到的 xp2pinfo .
- (void)startAppWith:(NSString *)sec_id sec_key:(NSString *)sec_key pro_id:(NSString *)pro_id dev_name:(NSString *)dev_name xp2pinfo:(NSString *)xp2pinfo;


- (NSString *)getUrlForHttpFlv:(NSString *)dev_name;
- (void)getCommandRequestWithAsync:(NSString *)dev_name cmd:(NSString *)cmd timeout:(uint64_t)timeout completion:(void (^ __nullable)(NSString * jsonList))completion;

- (void)startAvRecvService:(NSString *)dev_name cmd:(NSString *)cmd;
- (void)stopAvRecvService:(NSString *)dev_name;

- (void)sendVoiceToServer:(NSString *)dev_name channel:(NSString *)channel_number;
- (void)stopVoiceToServer;

- (void)stopService:(NSString *)dev_name;
@end

NS_ASSUME_NONNULL_END
