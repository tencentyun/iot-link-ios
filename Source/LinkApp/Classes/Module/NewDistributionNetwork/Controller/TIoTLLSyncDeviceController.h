//
//  TIoTLLSyncDeviceController.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>
#import "TIoTStartConfigViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTLLSyncDeviceController : UIViewController
/// 配网类型
@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;
/// WIFI信息(ssid name pwd)
@property (nonatomic, copy) NSDictionary *wifiInfo;
/// 绑定房间id
@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, copy) NSString *currentDistributionToken;

@property (nonatomic, copy) NSDictionary *connectGuideData;

@property (nonatomic, copy) NSDictionary *configdata; //所有数据

@property (nonatomic, assign) BOOL isFromProductList; //llsync 纯蓝牙设备绑定是否从设备发现页产品类别流程中进入 
//原始蓝牙扫描数据包含广播报文
@property (nonatomic, copy) NSDictionary<CBPeripheral *,NSDictionary<NSString *,id> *> *originBlueDevices;
- (void)changeContentArea ;

//首页蓝牙搜索头部调用
- (void)startConnectLLSync:(TIoTStartConfigViewController *)startconfigVC;
@end

NS_ASSUME_NONNULL_END
