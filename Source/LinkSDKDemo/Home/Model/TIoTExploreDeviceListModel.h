//
//  TIoTExploreDeviceListModel.h
//  LinkApp
//
//  Created by ccharlesren on 2021/1/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@class TIoTExploreDeviceModel;

@interface TIoTExploreDeviceListModel : NSObject
@property (nonatomic, strong) NSArray <TIoTExploreDeviceModel *> * Devices;
@property (nonatomic, assign) NSInteger Total;
@end

@interface TIoTExploreDeviceModel: NSObject
@property (nonatomic, copy) NSString *AppKey;
@property (nonatomic, copy) NSString *AppSKey;
@property (nonatomic, copy) NSString *CreateTime;
@property (nonatomic, copy) NSString *DevAddr;
@property (nonatomic, copy) NSString *DevEUI;
@property (nonatomic, copy) NSString *DeviceCert;
@property (nonatomic, copy) NSString *DeviceName;
@property (nonatomic, copy) NSString *DevicePsk;
@property (nonatomic, copy) NSString *FirstOnlineTime;
@property (nonatomic, copy) NSString *LogLevel;
@property (nonatomic, copy) NSString *LoginTime;
@property (nonatomic, copy) NSString *NwkSKey;
@property (nonatomic, copy) NSString *Status;
@property (nonatomic, copy) NSString *Version;
@end


NS_ASSUME_NONNULL_END
