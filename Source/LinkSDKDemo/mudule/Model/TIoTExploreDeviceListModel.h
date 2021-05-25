//
//  TIoTExploreDeviceListModel.h
//  LinkApp
//
//  Created by ccharlesren on 2021/1/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIoTExploreOrVideoDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN
@class TIoTExploreDeviceModel;

@interface TIoTExploreDeviceListModel : NSObject
@property (nonatomic, strong) NSArray <TIoTExploreDeviceModel *> * Devices;
@property (nonatomic, assign) NSInteger Total;
@end

@interface TIoTExploreDeviceModel: NSObject
@end


NS_ASSUME_NONNULL_END
