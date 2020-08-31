//
//  NSAttributedString+XDPAdd.m
//  SEEXiaodianpu
//
//  Created by seeweiting on 2019/3/6.
//  Copyright © 2019 黄锐灏. All rights reserved.
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
