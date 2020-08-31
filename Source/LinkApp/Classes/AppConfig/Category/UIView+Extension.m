//
//  UIView+Extension.m
//  TenextCloud
//
//  Created by ccharlesren on 2020/6/3.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (UIViewController *)parentController
{
    UIResponder *responder = [self nextResponder];
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}
@end
