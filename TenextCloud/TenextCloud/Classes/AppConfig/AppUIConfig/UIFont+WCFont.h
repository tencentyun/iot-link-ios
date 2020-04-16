//
//  UIFont+WCFont.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/17.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (WCFont)

+ (UIFont *)wcPfBoldFontOfSize:(CGFloat)size;

+ (UIFont *)wcPfSemiboldFontOfSize:(CGFloat)size;

+ (UIFont *)wcPfMediumFontOfSize:(CGFloat)size;

+ (UIFont *)wcPfRegularFontOfSize:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
