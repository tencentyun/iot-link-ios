//
//  UIView+XDPExtension.h
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/3/3.
//  Copyright © 2019 黄锐灏. All rights reserved.
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
