//
//  TIoTCloudStorageDayTimeListModel.m
//  LinkApp
//
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
