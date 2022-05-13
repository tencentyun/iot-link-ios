//
//  TIoTDeviceStatusModel.m
//  LinkApp
//
//

#import "TIoTDeviceStatusModel.h"

@implementation TIoTDeviceStatusModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"video":[TIoTDeviceVideoModel class],
             @"audio":[TIoTDeviceAudioModel class],
    };
}
@end

@implementation TIoTDeviceAudioModel

@end

@implementation TIoTDeviceVideoModel

@end
