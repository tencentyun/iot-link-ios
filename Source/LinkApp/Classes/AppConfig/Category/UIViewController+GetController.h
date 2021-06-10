//
//  UIViewController+GetController.h
//  zhipuzi
//
//

@interface UIViewController (GetController)

//获取根控制器
+ (UIViewController *)getRootViewController;
//获取当前view所在控制器
+ (UIViewController *)getCurrentViewController;

@end
