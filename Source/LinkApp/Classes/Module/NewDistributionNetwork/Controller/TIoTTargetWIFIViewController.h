//
//  TIoTTargetWIFIViewController.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>
#import "TIoTLLSyncDeviceController.h"
NS_ASSUME_NONNULL_BEGIN

@interface TIoTTargetWIFIViewController : UIViewController

/// 配网类型
@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;

@property (nonatomic, assign) NSInteger step;
/// WIFI信息(ssid name pwd)
@property (nonatomic, copy) NSDictionary *softApWifiInfo;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *currentDistributionToken;
@property (nonatomic, copy) NSDictionary *configConnentData;

@property (nonatomic, strong) TIoTLLSyncDeviceController *llsyncDeviceVC;

- (void)showWiFiListView;

@end

NS_ASSUME_NONNULL_END
