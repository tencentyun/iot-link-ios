//
//  UILabel+TIoTExtension.m
//  LinkApp
//
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
