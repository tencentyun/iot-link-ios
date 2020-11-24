//
//  TIoTIntelligentLogModel.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/24.
//  Copyright © 2020 Tencent. All rights reserved.
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

