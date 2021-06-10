//
//  TIoTExploreDeviceListModel.m
//  LinkApp
//
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
