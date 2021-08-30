//
//  TIoTDemoLocalRecordVC.h
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
 本地回看页面
 */

@interface TIoTDemoLocalRecordVC : UIViewController
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *deviceModel; //选择设备的model（不选事件，直接跳转回看）
@property (nonatomic, strong) TIoTDemoCloudEventModel *eventItemModel; // 选择具体某个事件model
@property (nonatomic, copy) TIoTDemoPlayerReloadBlock playerReloadBlock;

@property (nonatomic, assign) BOOL isNVR;
@property (nonatomic, copy) NSString *deviceName;
@end

NS_ASSUME_NONNULL_END
