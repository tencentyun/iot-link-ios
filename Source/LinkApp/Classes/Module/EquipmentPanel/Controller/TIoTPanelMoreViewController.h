//
//  WCPanelMoreViewController.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIoTDeleteDeviceRequest)(void);
typedef void(^TIoTDeleteDeviceBlock)(BOOL isSuccess);
typedef void(^TIoTFirmwareUpdateBlock)(void);
@interface TIoTPanelMoreViewController : UIViewController

@property (nonatomic, strong) NSMutableDictionary *deviceDic;
@property (nonatomic, copy) TIoTDeleteDeviceRequest deleteDeviceRequest;
@property (nonatomic, copy)TIoTDeleteDeviceBlock deleteDeviceBlock;
@property (nonatomic, copy)TIoTFirmwareUpdateBlock firmwareUpateBlock;
@end

NS_ASSUME_NONNULL_END
