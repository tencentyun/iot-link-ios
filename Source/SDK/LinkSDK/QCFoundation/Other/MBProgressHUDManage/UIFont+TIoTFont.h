//
//  UIFont+WCFont.h
//  TenextCloud
//
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
