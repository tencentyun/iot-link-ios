//
//  QCAddDevice.h
//  QCDeviceCenter
//
//  Created by Wp on 2019/12/5.
//  Copyright © 2019 Reo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIoTCoreObject.h"

NS_ASSUME_NONNULL_BEGIN


@protocol TIoTCoreAddDeviceProtocol

@property (nonatomic,readonly) BOOL isConnecting;//是否正在配网中

/// 开始配网流程
- (void)startAddDevice;

/// 终止配网流程
- (void)stopAddDevice;

@end

@class TCSocket;
@class GCDAsyncUdpSocket;

@protocol TIoTCoreAddDeviceDelegate <NSObject>
@optional
- (void)smartConfigOnHandleSocketOpen:(TCSocket *)socket;

- (void)smartConfigOnHandleSocketClosed:(TCSocket *)socket;

- (void)smartConfigOnHandleDataReceived:(TCSocket *)socket data:(NSData *)data;

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address;

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag;

- (void)softApuUdpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error;

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext;

/**
 - (void)onResult: 代理方法可选实现，但是 TIoTCoreSmartConfig 对象和 TIoTCoreSoftAP 对象中的 updConnectBlock 、connectFaildBlock 、udpFaildBlock必须要实现
 */
- (void)onResult:(TIoTCoreResult *)result;

@end

typedef void(^createUpdBlock)(NSString *ipaAddrData);
typedef void(^connectFaildBlock)(void);

@interface TIoTCoreSmartConfig : NSObject<TIoTCoreAddDeviceProtocol>

@property (nonatomic,copy,readonly) NSString *ssid;
@property (nonatomic,copy,readonly) NSString *password;
@property (nonatomic,copy,readonly) NSString *bssid;

@property (nonatomic,weak) id<TIoTCoreAddDeviceDelegate> delegate;
@property (nonatomic, assign) int serverProt;
/*
 必须实现
*/

/// 创建udp链接block  必须实现
@property (nonatomic, copy) createUpdBlock updConnectBlock;

/// 链接失败后block   必须实现
@property (nonatomic, copy) connectFaildBlock connectFaildBlock;

/// WiFi信息
/// @param ssid 必填
/// @param password 必填
/// @param bssid 必填
- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password BSSID:(NSString *)bssid;


@end


typedef void(^connectUdpFaildBlock)(void);
//typedef NSString *_Nullable(^gatewayIPBlock)(void);

@interface TIoTCoreSoftAP : NSObject<TIoTCoreAddDeviceProtocol>

@property (nonatomic,copy,readonly) NSString *ssid;
@property (nonatomic,copy,readonly) NSString *password;

@property (nonatomic,weak) id<TIoTCoreAddDeviceDelegate> delegate;
@property (nonatomic, assign) NSInteger serverProt;
/*
 必须实现
*/


/// 获取 gateway 的ip   必填
@property (nonatomic, copy) NSString *gatewayIpString;

/// dup连接失败 block   必须实现
@property (nonatomic ,copy) connectUdpFaildBlock udpFaildBlock;


/// WiFi信息
/// @param ssid 必填
/// @param password 必填
- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password;


@end

NS_ASSUME_NONNULL_END
