//
//  UIButton+LQRelayout.h
//  LQToolKit-ObjectiveC
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XDPButtonLayoutStyle) {
    XDPButtonLayoutStyleLeft = 0,
    XDPButtonLayoutStyleRight,
    XDPButtonLayoutStyleTop,
    XDPButtonLayoutStyleBottom
};

@interface UIButton (LQRelayout)

- (void)relayoutButton:(XDPButtonLayoutStyle)type ;

- (void)setButtonFormateWithTitlt:(NSString *)titlt titleColorHexString:(NSString *)titleColorString font:(UIFont *)font;
@end
