//
//  TIoTCloudStorageDateModel.m
//  LinkApp
//
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
