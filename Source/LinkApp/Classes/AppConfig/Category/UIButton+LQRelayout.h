//
//  UIButton+LQRelayout.h
//  LQToolKit-ObjectiveC
//
//  Created by LiuQiqiang on 2018/7/13.
//  Copyright © 2018年 QiqiangLiu. All rights reserved.
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
