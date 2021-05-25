//
//  TIoTDemoDeviceHeaderView.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/25.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIotDemoDeviceEditBlock)(void);

@interface TIoTDemoDeviceHeaderView : UICollectionReusableView
@property (nonatomic, copy) TIotDemoDeviceEditBlock editBlock;
@end

NS_ASSUME_NONNULL_END
