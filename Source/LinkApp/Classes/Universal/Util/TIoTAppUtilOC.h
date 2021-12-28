//
//  TIoTAppUtil.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTAppUtilOC : NSObject 
+ (void)checkNewVersion;
+ (BOOL)isTheVersion:(NSString *)theVersion laterThanLocalVersion:(NSString *)localVersion;
+ (void)handleOpsenUrl:(NSString *)result;
+ (BOOL)checkLogin;
+ (NSString *)getLangParameter;
@end

NS_ASSUME_NONNULL_END
