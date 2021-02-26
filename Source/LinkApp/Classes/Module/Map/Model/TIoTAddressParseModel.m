//
//  TIoTAddressParseModel.m
//  LinkApp
//
//  Created by ccharlesren on 2021/3/3.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTAddressParseModel.h"

@implementation TIoTAddressParseModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"location":[TIoTLocationModel class],
             @"address_component":[TIoTAddressComponentModel class],
             @"ad_info":[TIoTADInfoModel class]};
}
@end
