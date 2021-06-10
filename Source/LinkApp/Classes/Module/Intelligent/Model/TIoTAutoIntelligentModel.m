//
//  TIoTAutoIntelligentModel.m
//  LinkApp
//
//

#import "TIoTAutoIntelligentModel.h"

@implementation TIoTAutoIntelligentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Timer":[AutoIntelliConditionTimerProperty class],
             @"Property":[AutoIntelliConditionDeviceProperty class],
             @"propertyModel":[TIoTPropertiesModel class],
    };
}

@end

@implementation AutoIntelliConditionDeviceProperty

@end


@implementation AutoIntelliConditionTimerProperty

@end

