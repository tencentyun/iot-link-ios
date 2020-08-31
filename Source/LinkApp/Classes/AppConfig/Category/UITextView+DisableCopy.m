//
//  UITextView+DisableCopy.m
//  TenextCloud
//
//  Created by Wp on 2019/12/24.
//  Copyright © 2019 Winext. All rights reserved.
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
