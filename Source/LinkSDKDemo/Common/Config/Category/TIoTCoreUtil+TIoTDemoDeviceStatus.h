//
//  TIoTCoreUtil+TIoTDemoDeviceStatus.h
//  LinkSDKDemo
//

#import <UIKit/UIKit.h>
#import "TIoTCoreUtil.h"
#import "TIoTDemoDeviceStatusModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreUtil (TIoTDemoDeviceStatus)
+ (void)showDeviceStatusError:(TIoTDemoDeviceStatusModel *)responseModel;
@end

NS_ASSUME_NONNULL_END
