//
//  TIoTCoreUtil+TIoTDemoDeviceStatus.h
//  LinkSDKDemo
//

#import <UIKit/UIKit.h>
#import "TIoTCoreUtil.h"
#import "TIoTDemoDeviceStatusModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreUtil (TIoTDemoDeviceStatus)
+ (void)showDeviceStatusError:(TIoTDemoDeviceStatusModel *)responseModel commandInfo:(NSString *)commandInfo;
+ (void)showDeviceStatusErrorWithTitle:(NSString *)title contentText:(NSString *)content;
@end

NS_ASSUME_NONNULL_END
