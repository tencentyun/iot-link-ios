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

//统计事件
+ (void)logEvent:(NSString *)eventName params:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
