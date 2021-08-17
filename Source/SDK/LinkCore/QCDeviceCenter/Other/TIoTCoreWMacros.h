//
//  WCMacros.h
//  QCDeviceCenter
//
//

#ifndef WCMacros_h
#define WCMacros_h

#define QCLog(fmt, ...) if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pLogEnable"] boolValue]) {NSLog((@"\n--------------\n" fmt @"\n================================="), ##__VA_ARGS__);}

#define TIoTLog(FORMAT, ...) if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pLogEnable"] boolValue]) {NSLog(@"[%s]:[%s]:[%s]:[%d]",[[[NSString alloc] initWithData:[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] dataUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding] UTF8String],[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__FUNCTION__,__LINE__);}

#endif /* WCMacros_h */

#import <CocoaLumberjack/CocoaLumberjack.h>

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

#ifdef DEBUG
#define WCLog(fmt, ...) NSLog((@"\n--------------%s\n--------------[Line %d]\n" fmt @"\n=================================\n                          ."),__PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define WCLog(...)
#endif

