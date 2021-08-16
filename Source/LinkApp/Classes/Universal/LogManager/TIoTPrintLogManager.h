//
//  TIoTPrintLogManager.h
//  LinkApp
//
//

/**
 日志管理
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTPrintLogManager : NSObject
+ (instancetype)sharedManager;
- (void)config;
- (void)exploreLogFile;
- (void)clearAllLogFiles;
@end

NS_ASSUME_NONNULL_END
