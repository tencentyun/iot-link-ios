//
//  WCMacros.h
//  QCDeviceCenter
//
//

#ifndef WCMacros_h
#define WCMacros_h

typedef NS_ENUM(NSInteger,TIoTLogLevel) {
    TIoTLogLevelNone    = 0,            // 不打印日志信息
    TIoTLogLevelFatal   = 1 << 0,       // 每个严重的错误事件将会导致应用程序的退出。
    TIoTLogLevelError   = 1 << 1,       // 指出虽然发生错误事件，但仍然不影响系统的继续运行。
    TIoTLogLevelWarn    = 1 << 2,       // 会出现潜在错误的情形。
    TIoTLogLevelInfo    = 1 << 3,       // 消息在粗粒度级别上突出强调应用程序的运行过程。
    TIoTLogLevelDebug   = 1 << 4,       // 细粒度信息事件对调试应用程序是非常有帮助的。
    TIoTLogLevelAll     = 1 << 5,       // 不分级别全部打印日志信息
};

#ifdef DEBUG
// TIoTLOG_LEVEL_NONE, TIoTLOG_LEVEL_FATAL, TIoTLOG_LEVEL_ERROR, TIoTLOG_LEVEL_WARN, TIoTLOG_LEVEL_INFO, TIoTLOG_LEVEL_DEBUG, TIoTLOG_LEVEL_ALL
#define TIoTLOG_LEVEL_ALL
#else
#define TIoTLOG_LEVEL_ALL
#endif

#ifdef TIoTLOG_LEVEL_NONE
static const int TIoTLOG_LEVEL = (TIoTLogLevelNone);
#elif defined(TIoTLOG_LEVEL_FATAL)
static const int TIoTLOG_LEVEL = (TIoTLogLevelFatal);
#elif defined(TIoTLOG_LEVEL_ERROR)
static const int TIoTLOG_LEVEL = (TIoTLogLevelFatal | TIoTLogLevelError);
#elif defined(TIoTLOG_LEVEL_WARN)
static const int TIoTLOG_LEVEL = (TIoTLogLevelFatal | TIoTLogLevelError | TIoTLogLevelWarn);
#elif defined(TIoTLOG_LEVEL_INFO)
static const int TIoTLOG_LEVEL = (TIoTLogLevelFatal | TIoTLogLevelError | TIoTLogLevelWarn | TIoTLogLevelInfo);
#elif defined(TIoTLOG_LEVEL_DEBUG)
static const int TIoTLOG_LEVEL = (TIoTLogLevelFatal | TIoTLogLevelError | TIoTLogLevelWarn | TIoTLogLevelInfo | TIoTLogLevelDebug);
#elif defined(TIoTLOG_LEVEL_ALL)
static const int TIoTLOG_LEVEL = (TIoTLogLevelFatal | TIoTLogLevelError | TIoTLogLevelWarn | TIoTLogLevelInfo | TIoTLogLevelDebug);
#endif

#define TIoTLogFatal(fmt, ...)    \
if (TIoTLOG_LEVEL & TIoTLogLevelFatal){TIoTLog(fmt, ##__VA_ARGS__);}

#define TIoTLogError(fmt, ...)    \
if (TIoTLOG_LEVEL & TIoTLogLevelError){TIoTLog(fmt, ##__VA_ARGS__);}

#define TIoTLogWarn(fmt, ...)    \
if (TIoTLOG_LEVEL & TIoTLogLevelWarn){TIoTLog(fmt, ##__VA_ARGS__);}

#define TIoTLogInfo(fmt, ...)    \
if (TIoTLOG_LEVEL & TIoTLogLevelInfo){TIoTLog(fmt, ##__VA_ARGS__);}

#define TIoTLogDebug(fmt, ...)    \
if (TIoTLOG_LEVEL & TIoTLogLevelDebug){TIoTLog(fmt, ##__VA_ARGS__);}

#define QCLog(fmt, ...) if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pLogEnable"] boolValue]) {NSLog((@"\n--------------\n" fmt @"\n================================="), ##__VA_ARGS__);}

#define TIoTLog(FORMAT, ...) if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pLogEnable"] boolValue]) {fprintf(stderr,"\n[%s]:%s:[%d] [%s]\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__FUNCTION__,__LINE__, [[[NSString alloc] initWithData:[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] dataUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding] UTF8String]);}

#endif /* WCMacros_h */


#ifdef DEBUG
#define WCLog(fmt, ...) NSLog((@"\n--------------%s\n--------------[Line %d]\n" fmt @"\n=================================\n                          ."),__PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define WCLog(...)
#endif

