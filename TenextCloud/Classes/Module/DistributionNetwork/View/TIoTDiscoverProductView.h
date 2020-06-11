//
//  WCDiscoverProductView.h
//  TenextCloud
//
//  Created by Sun on 2020/5/27.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DiscoverDeviceStatus) {
    DiscoverDeviceStatusDiscovering,
    DiscoverDeviceStatusDiscovered,
    DiscoverDeviceStatusNotFound,
};

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDiscoverProductView : UIView

@property (nonatomic, copy) void (^helpAction)(void);
@property (nonatomic, copy) void (^scanAction)(void);
@property (nonatomic, copy) void (^retryAction)(void);
@property (nonatomic, assign) DiscoverDeviceStatus status;

@end

NS_ASSUME_NONNULL_END
