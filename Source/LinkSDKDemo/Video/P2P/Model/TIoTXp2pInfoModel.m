//
//  TIoTXp2pInfoModel.m
//  LinkSDKDemo
//

#import "TIoTXp2pInfoModel.h"

@implementation TIoTXp2pInfoModel

@end

@implementation TIoTXp2pModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Devices":[TIoTXp2pDetailModel class],
    };
}
@end

@implementation TIoTXp2pDetailModel

@end

@implementation TIoTXp2pDevInfoModel

@end

@implementation TIoTTRTCParamModel

@end
