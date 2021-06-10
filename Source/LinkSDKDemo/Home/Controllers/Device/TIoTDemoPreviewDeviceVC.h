//
//  TIoTDemoPreviewDeviceVC.h
//  LinkSDKDemo
//
//

#import "TIoTDemoBaseViewController.h"
#import "TIoTExploreOrVideoDeviceModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TIoTDemoPreviewDeviceVC : TIoTDemoBaseViewController
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *selectedModel;
@end

NS_ASSUME_NONNULL_END
