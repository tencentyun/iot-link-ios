//
//  UIFont+WCFont.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/17.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "UIFont+WCFont.h"

@implementation UIFont (WCFont)

+ (UIFont *)wcPfBoldFontOfSize:(CGFloat)size{
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Bold" size:size];
    
    if (font) {
        return font;
    }
    
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)wcPfSemiboldFontOfSize:(CGFloat)size{
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Semibold" size:size];
    
    if (font) {
        return font;
    }
    
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)wcPfMediumFontOfSize:(CGFloat)size{
    UIFont *font = [UIFont fontWithName:@"PingFang-SC-Medium" size:size];
    
    if (font) {
        return font;
    }
    
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)wcPfRegularFontOfSize:(CGFloat)size{
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:size];
    
    if (font) {
        return font;
    }
    
    return [UIFont systemFontOfSize:size];
}

@end
