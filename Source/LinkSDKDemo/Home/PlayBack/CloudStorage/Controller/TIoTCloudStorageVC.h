//
//  TIoTCloudStorageVC.h
//  LinkSDKDemo
//
//

#import <UIKit/UIKit.h>
#import "TIoTDemoBaseViewController.h"
#import "TIoTExploreOrVideoDeviceModel.h"
#import "TIoTDemoCloudEventListModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTDemoPlayerReloadBlock)(void);

/**
 云存页面
 */
@interface TIoTCloudStorageVC : TIoTDemoBaseViewController
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *deviceModel; //不选事件，直接跳转回看
@property (nonatomic, strong) TIoTDemoCloudEventModel *eventItemModel; // 选择具体某个事件model
@property (nonatomic, copy) TIoTDemoPlayerReloadBlock playerReloadBlock;
@end

NS_ASSUME_NONNULL_END
