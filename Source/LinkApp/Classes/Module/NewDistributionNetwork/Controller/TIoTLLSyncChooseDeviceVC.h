//
//  TIoTLLSyncChooseDeviceVC.h
//  LinkApp
//

#import <UIKit/UIKit.h>
@class TIoTLLSyncDeviceController;
/**
 * 纯蓝牙设备选择页面，从设备发现页
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTLLSyncChooseDeviceVC : UIViewController

/// 纯蓝牙设备类型
@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;

@property (nonatomic, strong, nullable) TIoTLLSyncDeviceController *llsyncDeviceVC;
/// 绑定房间id
@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, copy) NSString *currentDistributionToken;

@property (nonatomic, copy) NSDictionary *configdata; //所有数据

@property (nonatomic, assign) BOOL isFromProductsList; //llsync 纯蓝牙设备绑定是否从设备发现页产品类别流程中进入
@end

NS_ASSUME_NONNULL_END
