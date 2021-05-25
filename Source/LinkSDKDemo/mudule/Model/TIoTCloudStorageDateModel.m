//
//  TIoTCloudStorageDateModel.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/17.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCloudStorageDateModel.h"

@implementation TIoTCloudStorageDateModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Data":[TIoTCloudStorageDateListModel class],
    };
}
@end

@implementation TIoTCloudStorageDateListModel

@end
