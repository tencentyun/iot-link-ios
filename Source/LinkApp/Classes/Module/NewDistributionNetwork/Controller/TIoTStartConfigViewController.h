//
//  TIoTStartConfigViewController.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>
#import "TIoTConnectStepTipView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTStartConfigViewController : UIViewController

@property (nonatomic, strong) TIoTConnectStepTipView *connectStepTipView;

/// 配网类型
@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;
/// WIFI信息(ssid name pwd)
@property (nonatomic, copy) NSDictionary *wifiInfo;
/// 绑定房间id
@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, copy) NSDictionary *connectGuideData;

@property (nonatomic, assign) BOOL isFromProductList;

//token 2秒轮询查看设备状态
- (void)checkTokenStateWithCirculationWithDeviceData:(NSDictionary *)data;
@end

NS_ASSUME_NONNULL_END
