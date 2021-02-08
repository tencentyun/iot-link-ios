//
//  TIoTVideoDeviceListModel.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTVideoDeviceListModel.h"

@implementation TIoTVideoDeviceListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Data":[TIoTExploreOrVideoDeviceModel class],
    };
}

@end


@implementation TIoTVideoDeviceModel

@end
