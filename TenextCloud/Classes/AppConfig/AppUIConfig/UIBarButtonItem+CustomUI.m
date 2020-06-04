//
//  UIBarButtonItem+CustomUI.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/2/13.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "UIBarButtonItem+CustomUI.h"
#import "WCUIProxy.h"

@implementation UIBarButtonItem (CustomUI)


+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image selectImage:(NSString *)selectImage{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    // 设置图片
    if (image) {
        [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    }
    
    if (selectImage) {
        [btn setImage:[UIImage imageNamed:selectImage] forState:UIControlStateHighlighted];
    }
    
    // 设置尺寸
    CGRect bframe = btn.frame;
    bframe.size = CGSizeMake(kXDPNavigationBarIcon, kXDPNavigationBarIcon);
    btn.frame = bframe;
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [btn addTarget:target  action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

@end
