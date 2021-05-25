//
//  UILabel+TIoTLableFormatter.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/24.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (TIoTLableFormatter)
/**
 设置label样式
 */

- (void)setLabelFormateTitle:(NSString *)title font:(UIFont *)font titleColorHexString:(NSString *)titleColorString textAlignment:(NSTextAlignment)alignment;
@end

NS_ASSUME_NONNULL_END
