//
//  TIoTRTCDeviceDataModel.m
//  LinkApp
//
//  Created by ccharlesren on 2021/7/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTRTCDeviceDataModel.h"

@implementation TIoTRTCDeviceDataModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"brightness":[TIoTRTCDeviceValueModel class],
             @"color":[TIoTRTCDeviceValueModel class],
             @"switch_on":[TIoTRTCDeviceValueModel class],
             @"light_switch":[TIoTRTCDeviceValueModel class],
             @"_sys_audio_call_status":[TIoTRTCDeviceValueModel class],
             @"_sys_video_call_status":[TIoTRTCDeviceValueModel class],
             @"_sys_userid":[TIoTRTCDeviceValueModel class],
             
    };
}
@end

@implementation TIoTRTCDeviceValueModel

@end
