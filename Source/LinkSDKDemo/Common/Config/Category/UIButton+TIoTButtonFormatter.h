//
//  UIButton+TIoTButtonFormatter.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (TIoTButtonFormatter)

/**
 设置Button样式
 */
- (void)setButtonFormateWithTitlt:(NSString *)titlt titleColorHexString:(NSString *)titleColorString font:(UIFont *)font;
@end

NS_ASSUME_NONNULL_END
