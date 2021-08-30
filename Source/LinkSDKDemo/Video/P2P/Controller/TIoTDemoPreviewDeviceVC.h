//
//  TIoTDemoPreviewDeviceVC.h
//  LinkSDKDemo
//
//

#import "TIoTDemoBaseViewController.h"
#import "TIoTExploreOrVideoDeviceModel.h"
NS_ASSUME_NONNULL_BEGIN

/**
 预览页
 */
@interface TIoTDemoPreviewDeviceVC : TIoTDemoBaseViewController
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *selectedModel;   //选择设备的model
@property (nonatomic, assign) BOOL isNVR; //区分是NVR、IPC
@property (nonatomic, strong) NSString *deviceNameNVR;
@end

NS_ASSUME_NONNULL_END
