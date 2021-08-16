//
//  TIoTPrintLogFileManager.h
//  LinkApp
//
//

/**
 重命名日志文件
 */
#import <CocoaLumberjack/CocoaLumberjack.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTPrintLogFileManager : DDLogFileManagerDefault
- (instancetype)initWithFileLogDirectory:(NSString *)logDirectory newFileName:(NSString *)newFileName;
@end

NS_ASSUME_NONNULL_END
