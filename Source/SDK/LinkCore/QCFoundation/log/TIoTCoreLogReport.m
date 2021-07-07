//
// Created by Larry Tin on 2020/4/22.
// Copyright (c) 2020 Tencent. All rights reserved.
//

#import "TIoTCoreLogReport.h"
#import "TIoTCodeAddress.h"

@implementation TIoTCoreLogReport {
    
}

static NSUncaughtExceptionHandler *_previousHandler;
static void *startAddr;
static void *endAddr;
static void *startAddrWithoutSlide;
static void *endAddrWithoutSlide;

void onException(NSException *exception) {
    NSString *name = [exception name];
    NSString *reason = [exception reason];
    NSArray *symbols = [exception callStackSymbols]; // 异常发生时的调用栈
    NSMutableString *strSymbols = [[NSMutableString alloc] init]; //将调用栈拼成输出日志的字符串
    for (NSString *item in symbols) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+0x\\w*\\s+"
                                                                               options:nil
                                                                                 error:nil];
        NSTextCheckingResult *result = [regex firstMatchInString:item options:NSMatchingReportCompletion range:NSMakeRange(0, item.length)];
        if (result) {
            NSString *hexString = [item substringWithRange:result.range];
            hexString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            hexString = [hexString substringFromIndex:2];
            NSScanner* scanner = [NSScanner scannerWithString: hexString];
            unsigned long long hexNumber;
            [scanner scanHexLongLong: &hexNumber];
            
            NSString *hexStartAddrString = [NSString stringWithFormat:@"%p", startAddr];
            hexStartAddrString = [hexStartAddrString substringFromIndex:2];
            scanner = [NSScanner scannerWithString: hexStartAddrString];
            unsigned long long hexStartNumber;
            [scanner scanHexLongLong: &hexStartNumber];
            
            NSString *hexEndAddrString = [NSString stringWithFormat:@"%p", endAddr];
            hexEndAddrString = [hexEndAddrString substringFromIndex:2];
            scanner = [NSScanner scannerWithString: hexEndAddrString];
            unsigned long long hexEndNumber;
            [scanner scanHexLongLong: &hexEndNumber];
            
            if (hexNumber >= hexStartNumber && hexNumber <= hexEndNumber) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *dateStr = [formatter stringFromDate:[NSDate date]];
                NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *) kCFBundleNameKey];
                NSString *addr = [NSString stringWithFormat:@"%@ 腾讯连连SDK内存地址范围: [%p, %p]", [formatter stringFromDate:[NSDate date]], startAddr, endAddr];
                NSString *withoutSlideAddr = [NSString stringWithFormat:@"\n%@ 腾讯连连SDK内存地址范围(不带偏移): [%p, %p]", [formatter stringFromDate:[NSDate date]], startAddrWithoutSlide, endAddrWithoutSlide];
                NSString *crashString = [NSString stringWithFormat:@"%@%@\n%@ %@ *** TIoT异常结束 '%@', reason: '%@'\n%@\n", addr, withoutSlideAddr, dateStr, appName, name, exception, exception.callStackSymbols];

                NSLog(crashString);
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    
                    saveToFile(crashString);
                });
                break;
            }
        }
    }

    if (_previousHandler) {
        _previousHandler(exception);
    }
}

void saveToFile(NSString *crashString) {
    //将crash日志保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"UncaughtException.log"];


    //把错误日志写到文件中
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }

    // 将log输入到文件
//    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stdout);
//    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stderr);


}

+ (NSString *)getCrashStringFromLogFile {
    //crash日志在 Document目录下的Log文件夹下UncaughtException.log文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"UncaughtException.log"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logFilePath]) {//logFile为空
        return nil;
    } else {
        NSData *data = [NSData dataWithContentsOfFile:logFilePath];
        NSString *crashString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([crashString isEqualToString:@""]) {
            return nil;
        } else {
            return crashString;
        }
    }
}

+ (void)deleteLogFile {
    //将crash日志保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"UncaughtException.log"];
    
    //删除log文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
}

- (instancetype)initWithAppId:(NSString *)appid secretId:(NSString *)secretId secretKey:(NSString *)secretKey projectId:(NSInteger)projectId {
    self = [super init];
    if (self) {
        _appId = appid;
        _secretId = secretId;
        _secretKey = secretKey;
        _projectId = projectId;

        long slide = getExecuteImageSlide();
        startAddr = getSDKStartAddress();
        // 真实的起始地址
        startAddrWithoutSlide = startAddr - slide;
        endAddr = getSDKEndAddress();
        // 真实的结束地址
        endAddrWithoutSlide = endAddr - slide;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSString *addr = [NSString stringWithFormat:@"%@ 腾讯连连SDK内存地址范围: [%p, %p]", [formatter stringFromDate:[NSDate date]], startAddr, endAddr];
        NSLog(addr);
        NSString *withoutSlideAddr = [NSString stringWithFormat:@"%@ 腾讯连连SDK内存地址范围(不带偏移): [%p, %p]", [formatter stringFromDate:[NSDate date]], startAddrWithoutSlide, endAddrWithoutSlide];
        NSLog(withoutSlideAddr);
        NSString *addrString = [NSString stringWithFormat:@"%@\n%@\n", addr, withoutSlideAddr];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *logFileContent = [TIoTCoreLogReport getCrashStringFromLogFile];
            if (![logFileContent containsString:@"TIoT异常结束"] && logFileContent) {
                [TIoTCoreLogReport deleteLogFile];
            }
            saveToFile(addrString);
        });
        
        //拦截crash信息
        [self interceptCrashInfo];
    }
    return self;
}

//拦截crash信息
- (void)interceptCrashInfo {
    _previousHandler = NSGetUncaughtExceptionHandler();
    if (_previousHandler == &onException) {
        return;
    }

    NSSetUncaughtExceptionHandler(&onException);
}

- (void)reportCrash {
    
}

@end
