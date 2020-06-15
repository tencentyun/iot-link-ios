//
//  NSObject+ro.m
//  QCFrameworkDemo
//
//  Created by Wp on 2019/12/10.
//  Copyright © 2019 Reo. All rights reserved.
//

#import "NSObject+ro.h"



@implementation NSObject (ro)
- (BOOL)isNullOrNilWithObject;
{
    if (self == nil || [self isEqual:[NSNull null]]) {
        return YES;
    }
    
    return NO;
}

+ (CGFloat)navigationBarHeight
{
    if (@available(iOS 11.0, *)) {
        if ([UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom > 0) {
            return 88;
        }
        return 64;
    } else {
        return 64;
    }
}

+ (CGFloat)tabbarAddHeight
{
    if (@available(iOS 11.0, *)) {
        if ([UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom > 0) {
            return 34;
        }
        return 0;
    } else {
        return 0;
    }
}
@end
