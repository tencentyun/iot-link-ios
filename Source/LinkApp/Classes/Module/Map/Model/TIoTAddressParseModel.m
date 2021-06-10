//
//  TIoTAddressParseModel.m
//  LinkApp
//
//

#import "TIoTAddressParseModel.h"

@implementation TIoTAddressParseModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"location":[TIoTLocationModel class],
             @"address_component":[TIoTAddressComponentModel class],
             @"ad_info":[TIoTADInfoModel class]};
}
@end
