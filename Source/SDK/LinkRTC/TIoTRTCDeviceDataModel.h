//
//  TIoTRTCDeviceDataModel.h
//  LinkApp
//
//  Created by ccharlesren on 2021/7/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TIoTRTCDeviceValueModel;

@interface TIoTRTCDeviceDataModel : NSObject

@property (nonatomic, strong) TIoTRTCDeviceValueModel * brightness;
@property (nonatomic, strong) TIoTRTCDeviceValueModel * color;
@property (nonatomic, strong) TIoTRTCDeviceValueModel * switch_on;
@property (nonatomic, strong) TIoTRTCDeviceValueModel * light_switch;
@property (nonatomic, strong) TIoTRTCDeviceValueModel * name;

@property (nonatomic, strong) TIoTRTCDeviceValueModel * _sys_audio_call_status;
@property (nonatomic, strong) TIoTRTCDeviceValueModel * _sys_video_call_status;
@property (nonatomic, strong) TIoTRTCDeviceValueModel * _sys_userid;
@end


@interface TIoTRTCDeviceValueModel : NSObject
@property (nonatomic, copy) NSString * Value;
@property (nonatomic, copy) NSString * LastUpdate;
@end

NS_ASSUME_NONNULL_END
