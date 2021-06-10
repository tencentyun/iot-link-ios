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

@interface TIoTCloudStorageVC : TIoTDemoBaseViewController
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *deviceModel; //不选事件，直接跳转回看
@property (nonatomic, strong) TIoTDemoCloudEventModel *eventItemModel; // 选择具体某个事件model
@end

NS_ASSUME_NONNULL_END
