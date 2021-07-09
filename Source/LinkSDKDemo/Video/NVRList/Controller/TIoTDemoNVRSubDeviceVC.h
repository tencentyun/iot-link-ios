//
//  TIoTDemoNVRSubDeviceVC.h
//  LinkSDKDemo
//

#import "TIoTDemoBaseViewController.h"
#import "TIoTExploreOrVideoDeviceModel.h"
NS_ASSUME_NONNULL_BEGIN
/**
 NVR子设备列表
 */
@interface TIoTDemoNVRSubDeviceVC : TIoTDemoBaseViewController
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *selectedModel;
@end

NS_ASSUME_NONNULL_END
