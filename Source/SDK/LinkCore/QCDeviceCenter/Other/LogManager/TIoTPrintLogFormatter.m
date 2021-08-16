//
//  TIoTPrintLogFormatter.m
//  LinkApp
//
//

#import "TIoTPrintLogFormatter.h"

static NSString *const kTimeFormatString = @"yyyy-MM-dd HH:mm:ss:SSS";

@implementation TIoTPrintLogFormatter

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *levelString = @"";
    switch (logMessage->_flag) {
        case DDLogFlagError: {
            levelString = @"ErrorLevel";
            break;
        }
        case DDLogFlagWarning: {
            levelString = @"WarningLevel";
            break;
        }
        case DDLogFlagInfo: {
            levelString = @"InfoLevel";
            break;
        }
        case DDLogFlagDebug: {
            levelString = @"DebugLevel";
            break;
        }
        case DDLogFlagVerbose: {
            levelString = @"VarboseLevel";
            break;
        }
            
        default:{
            levelString = @"InvalidLevel";
            break;
        }
    }
    
    NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc]init];
    [dateTimeFormatter setDateFormat:kTimeFormatString];
    NSString *timeString = [dateTimeFormatter stringFromDate:logMessage->_timestamp];
    NSString *message = logMessage->_message;
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pLogEnable"] boolValue]) {
        NSString *resultString = [NSString stringWithFormat:@"[%@]:[%@]:[%@]:[%@]:[%@]:[%ld]",timeString,message,levelString,logMessage->_fileName,logMessage->_function,logMessage->_line];
        return resultString;
    }else {
        return @"";
    }
    
}
@end
