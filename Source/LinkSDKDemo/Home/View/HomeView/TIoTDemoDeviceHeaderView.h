//
//  TIoTDemoDeviceHeaderView.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/25.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 首页设备列表header view
 */

@class TIoTDemoDeviceHeaderView;

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIotDemoDeviceEditBlock)(TIoTDemoDeviceHeaderView *headerView,BOOL isEditPartten);
typedef void(^TIoTDemoCanceEditlBlock)(void);

@interface TIoTDemoDeviceHeaderView : UICollectionReusableView
@property (nonatomic, copy) TIotDemoDeviceEditBlock editBlock;
@property (nonatomic, copy) TIoTDemoCanceEditlBlock cancelEditBlock;

- (void)enterEditPattern;
- (void)exitEditPattern;
@end

NS_ASSUME_NONNULL_END
