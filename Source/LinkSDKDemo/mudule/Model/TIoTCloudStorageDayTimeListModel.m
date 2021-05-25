//
//  TIoTCloudStorageDayTimeListModel.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/17.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCloudStorageDayTimeListModel.h"

@implementation TIoTCloudStorageDayTimeListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"TimeList":[TIoTCloudStorageTimeDataModel class],
    };
}
@end

@implementation TIoTCloudStorageTimeDataModel

@end
