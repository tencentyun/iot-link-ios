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
@end

NS_ASSUME_NONNULL_END
