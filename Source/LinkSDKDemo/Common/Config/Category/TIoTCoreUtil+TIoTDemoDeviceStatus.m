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
+ (void)showDeviceStatusError:(TIoTDemoDeviceStatusModel *)responseModel {
    
    NSLog(@"Command Request DeviceStatue error:%@",responseModel.status);
    switch (responseModel.status.intValue) {
        case TIoTDeviceStatus1:
            [TIoTCoreUtil showAlertViewWithText:@"拒绝请求"];
            break;
        case TIoTDeviceStatus404:
            [TIoTCoreUtil showAlertViewWithText:@"错误请求"];
            break;
        case TIoTDeviceStatus405:
            [TIoTCoreUtil showAlertViewWithText:@"连接APP数量超过最大连接数"];
            break;
        case TIoTDeviceStatus406:
            [TIoTCoreUtil showAlertViewWithText:@"信令不支持"];
            break;
        default:
            break;
    }
}
@end
