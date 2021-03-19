//
//  TIoTMapLocationModel.m
//  LinkApp
//
//  Created by ccharlesren on 2021/3/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTMapLocationModel.h"

@implementation TIoTMapLocationModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"pois":[TIoTPoisModel class],
             @"data":[TIoTPoisModel class],
             @"location":[TIoTLocationModel class],
             @"formatted_addresses":[TIoTAddressModel class],
             @"address_component":[TIoTAddressComponentModel class],
             @"ad_info":[TIoTADInfoModel class]};
}

@end

@implementation TIoTLocationModel

@end


@implementation TIoTAddressModel

@end

@implementation TIoTAddressComponentModel

@end


@implementation TIoTADInfoModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"location":[TIoTLocationModel class]};
}
@end

@implementation TIoTPoisModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"location":[TIoTLocationModel class],
             @"ad_info":[TIoTADInfoModel class]};
}
@end
