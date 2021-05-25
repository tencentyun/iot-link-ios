//
//  UILabel+TIoTLableFormatter.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/24.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "UILabel+TIoTLableFormatter.h"

@implementation UILabel (TIoTLableFormatter)

- (void)setLabelFormateTitle:(NSString *)title font:(UIFont *)font titleColorHexString:(NSString *)titleColorString textAlignment:(NSTextAlignment)alignment{
    self.text = title;
    self.textColor = [UIColor colorWithHexString:titleColorString];
    self.font = font;
    self.textAlignment = alignment;
}

@end
