//
//  NSObject+additions.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/8.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "NSObject+additions.h"

@implementation NSObject (additions)

+ (BOOL)isNullOrNilWithObject:(id)object;
{
    if (object == nil || [object isEqual:[NSNull null]]) {
        return YES;
    } else if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@""]) {
            return YES;
        } else {
            return NO;
        }
    } else if ([object isKindOfClass:[NSNumber class]]) {
        if ([object isEqualToNumber:@0]) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}

@end
