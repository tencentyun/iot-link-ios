//
//  UIView+XDPGesture.h
//  TestGesture
//
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


