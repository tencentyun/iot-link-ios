//
//  TIoTDemoCloudEventListModel.m
//  LinkSDKDemo
//
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


