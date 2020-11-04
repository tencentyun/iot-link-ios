//
//  UILabel+TIoTExtension.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "UILabel+TIoTExtension.h"

@implementation UILabel (TIoTExtension)

- (void)setLabelFormateTitle:(NSString *)title font:(UIFont *)font titleColorHexString:(NSString *)titleColorString textAlignment:(NSTextAlignment)alignment{
    self.text = title;
    self.textColor = [UIColor colorWithHexString:titleColorString];
    self.font = font;
    self.textAlignment = alignment;
}

@end
