//
//  TIoTDemoSameScreenVC.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

#import "TIoTExploreOrVideoDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN
/**
 设备同屏控制器
 */
@interface TIoTDemoSameScreenVC : UIViewController
- (void)setupSameScreenArray:(NSArray <TIoTExploreOrVideoDeviceModel *>*)array;
@property (nonatomic, assign) BOOL isNVRType;
@property (nonatomic, copy) NSString *NVRDeviceName;
@end

NS_ASSUME_NONNULL_END
