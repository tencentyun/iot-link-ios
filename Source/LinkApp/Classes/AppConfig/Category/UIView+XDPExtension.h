//
//  UIView+XDPExtension.h
//  SEEXiaodianpu
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (XDPExtension)

- (CAShapeLayer *)xdp_cornerRadius:(CGSize)size location:(UIRectCorner)corner;

/**
 设置UIview 四个角的弧度
 */
- (void)changeViewRectConnerWithView:(UIView *)view withRect:(CGRect )rect roundCorner:(UIRectCorner)corner withRadius:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
