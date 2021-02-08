//
//  TIoTExploreDeviceListModel.m
//  LinkApp
//
//  Created by ccharlesren on 2021/1/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTExploreDeviceListModel.h"

@implementation TIoTExploreDeviceListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Devices":[TIoTExploreOrVideoDeviceModel class],
    };
}

@end

@implementation TIoTExploreDeviceModel

@end
