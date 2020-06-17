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

@protocol TIoTCoreAddDeviceDelegate <NSObject>

- (void)onResult:(TIoTCoreResult *)result;

@end


@interface TIoTCoreSmartConfig : NSObject<TIoTCoreAddDeviceProtocol>

@property (nonatomic,copy,readonly) NSString *ssid;
@property (nonatomic,copy,readonly) NSString *password;
@property (nonatomic,copy,readonly) NSString *bssid;

@property (nonatomic,weak) id<TIoTCoreAddDeviceDelegate> delegate;

/// WiFi信息
/// @param ssid 必填
/// @param password 必填
/// @param bssid 必填
- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password BSSID:(NSString *)bssid;

@end



@interface TIoTCoreSoftAP : NSObject<TIoTCoreAddDeviceProtocol>

@property (nonatomic,copy,readonly) NSString *ssid;
@property (nonatomic,copy,readonly) NSString *password;

@property (nonatomic,weak) id<TIoTCoreAddDeviceDelegate> delegate;

/// WiFi信息
/// @param ssid 必填
/// @param password 必填
- (instancetype)initWithSSID:(NSString *)ssid PWD:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
