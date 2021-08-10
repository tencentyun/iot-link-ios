//
//  TIoTExportPrintLogManager.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTExportPrintLogManager : NSObject

@property (nonatomic, copy) NSString *exportLogFileName;

+ (instancetype)sharedManager;

/**
 开启重定向打印的日志
 */
- (void)startRecordPrintLog;

/**
 通过系统的分享功能导出Log日志文件
 */
- (void)exportPrintLog;
@end

NS_ASSUME_NONNULL_END
