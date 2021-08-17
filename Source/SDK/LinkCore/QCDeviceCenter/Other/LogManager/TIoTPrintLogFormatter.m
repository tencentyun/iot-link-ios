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
            levelString = @"Error";
            break;
        }
        case DDLogFlagWarning: {
            levelString = @"Warning";
            break;
        }
        case DDLogFlagInfo: {
            levelString = @"Info";
            break;
        }
        case DDLogFlagDebug: {
            levelString = @"Debug";
            break;
        }
        case DDLogFlagVerbose: {
            levelString = @"Varbose";
            break;
        }
            
        default:{
            levelString = @"Invalid";
            break;
        }
    }
    
    NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc]init];
    [dateTimeFormatter setDateFormat:kTimeFormatString];
    NSString *timeString = [dateTimeFormatter stringFromDate:logMessage->_timestamp];
    NSString *message = logMessage->_message;
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pLogEnable"] boolValue]) {
        NSString *resultString = [NSString stringWithFormat:@"[%@]:[%@]:[%s]:[%ld]:[%@]",timeString,levelString,[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],logMessage->_line,message];
        return resultString;
    }else {
        return @"";
    }
    
}
@end
