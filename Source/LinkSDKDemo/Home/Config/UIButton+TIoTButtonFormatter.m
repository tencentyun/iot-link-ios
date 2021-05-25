//
//  UIButton+TIoTButtonFormatter.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/24.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "UIButton+TIoTButtonFormatter.h"

@implementation UIButton (TIoTButtonFormatter)

- (void)setButtonFormateWithTitlt:(NSString *)titlt titleColorHexString:(NSString *)titleColorString font:(UIFont *)font {
    [self setTitle:titlt forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithHexString:titleColorString] forState:UIControlStateNormal];
    self.titleLabel.font = font;
}

@end
