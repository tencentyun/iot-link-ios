//
//  TIoTDeviceDetailModel.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/25.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDeviceDetailModel : NSObject
@property (nonatomic, copy) NSString *DeviceId;
@property (nonatomic, copy) NSString *ProductId;
@property (nonatomic, copy) NSString *DeviceName;
@property (nonatomic, copy) NSString *AliasName;
@property (nonatomic, copy) NSString *IconUrl;
@property (nonatomic, copy) NSString *FamilyId;
@property (nonatomic, copy) NSString *RoomId;
@property (nonatomic, copy) NSString *CreateTime;
@property (nonatomic, copy) NSString *UpdateTime;

@end

NS_ASSUME_NONNULL_END
