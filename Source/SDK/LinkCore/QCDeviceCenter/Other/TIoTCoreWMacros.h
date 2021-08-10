//
//  WCMacros.h
//  QCDeviceCenter
//
//

#ifndef WCMacros_h
#define WCMacros_h

typedef NS_ENUM(NSInteger,TIoTLogLevel) {
    TIoTLogLevelNone    = 0,            // 不打印
    TIoTLogLevelFatal   = 1 << 0,       // 严重、重要信息
    TIoTLogLevelError   = 1 << 1,       // 错误
    TIoTLogLevelDebug   = 1 << 2,       // 正常调试，网络请求等
    TIoTLogLevelSimple  = 1 << 3,       // 不紧要信息，日志上报等
};

#ifdef DEBUG
// TIoTLOG_LEVEL_NONE, TIoTLOG_LEVEL_FATAL, TIoTLOG_LEVEL_ERROR, TIoTLOG_LEVEL_DEBUG, TIoTLOG_LEVEL_ALL
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
#elif defined(TIoTLOG_LEVEL_DEBUG)
static const int TIoTLOG_LEVEL = (TIoTLogLevelFatal | TIoTLogLevelError | TIoTLogLevelDebug);
#elif defined(TIoTLOG_LEVEL_ALL)
static const int TIoTLOG_LEVEL = (TIoTLogLevelFatal | TIoTLogLevelError | TIoTLogLevelDebug | TIoTLogLevelSimple);
#endif

#define TIoTLogFatal(fmt, ...)    \
if (TIoTLOG_LEVEL & TIoTLogLevelFatal){QCLog(fmt, ##__VA_ARGS__);}

#define TIoTLogError(fmt, ...)    \
if (TIoTLOG_LEVEL & TIoTLogLevelError){QCLog(fmt, ##__VA_ARGS__);}

#define TIoTLogDebug(fmt, ...)    \
if (TIoTLOG_LEVEL & TIoTLogLevelDebug){QCLog(fmt, ##__VA_ARGS__);}

#define TIoTLogSimple(fmt, ...)    \
if (TIoTLOG_LEVEL & TIoTLogLevelSimple){QCLog(fmt, ##__VA_ARGS__);}

#define QCLog(fmt, ...) if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pLogEnable"] boolValue]) {NSLog((@"\n--------------\n" fmt @"\n================================="), ##__VA_ARGS__);}

#endif /* WCMacros_h */


#ifdef DEBUG
#define WCLog(fmt, ...) NSLog((@"\n--------------%s\n--------------[Line %d]\n" fmt @"\n=================================\n                          ."),__PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define WCLog(...)
#endif

 
#ifdef DEBUG
#define TIoTLog(FORMAT, ...) fprintf(stderr,"\n %s:%d   %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__LINE__, [[[NSString alloc] initWithData:[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] dataUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding] UTF8String]);
#else
#define TIoTLog(...)
#endif
