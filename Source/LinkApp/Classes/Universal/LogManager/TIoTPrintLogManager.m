//
//  TIoTPrintLogManager.m
//  LinkApp
//
//

#import "TIoTPrintLogManager.h"
#import "TIoTPrintLogFileManager.h"
#import "TIoTPrintLogFormatter.h"

@implementation TIoTPrintLogManager
+ (instancetype)sharedManager {
    static TIoTPrintLogManager *logManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logManager = [[self alloc]init];
    });
    return logManager;
}

- (void)config {
    TIoTPrintLogFormatter *logForamtter = [[TIoTPrintLogFormatter alloc]init];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // Xcode 控制台
//    [DDLog addLogger:[DDOSLogger sharedInstance]]; // 系统日志
    
    [[DDTTYLogger sharedInstance] setLogFormatter:logForamtter];  // 自定义日志格式  Xcode 控制台格式输出
//    [[DDASLLogger sharedInstance] setLogFormatter:logForamtter]; // 自定义日志格式 系统日志格式输出
    
    
    // 创建本地日志文件
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 每24小时创建一个新文件
    fileLogger.logFileManager.maximumNumberOfLogFiles = 10; // 最多允许创建文件数量
    fileLogger.maximumFileSize = 1024*1024*3;   //每个日志最大限制为 3M
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;    // 保存日志7天
    [DDLog addLogger:fileLogger withLevel:ddLogLevel];
}

- (void)exploreLogFile {
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    
    NSString *logDirectory = [fileLogger.logFileManager logsDirectory];
    NSURL *fileURL = [NSURL fileURLWithPath:logDirectory?:@""];
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    
    //推出分享页
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
        [window.rootViewController presentViewController:activityVC animated:YES completion:nil];
    });
}

- (void)clearAllLogFiles {
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger rollLogFileWithCompletionBlock:^{
        for (NSString *filename in fileLogger.logFileManager.sortedLogFilePaths) {
            [[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
        }
    }];
}
@end
