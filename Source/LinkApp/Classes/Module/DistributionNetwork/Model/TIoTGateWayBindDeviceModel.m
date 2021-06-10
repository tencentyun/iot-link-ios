//
//  TIoTGateWayBindDeviceModel.m
//  LinkApp
//
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
