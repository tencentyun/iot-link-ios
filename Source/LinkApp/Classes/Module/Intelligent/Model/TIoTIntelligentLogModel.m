//
//  TIoTIntelligentLogModel.m
//  LinkApp
//
//

#import "TIoTIntelligentLogModel.h"

@implementation TIoTIntelligentLogModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Msgs":[TIoTLogMsgsModel class],
    };
}

@end

@implementation TIoTLogMsgsModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"ActionResults":[TIoTActionResultsModel class],
    };
}
@end

@implementation TIoTActionResultsModel

@end

