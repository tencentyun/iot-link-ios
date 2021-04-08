//
//  TIoTGateWayBindDeviceModel.m
//  LinkApp
//
//  Created by ccharlesren on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTGateWayBindDeviceModel.h"

@implementation TIoTGateWayBindDeviceModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"DeviceList":[TIoTGateWayBindDeviceInfo class],
    };
}
@end

@implementation TIoTGateWayBindDeviceInfo

@end
