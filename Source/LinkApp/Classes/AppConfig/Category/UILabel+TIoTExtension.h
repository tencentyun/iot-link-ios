//
//  UILabel+TIoTExtension.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (TIoTExtension)

/**
 设置label样式
 */

- (void)setLabelFormateTitle:(NSString *)title font:(UIFont *)font titleColorHexString:(NSString *)titleColorString textAlignment:(NSTextAlignment)alignment;

@end

NS_ASSUME_NONNULL_END
