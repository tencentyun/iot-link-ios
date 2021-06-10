//
//  UITextView+DisableCopy.m
//  TenextCloud
//
//

#import "UITextView+DisableCopy.h"


@implementation UITextView (DisableCopy)


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ([UIMenuController sharedMenuController]) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }

    return NO;
}

@end
