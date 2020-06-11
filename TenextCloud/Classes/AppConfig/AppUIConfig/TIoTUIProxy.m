//
//  XDPUIProxy.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/2/13.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "TIoTUIProxy.h"


@implementation TIoTUIProxy

+ (TIoTUIProxy *)shareUIProxy{
    static id _proxy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _proxy = [TIoTUIProxy new];
    });
    return _proxy;
}


- (CGFloat)screenWidthScale{
    if (_screenWidthScale == 0) {
        _screenWidthScale = [UIScreen mainScreen].scale == 3.0 ? 1 :  self.screenWidth / 375.0;
    }
    return _screenWidthScale;
}

- (CGFloat)screenAllWidthScale{
    if (_screenAllWidthScale == 0) {
        _screenAllWidthScale = self.screenWidth / 375.0;
    }
    return _screenAllWidthScale;
}

- (CGFloat)screenAllHeightScale{
    if (_screenAllHeightScale == 0) {
        _screenAllHeightScale = self.screenHeight / 812.0;
    }
    return _screenAllHeightScale;
}

- (CGFloat)contentWidth{
    if (_contentWidth == 0) {
        _contentWidth = self.screenWidth - 2 * kHorEdge;
    }
    return _contentWidth;
}

- (CGSize)screenSize{
    return [UIScreen mainScreen].bounds.size;
}

- (CGFloat)screenWidth{
    return [UIScreen mainScreen].bounds.size.width;
}

- (CGFloat)screenHeight{
    return [UIScreen mainScreen].bounds.size.height;
}

- (BOOL)iPhoneX{
    if (@available(iOS 11.0, *)) {
        if ([UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom > 0) {
            return YES;
        }
        return NO;
    } else {
        return NO;
    }
}

- (CGFloat)tabbarHeight{
    return self.iPhoneX ? 83 : 49;
}

- (CGFloat)tabbarAddHeight{
    return self.iPhoneX ? 34 : 0;
}

- (CGFloat)statusHeight{
    return self.iPhoneX ? 44 : 20;
}

- (CGFloat)navigationBarHeight{
    return self.statusHeight + 44;
}

+ (UIColor *)colorWithHexColor:(NSString *)hexColor alpha:(CGFloat)alpha
{
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:alpha];
}

@end
