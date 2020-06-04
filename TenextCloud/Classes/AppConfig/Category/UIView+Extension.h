//
//  UIView+Extension.h
//  TenextCloud
//
//  Created by ccharlesren on 2020/6/3.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Extension)

/// 在view中获取父试图控制器
- (UIViewController *)parentController;
@end

NS_ASSUME_NONNULL_END
