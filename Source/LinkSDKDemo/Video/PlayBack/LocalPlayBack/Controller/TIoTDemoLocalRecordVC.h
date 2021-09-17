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

typedef void(^TIoTDemoLocalPlayerReloadBlock)(void);

/**
 本地回看页面
 */

@interface TIoTDemoLocalRecordVC : UIViewController
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *deviceModel; //选择设备的model（不选事件，直接跳转回看）
@property (nonatomic, strong) TIoTDemoCloudEventModel *eventItemModel; // 选择具体某个事件model
@property (nonatomic, copy) TIoTDemoLocalPlayerReloadBlock playerReloadBlock;

@property (nonatomic, assign) BOOL isNVR;
@property (nonatomic, copy) NSString *deviceName;

- (void)clearMessage;
@end

NS_ASSUME_NONNULL_END
