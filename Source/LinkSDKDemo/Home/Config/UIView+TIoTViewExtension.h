//
//  UIView+TIoTViewExtension.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/24.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (TIoTViewExtension)

/**
 设置UIview 四个角的弧度
 */
- (void)changeViewRectConnerWithView:(UIView *)view withRect:(CGRect )rect roundCorner:(UIRectCorner)corner withRadius:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
