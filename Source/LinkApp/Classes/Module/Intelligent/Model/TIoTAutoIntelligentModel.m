//
//  TIoTAutoIntelligentModel.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoIntelligentModel.h"

@implementation TIoTAutoIntelligentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Timer":[AutoIntelliConditionTimerProperty class],
             @"Property":[AutoIntelliConditionDeviceProperty class],
    };
}

@end

@implementation AutoIntelliConditionDeviceProperty

@end


@implementation AutoIntelliConditionTimerProperty

@end

