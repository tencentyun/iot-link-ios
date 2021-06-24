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
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *selectedModel;
@end

NS_ASSUME_NONNULL_END
