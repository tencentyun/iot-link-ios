//
//  TIoTAutoIntelligentModel.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoIntelligentModel.h"

@implementation TIoTAutoIntelligentModel
//class func modelContainerPropertyGenericClass() -> [String: AnyObject]? {
//    return ["profile": TIoTProfileModel.classForCoder(),
//            "properties": TIoTPropertiesModel.classForCoder()]
//}

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

