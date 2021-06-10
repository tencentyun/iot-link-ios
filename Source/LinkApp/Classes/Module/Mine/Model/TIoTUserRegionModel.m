//
//  TIoTUserRegionModel.m
//  LinkApp
//
//

#import "TIoTUserRegionModel.h"

@implementation TIoTUserRegionModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Configs":[TIoTConfigModel class]};
}
@end

@implementation TIoTConfigModel

@end

@implementation TIoTTimeZoneListModel

@end

@implementation TIoTRegionModel

@end
