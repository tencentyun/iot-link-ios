//
//  UIView+TIoTViewExtension.m
//  LinkApp
//
//

#import "UIView+TIoTViewExtension.h"

@implementation UIView (TIoTViewExtension)

//设置圆角
- (void)changeViewRectConnerWithView:(UIView *)view withRect:(CGRect )rect roundCorner:(UIRectCorner)corner withRadius:(CGSize)size {
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:size];
    CAShapeLayer * layer = [[CAShapeLayer alloc]init];
    layer.frame = view.bounds;
    layer.path = path.CGPath;
    view.layer.mask = layer;

}
@end
