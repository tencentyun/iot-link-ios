//
//  WCMacros.h
//  QCDeviceCenter
//
//  Created by Wp on 2019/12/9.
//  Copyright © 2019 Reo. All rights reserved.
//

#ifndef WCMacros_h
#define WCMacros_h

#define WCLog(fmt, ...) if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pLogEnable"] boolValue]) {NSLog((@"\n--------------\n" fmt @"\n================================="), ##__VA_ARGS__);}

#endif /* WCMacros_h */
