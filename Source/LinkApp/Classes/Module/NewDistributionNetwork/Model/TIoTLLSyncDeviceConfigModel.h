//
//  TIoTLLSyncDeviceConfigModel.h
//  LinkApp
//
//  Created by ccharlesren on 2021/9/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TIoTLLSyncLocalPskModel;

@interface TIoTLLSyncDeviceConfigModel : NSObject
@property (nonatomic, strong) TIoTLLSyncLocalPskModel *Configs;
@end

@interface TIoTLLSyncLocalPskModel: NSObject
@property (nonatomic, copy) NSString *ble_psk_device_ket;
@property (nonatomic, copy) NSString *ble_timestamp_device_ket;
@end

@interface TIotLLSyncDynamicRegist : NSObject
@property (nonatomic, copy) NSString *Payload;
@property (nonatomic, copy) NSString *Len;
@end
NS_ASSUME_NONNULL_END
