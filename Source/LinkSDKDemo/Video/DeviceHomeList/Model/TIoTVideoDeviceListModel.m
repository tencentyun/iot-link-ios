//
//  TIoTVideoDeviceListModel.m
//  LinkSDKDemo
//
//

#import "TIoTVideoDeviceListModel.h"

@implementation TIoTVideoDeviceListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Devices":[TIoTExploreOrVideoDeviceModel class],
    };
}

@end


@implementation TIoTVideoDeviceModel

@end
