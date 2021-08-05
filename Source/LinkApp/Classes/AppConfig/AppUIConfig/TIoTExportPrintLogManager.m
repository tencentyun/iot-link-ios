//
//  TIoTExportPrintLogManager.m
//  LinkApp
//
//

#import "TIoTExportPrintLogManager.h"

static NSString *const kTIoTExplortLogFile = @"TIoTExplortLogFile";
static NSString *const kTimeFormatString = @"yyyy-MM-dd HH:mm:ss";

@interface TIoTExportPrintLogManager ()

@property (nonatomic, copy) NSString *defaultLogFilePath;
@property (nonatomic, copy) NSString *targetFileDirectory;  //日志文件目录
@property (nonatomic, strong) NSString *logFilePath; ///日志文件路径

@end

@implementation TIoTExportPrintLogManager

+ (instancetype)sharedManager {
    static TIoTExportPrintLogManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc]init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        NSString *documentString = [self getDocumentDirectory]?:@"";
        self.targetFileDirectory = [self generateTargetFilePath:documentString filename:kTIoTExplortLogFile]?:@"";

        NSString *currentTimeString = [NSString getNowTimeStingWithTimeZone:@"" formatter:kTimeFormatString];
        
        self.exportLogFileName = [NSString stringWithFormat:@"%@.log", currentTimeString];

        self.defaultLogFilePath = [self.targetFileDirectory stringByAppendingPathComponent:self.exportLogFileName];
        
        self.logFilePath = self.defaultLogFilePath;
    }
    return self;
}

#pragma mark - setter and getter

- (void)setExportLogFileName:(NSString *)exportLogFileName {
    _exportLogFileName = exportLogFileName;
    //拼接Log文件路径
    self.logFilePath = [self.targetFileDirectory stringByAppendingPathComponent:exportLogFileName];
}


#pragma mark - public method

///开始日志重定向
- (void)startRecordPrintLog {
    
    BOOL isDirectExist = NO;
    
    //根据log日志文件是否存在，进行删除；（存在则删除）
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isExist = [fileManager fileExistsAtPath:self.logFilePath isDirectory:&isDirectExist];
    if (isExist) {
        NSError *error = nil;
        BOOL isDeleteSuccess = [fileManager removeItemAtPath:self.logFilePath error:&error];
        if (!isDeleteSuccess) {
            QCLog(@"delete LogFile error: %@", error.localizedDescription);
        }
    }
    
    //控制台打印重定向
    freopen([self.logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([self.logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

//MARK: 系统分享手动导出Log日志
- (void)exportLogFileInViewController:(UIViewController *)viewController {
    
    NSURL *logFileURL = nil;
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isFileExist = [fileManager fileExistsAtPath:self.logFilePath isDirectory:&isDir];
    
    if (isFileExist) {
        logFileURL = [NSURL fileURLWithPath:self.logFilePath];
    } else {
        logFileURL = [NSURL fileURLWithPath:self.defaultLogFilePath];
    }
    
    //推出分享页
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[logFileURL] applicationActivities:nil];
        [viewController presentViewController:activityVC animated:YES completion:nil];
    });
}

//MARK: 导出Log日志文件
- (void)exportPrintLog {
    UIWindow *window = [self getCurrentWindow];
    
    //系统分享手动导出Log日志
    [self exportLogFileInViewController:window.rootViewController];
}


#pragma mark - private methods

///MARK: 返回NSDocumentDirectory根目录
- (NSString *)getDocumentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return documentsDirectory;
}

// MARK: 创建指定路径文件
- (NSString *)generateTargetFilePath:(NSString *)filePath filename:(NSString *)filename {
    BOOL isDirectExist = YES;
    // 判断路径是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *targetFilePath = [NSString stringWithFormat:@"%@/%@",filePath,filename]?:@"";
    
    BOOL isExist = [fileManager fileExistsAtPath:targetFilePath isDirectory:&isDirectExist];
    if (isExist) {
        QCLog(@"\n create targetFilePath: %@\n", targetFilePath);
        return targetFilePath;
    }
    
    // 不存在则创建
    BOOL isNoExist = [fileManager createDirectoryAtPath:targetFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!isNoExist || error) {
        QCLog(@"\n create targetFilePath error: %@\n", error.localizedDescription);
        return nil;
    }
    return targetFilePath;
}

- (UIWindow *)getCurrentWindow {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    return window;
    
}

@end
