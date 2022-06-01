//
//  TIoTLLSyncViewController.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>
#import "TIoTLLSyncDeviceController.h"
NS_ASSUME_NONNULL_BEGIN

@interface TIoTLLSyncViewController : UIViewController

@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, strong) NSDictionary *configurationData;
@property (nonatomic, strong, nullable) TIoTLLSyncDeviceController *llsyncDeviceVC;
@property (nonatomic, assign) BOOL isPureBleLLSyncType; //是纯蓝牙设备 创建时需赋值
@property (nonatomic, assign) BOOL isDistributeNetFailure; //配网失败，切换配网方式时候，再新的配网流程中，用来判断返回首页还是上个页面
@property (nonatomic, assign) BOOL isFromProductsList; //是否从设备发现页的产品类别列表跳转（纯蓝牙类型产品且设备发现页点击特定图标跳转过来的）
@end

NS_ASSUME_NONNULL_END
