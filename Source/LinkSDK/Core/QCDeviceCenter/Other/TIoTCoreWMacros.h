//
//  WCMacros.h
//  QCDeviceCenter
//
//  Created by Wp on 2019/12/9.
//  Copyright © 2019 Reo. All rights reserved.
//

#ifndef WCMacros_h
#define WCMacros_h

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
