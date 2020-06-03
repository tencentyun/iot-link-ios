//
//  XDPTabBarViewController.m
//  SEEXiaodianpu
//
//  Created by houxingyu on 2019/2/13.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "WCTabBarViewController.h"
#import "WCHomeViewController.h"
#import "WCMineViewController.h"
#import "WCNavigationController.h"
#import "UIImage+Ex.h"

@interface WCTabBarViewController ()<UITabBarControllerDelegate>


@end

@implementation WCTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tabBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]];
    self.tabBar.tintColor = kMainColor;
//    [UINavigationBar appearance].shadowImage = [UIImage imageWithColor:kXDPNavigationLineColor];
    // 1.初始化子控制器
    
    //首页
    WCHomeViewController *homeVC = [[WCHomeViewController alloc] init];
    [self addChildVc:homeVC title:@"首页" image:@"equipmentDefaultTabbar" selectedImage:@"equipmentSelectTabbar"];

    //个人中心
    WCMineViewController *mineVC = [[WCMineViewController alloc] init];
    [self addChildVc:mineVC title:@"我的" image:@"mineDefaultTabbar" selectedImage:@"mineSelectTabbar"];

    self.delegate = self;
    
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{

    
    return YES;
}

/**
 *  添加一个子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图片
 *  @param selectedImage 选中的图片
 */
- (void)addChildVc:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    //[[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:HWColor(255, 255, 255, 1.0)]];
    // 设置子控制器的文字
    childVc.title = title;
    // 设置子控制器的图片
    childVc.tabBarItem.image = [[UIImage imageNamed:image]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 设置文字的样式
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = kXDPTabbarNomalColor;
    textAttrs[NSFontAttributeName] = [UIFont wcPfRegularFontOfSize:kXDPTabbarTitleFont];
    
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSForegroundColorAttributeName] = kMainColor;
    selectTextAttrs[NSFontAttributeName] = [UIFont wcPfRegularFontOfSize:kXDPTabbarTitleFont];;
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    // 先给外面传进来的小控制器 包装 一个导航控制器
    WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:childVc];
    // 添加为子控制器
    [self addChildViewController:nav];
}

@end
