//
//  TIoTAppUtil.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTAppUtilOC : NSObject 
+ (void)checkNewVersion;
+ (void)handleOpsenUrl:(NSString *)result;
+ (BOOL)checkLogin;
+ (NSString *)getLangParameter;

/*
 用于 TRTC和P2P Video 中 _sys_user_agent 参数拼接组成
 */
+ (NSString *)getSysUserAgent;
@end

NS_ASSUME_NONNULL_END
