//
//  ESPUDPSocketClient.h
//  EspTouchDemo
//
//  Created by 白 桦 on 4/13/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPUDPSocketClient : NSObject

- (void) close;

- (void) interrupt;

/**
 * send the data by UDP
 * @param interval
 *            the milliseconds to between each UDP sent
 */
- (void) sendDataWithBytesArray2: (NSArray *) bytesArray2 ToTargetHostName: (NSString *)targetHostName WithPort: (int) port
      andInterval: (long) interval;

/**
 * send the data by UDP
 * @param offset
 * 			  the offset which data to be sent
 * @param count
 * 			  the count of the data
 * @param interval
 *            the milliseconds to between each UDP sent
 */
- (void) sendDataWithBytesArray2: (NSArray *) bytesArray2 Offset: (NSUInteger) offset Count: (NSUInteger) count ToTargetHostName: (NSString *)targetHostName WithPort: (int) port
                     andInterval: (long) interval;
@end
