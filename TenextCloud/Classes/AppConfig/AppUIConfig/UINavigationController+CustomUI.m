//
//  UINavigationController+CustomUI.m
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/2/13.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "UINavigationController+CustomUI.h"
#import "NSObject+SwizzlingMethod.h"
#import <objc/runtime.h>
#import "UIBarButtonItem+CustomUI.h"

static char const *const panGesKey = "panGesKey";

@implementation UINavigationController (CustomUI)

#pragma mark life cycle
+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
        [self swizzlingMethod:@selector(pushViewController:animated:) replace:@selector(xdp_pushViewController:animated:)];
//        [self swizzlingMethod:@selector(viewDidLoad) replace:@selector(xdp_viewDidLoad)];

    });
}

- (void)xdp_viewDidLoad{
    
    //1.获取系统interactivePopGestureRecognizer对象的target对象
    id target = self.interactivePopGestureRecognizer.delegate;
    //2.创建滑动手势，taregt设置interactivePopGestureRecognizer的target，所以当界面滑动的时候就会自动调用target的action方法。
    //handleNavigationTransition是私有类_UINavigationInteractiveTransition的方法，系统主要在这个方法里面实现动画的。
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] init];
    pan.edges = UIRectEdgeLeft;
    [pan addTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
    //3.设置代理
    pan.delegate = self;
    //4.添加到导航控制器的视图上
    [self.view addGestureRecognizer:pan];
    
    objc_setAssociatedObject(self, panGesKey, pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //5.禁用系统的滑动手势
    self.interactivePopGestureRecognizer.enabled = NO;
    
    self.hidesBottomBarWhenPushed=YES;
    
    [self xdp_viewDidLoad];
}

- (void)xdp_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0)
    {
        // 不是第一个子控制器（不是根控制器）
        /* 自动显示和隐藏tabbar */
        viewController.hidesBottomBarWhenPushed = YES;
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backNac"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        // 设置左边的返回按钮
        viewController.navigationItem.leftBarButtonItem = item;

    }
    
    if (![self.viewControllers containsObject:viewController]) {
        [self xdp_pushViewController:viewController animated:animated];
    }
}

#pragma mark pubilc method
- (UIScreenEdgePanGestureRecognizer *)xdpPopGes{
    return objc_getAssociatedObject(self, panGesKey);
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        if (self.visibleViewController == [self.viewControllers objectAtIndex:0]){
            return NO;
        }
    }
   
    return YES;
}


#pragma target

- (void)back
{
    [self popViewControllerAnimated:YES];
}


@end
