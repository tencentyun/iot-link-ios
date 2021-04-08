//
//  TIoTSecureAddDeviceModel.m
//  LinkApp
//
//  Created by ccharlesren on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTSecureAddDeviceModel.h"

@implementation TIoTSecureAddDeviceModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Data":[TIoTSecureAddDeviceData class],
    };
}

@end

@implementation TIoTSecureAddDeviceData
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"AppDeviceInfo":[TIoTSecureAppDeviceInfo class],
    };
}
@end

@implementation TIoTSecureAppDeviceInfo

@end



