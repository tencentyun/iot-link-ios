//
//  TIoTPrintLogFileManager.m
//  LinkApp
//
//

#import "TIoTPrintLogFileManager.h"
@interface TIoTPrintLogFileManager()
@property (nonatomic, copy) NSString *targetFileName;

@end

@implementation TIoTPrintLogFileManager

- (instancetype)initWithFileLogDirectory:(NSString *)logDirectory newFileName:(NSString *)newFileName {
    self = [super initWithLogsDirectory:logDirectory];
    if (self) {
        self.targetFileName = newFileName;
    }
    return self;
}

#pragma mark - Override methods

- (NSString *)newLogFileName
{
    return [NSString stringWithFormat:@"%@", self.targetFileName];
}

- (BOOL)isLogFile:(NSString *)fileName
{
    return [fileName isEqualToString:self.targetFileName];
}
@end
