//
//  TIoTVideoDeviceListModel.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TIoTVideoDeviceModel;

@interface TIoTVideoDeviceListModel : NSObject
@property (nonatomic, strong) NSArray <TIoTVideoDeviceModel *> * Data;
@property (nonatomic, assign) NSInteger TotalCount;
@end

@interface TIoTVideoDeviceModel : NSObject

@property (nonatomic, copy) NSString *ActiveTime;
@property (nonatomic, copy) NSString *DeviceName;
@property (nonatomic, copy) NSString *Disabled;
@property (nonatomic, copy) NSString *IotModel;
@property (nonatomic, copy) NSString *LastOnlineTime;
@property (nonatomic, copy) NSString *LastUpdateTime;
@property (nonatomic, copy) NSString *Online;
@property (nonatomic, copy) NSString *OtaVersion;
@property (nonatomic, copy) NSString *StreamStatus;
@property (nonatomic, copy) NSString *Tid;
@end

NS_ASSUME_NONNULL_END
