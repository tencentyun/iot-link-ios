//
//  TIoTCustomTabBar.h
//  LinkApp
//
//  Created by ccharlesren on 2021/2/18.
//  Copyright © 2021 Tencent. All rights reserved.
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
