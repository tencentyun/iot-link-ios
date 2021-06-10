//
//  TIoTSecureAddDeviceModel.m
//  LinkApp
//
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



