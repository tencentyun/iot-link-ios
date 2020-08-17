//
//  TIoTUserRegionModel.m
//  LinkApp
//
//  Created by ccharlesren on 2020/8/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTUserRegionModel.h"

@implementation TIoTUserRegionModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Configs":[TIoTConfigModel class]};
}
@end

@implementation TIoTConfigModel

@end

@implementation TIoTReginListModel

@end
