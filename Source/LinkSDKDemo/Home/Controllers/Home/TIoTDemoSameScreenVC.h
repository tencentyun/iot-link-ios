//
//  TIoTDemoSameScreenVC.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/27.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTDemoBaseViewController.h"
#import "TIoTExploreOrVideoDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN
/**
 设备同屏控制器
 */
@interface TIoTDemoSameScreenVC : TIoTDemoBaseViewController
- (void)setupSameScreenArray:(NSArray <TIoTExploreOrVideoDeviceModel *>*)array;
@end

NS_ASSUME_NONNULL_END
