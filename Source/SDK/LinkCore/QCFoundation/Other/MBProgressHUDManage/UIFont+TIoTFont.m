//
//  UIFont+WCFont.m
//  TenextCloud
//
//

#import "UIFont+TIoTFont.h"

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
