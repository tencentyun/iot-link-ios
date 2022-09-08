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

typedef void(^TIoTDemoCloudPlayerReloadBlock)(void);

/**
 云存页面
 */
@interface TIoTCloudStorageVC : TIoTDemoBaseViewController
@property (nonatomic, strong) TIoTExploreOrVideoDeviceModel *deviceModel; //不选事件，直接跳转回看
@property (nonatomic, strong) TIoTDemoCloudEventModel *eventItemModel; // 选择具体某个事件model
@property (nonatomic, copy) TIoTDemoCloudPlayerReloadBlock playerReloadBlock;
@property (nonatomic, strong) NSString *device_xp2p_info;
@property (nonatomic, assign) BOOL isMJPEG;
- (void)clearMessage;
@end

NS_ASSUME_NONNULL_END
