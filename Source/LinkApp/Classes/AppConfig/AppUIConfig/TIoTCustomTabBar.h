//
//  TIoTCustomTabBar.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTTabBarCenterAddDeviceBlcok)(void);
typedef void(^TIoTTabBarCenterScanDeviceBlcok)(void);
typedef void(^TIoTTabBarCenterIntelliDeviceBlcok)(void);

@interface TIoTCustomTabBar : UITabBar
@property (nonatomic, copy) TIoTTabBarCenterAddDeviceBlcok addDeviceBlock;
@property (nonatomic, copy) TIoTTabBarCenterScanDeviceBlcok scanDeviceBlock;
@property (nonatomic, copy) TIoTTabBarCenterIntelliDeviceBlcok intelliDeviceBlock;
@end

NS_ASSUME_NONNULL_END
