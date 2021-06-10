//
//  UIViewController+GetController.m
//  zhipuzi
//
//

#import "UIViewController+GetController.h"

@implementation UIViewController (GetController)

+ (UIViewController *)getCurrentViewController
{
    UIViewController* currentViewController = [self getRootViewController];
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {

            currentViewController = currentViewController.presentedViewController;
        } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {

          UINavigationController* navigationController = (UINavigationController* )currentViewController;
            currentViewController = [navigationController.childViewControllers lastObject];

        } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {

          UITabBarController* tabBarController = (UITabBarController* )currentViewController;
            currentViewController = tabBarController.selectedViewController;
        } else {
            NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
                    if (childViewControllerCount > 0) {

                        currentViewController = currentViewController.childViewControllers.lastObject;

                        return currentViewController;
                    } else {

                        return currentViewController;
                    }
                }

            }
            return currentViewController;
}

+ (UIViewController *)getRootViewController{

    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}

@end
