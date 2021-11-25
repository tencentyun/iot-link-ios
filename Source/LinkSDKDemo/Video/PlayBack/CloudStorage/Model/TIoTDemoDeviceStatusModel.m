//
//  TIoTDemoDeviceStatusModel.m
//  LinkSDKDemo
//
//

#import "TIoTDemoDeviceStatusModel.h"

@implementation TIoTDemoDeviceStatusModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"video":[TIoTDemoDeviceVideoModel class],
             @"audio":[TIoTDemoDeviceAudioModel class],
    };
}
@end

@implementation TIoTDemoDeviceAudioModel

@end

@implementation TIoTDemoDeviceVideoModel

@end
