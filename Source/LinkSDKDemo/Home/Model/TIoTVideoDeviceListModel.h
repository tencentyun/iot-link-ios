//
//  TIoTVideoDeviceListModel.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIoTExploreOrVideoDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TIoTVideoDeviceModel;

@interface TIoTVideoDeviceListModel : NSObject
@property (nonatomic, strong) NSArray <TIoTVideoDeviceModel *> * Data;
@property (nonatomic, assign) NSInteger TotalCount;
@end

@interface TIoTVideoDeviceModel : NSObject
@end

NS_ASSUME_NONNULL_END
