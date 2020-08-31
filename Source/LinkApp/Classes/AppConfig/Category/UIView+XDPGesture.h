//
//  UIView+XDPGesture.h
//  TestGesture
//
//  Created by cievon on 2017/9/8.
//  Copyright © 2017年 cievon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XDPLongPressEvents) {
    XDPLongPressEventsStart,
    XDPLongPressEventsEnd,
    XDPLongPressEventsCancel
};


@interface XDPTouchesGestureRecognizer : UIGestureRecognizer

@end

@interface UIView (XDPGesture)

- (void)xdp_addTarget:(id)target action:(SEL)action;
- (void)xdp_addHighlightedTarget:(id)target action:(SEL)action;
- (void)xdp_addDBclick:(id)target action:(SEL)action;
- (void)xdp_addLongPressTarget:(id)target action:(SEL)action event:(XDPLongPressEvents)event;

@end


