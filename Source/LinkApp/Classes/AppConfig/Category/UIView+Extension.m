//
//  UIView+Extension.m
//  TenextCloud
//
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
