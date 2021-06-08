//
//  TIoTDemoCloudEventListModel.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoCloudEventListModel.h"

@implementation TIoTDemoCloudEventListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Events":[TIoTDemoCloudEventModel class],
    };
}
@end

@implementation TIoTDemoCloudEventModel

@end


