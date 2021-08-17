//
//  TIoTCoreXP2PHeader.h
//  Pods
//
//  Created by ccharlesren on 2021/8/17.
//

#ifndef TIoTCoreXP2PHeader_h
#define TIoTCoreXP2PHeader_h

#ifdef __OBJC__
#import <CocoaLumberjack/CocoaLumberjack.h>

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

#endif

#endif /* TIoTCoreXP2PHeader_h */
