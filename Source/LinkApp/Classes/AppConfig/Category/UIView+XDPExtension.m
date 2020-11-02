//
//  UIView+XDPExtension.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/3/3.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "UIView+XDPExtension.h"

@implementation UIView (XDPExtension)

- (CAShapeLayer *)xdp_cornerRadius:(CGSize)size location:(UIRectCorner)corner
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds      byRoundingCorners:corner  cornerRadii:size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}


//设置圆角
- (void)changeViewRectConnerWithView:(UIView *)view withRect:(CGRect )rect roundCorner:(UIRectCorner)corner withRadius:(CGSize)size {
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:size];
    CAShapeLayer * layer = [[CAShapeLayer alloc]init];
    layer.frame = view.bounds;
    layer.path = path.CGPath;
    view.layer.mask = layer;

}

@end
