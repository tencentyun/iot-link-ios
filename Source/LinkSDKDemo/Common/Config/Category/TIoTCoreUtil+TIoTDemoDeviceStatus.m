//
//  TIoTCoreUtil+TIoTDemoDeviceStatus.m
//  LinkSDKDemo
//

#import "TIoTCoreUtil+TIoTDemoDeviceStatus.h"
typedef NS_ENUM (NSInteger,TIoTDeviceStatus){
    TIoTDeviceStatus0,
    TIoTDeviceStatus1,
    TIoTDeviceStatus404,
    TIoTDeviceStatus405,
    TIoTDeviceStatus406,
};

@implementation TIoTCoreUtil (TIoTDemoDeviceStatus)
+ (void)showDeviceStatusError:(TIoTDemoDeviceStatusModel *)responseModel commandInfo:(NSString *)commandInfo{
    
    DDLogError(@"Command Request DeviceStatue error:%@",responseModel.status);
    switch (responseModel.status.intValue) {
        case TIoTDeviceStatus1:
            [TIoTCoreUtil showSingleActionAlertWithTitle:@"拒绝请求" content:commandInfo confirmText:@"确定"];
            break;
        case TIoTDeviceStatus404:
            [TIoTCoreUtil showSingleActionAlertWithTitle:@"错误请求" content:commandInfo confirmText:@"确定"];
            break;
        case TIoTDeviceStatus405:
            [TIoTCoreUtil showSingleActionAlertWithTitle:@"连接APP数量超过最大连接数" content:commandInfo confirmText:@"确定"];
            break;
        case TIoTDeviceStatus406:
            [TIoTCoreUtil showSingleActionAlertWithTitle:@"信令不支持" content:commandInfo confirmText:@"确定"];
            break;
        default:
            [TIoTCoreUtil showSingleActionAlertWithTitle:@"信令返回异常" content:commandInfo confirmText:@"确定"];
            break;
    }
}

+ (void)showDeviceStatusErrorWithTitle:(NSString *)title contentText:(NSString *)content {
    [TIoTCoreUtil showSingleActionAlertWithTitle:title content:content confirmText:@"确定"];
}
@end
