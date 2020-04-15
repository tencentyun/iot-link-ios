//
//  ESPTouchTask.h
//  EspTouchDemo
//
//  Created by 白 桦 on 4/14/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPTouchResult.h"
#import "ESPTouchDelegate.h"
#import "ESPAES.h"

#define ESPTOUCH_VERSION    @"v0.3.7.1"

#define DEBUG_ON   YES

@interface ESPTouchTask : NSObject

@property (atomic,assign) BOOL isCancelled;

/**
 * Constructor of EsptouchTask
 *
 * @param apSsid
 *            the Ap's ssid
 * @param apBssid
 *            the Ap's bssid
 * @param apPwd
 *            the Ap's password
 */
- (id) initWithApSsid: (NSString *)apSsid andApBssid: (NSString *) apBssid andApPwd: (NSString *)apPwd;

/**
 * Constructor of EsptouchTask
 *
 * @param apSsid
 *            the Ap's ssid
 * @param apBssid
 *            the Ap's bssid
 * @param timeoutMillisecond should be >= 15000+6000)
 * 			  millisecond of total timeout
 */
- (id) initWithApSsid: (NSString *)apSsid andApBssid: (NSString *) apBssid andApPwd: (NSString *)apPwd andTimeoutMillisecond: (int) timeoutMillisecond;

/**
 * Interrupt the Esptouch Task when User tap back or close the Application.
 */
- (void) interrupt;

/**
 * Note: !!!Don't call the task at UI Main Thread
 *
 * Smart Config v2.4 support the API
 *
 * @return the ESPTouchResult
 */
- (ESPTouchResult*) executeForResult;

/**
 * Note: !!!Don't call the task at UI Main Thread
 *
 * Smart Config v2.4 support the API
 *
 * It will be blocked until the client receive result count >= expectTaskResultCount.
 * If it fail, it will return one fail result will be returned in the list.
 * If it is cancelled while executing,
 *     if it has received some results, all of them will be returned in the list.
 *     if it hasn't received any results, one cancel result will be returned in the list.
 *
 * @param expectTaskResultCount
 *            the expect result count(if expectTaskResultCount <= 0,
 *            expectTaskResultCount = INT32_MAX)
 * @return the NSArray of EsptouchResult
 * @throws RuntimeException
 */
- (NSArray*) executeForResults:(int) expectTaskResultCount;

/**
 * set the esptouch delegate, when one device is connected to the Ap, it will be called back
 * @param esptouchDelegate when one device is connected to the Ap, it will be called back
 */
- (void) setEsptouchDelegate: (NSObject<ESPTouchDelegate> *) esptouchDelegate;

/**
 * Set boradcast or multicast when post config info
 * @param broadcast YES is boradcast, NO is multicast
 */
- (void) setPackageBroadcast: (BOOL) broadcast;
@end
