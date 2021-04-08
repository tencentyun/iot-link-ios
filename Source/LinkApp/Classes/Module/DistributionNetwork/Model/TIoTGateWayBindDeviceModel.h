//
//  TIoTGateWayBindDeviceModel.h
//  LinkApp
//
//  Created by ccharlesren on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 绑定网关设备列表
 */
NS_ASSUME_NONNULL_BEGIN

@class TIoTGateWayBindDeviceInfo;

@interface TIoTGateWayBindDeviceModel : NSObject
//@property (nonatomic, strong) TIoTGateWayBindDeviceData *data;
@property (nonatomic, copy) NSString *Total;
@property (nonatomic, strong) NSArray <TIoTGateWayBindDeviceInfo*>* DeviceList;
@end

@interface TIoTGateWayBindDeviceInfo : NSObject
@property (nonatomic, copy) NSString *ProductId;
@property (nonatomic, copy) NSString *DeviceName;
@property (nonatomic, copy) NSString *DeviceId;
@property (nonatomic, copy) NSString *AliasName;
@property (nonatomic, copy) NSString *IconUrl;
@property (nonatomic, copy) NSString *IconUrlGrid;
@property (nonatomic, copy) NSString *BindStatus;
@end

NS_ASSUME_NONNULL_END
