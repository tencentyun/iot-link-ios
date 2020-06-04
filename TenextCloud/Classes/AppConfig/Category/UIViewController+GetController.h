//
//  UIViewController+GetController.h
//  zhipuzi
//
//  Created by 侯兴宇 on 2017/11/15.
//  Copyright © 2017年 迅享科技. All rights reserved.
//

@interface UIViewController (GetController)

//获取根控制器
+ (UIViewController *)getRootViewController;
//获取当前view所在控制器
+ (UIViewController *)getCurrentViewController;

@end
