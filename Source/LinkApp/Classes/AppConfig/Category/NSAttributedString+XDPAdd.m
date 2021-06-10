//
//  NSAttributedString+XDPAdd.m
//  SEEXiaodianpu
//
//

#import "NSAttributedString+XDPAdd.h"

@implementation NSAttributedString (XDPAdd)

- (CGFloat)heightForWidth:(CGFloat)width{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, HUGE)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     context:nil];
    return rect.size.height;
}

@end
