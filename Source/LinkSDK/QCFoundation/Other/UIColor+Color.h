//
//  UIColor+Color.h
//  LinkApp
//
//  Created by ccharlesren on 2020/7/28.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Color)

/// 颜色转换：16进制颜色传为UIcolor（RGB）
/// @param colorString 16进制颜色字符串（#000000）
+ (UIColor *)colorWithHexString:(NSString *)colorString;

+ (UIColor *)colorWithHexString:(NSString *)colorString withAlpha:(CGFloat )alpha;
@end

NS_ASSUME_NONNULL_END
