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

@property (nonatomic, assign) BOOL isDistributeNetFailure; //配网失败，切换配网方式时候，再新的配网流程中，用来判断返回首页还是上个页面

@end

NS_ASSUME_NONNULL_END
