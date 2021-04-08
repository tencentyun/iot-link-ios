//
//  TIoTSecureAddDeviceModel.h
//  LinkApp
//
//  Created by ccharlesren on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 绑定主设备（网关和一般）后返回信息
 */

NS_ASSUME_NONNULL_BEGIN
@class TIoTSecureAddDeviceData;
@class TIoTSecureAppDeviceInfo;
@interface TIoTSecureAddDeviceModel : NSObject
@property (nonatomic, strong) TIoTSecureAddDeviceData *Data;
@end

@interface TIoTSecureAddDeviceData : NSObject
@property (nonatomic, strong) TIoTSecureAppDeviceInfo *AppDeviceInfo;
@end

@interface TIoTSecureAppDeviceInfo : NSObject
@property (nonatomic, copy) NSString *AliasName;
@property (nonatomic, copy) NSString *CreateTime;
@property (nonatomic, copy) NSString *DeviceId;
@property (nonatomic, copy) NSString *DeviceName;
@property (nonatomic, copy) NSString *DeviceType;
@property (nonatomic, copy) NSString *FamilyId;
@property (nonatomic, copy) NSString *IconUrl;
@property (nonatomic, copy) NSString *ProductId;
@property (nonatomic, copy) NSString *RoomId;
@property (nonatomic, copy) NSString *UpdateTime;
@end

NS_ASSUME_NONNULL_END
