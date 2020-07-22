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
