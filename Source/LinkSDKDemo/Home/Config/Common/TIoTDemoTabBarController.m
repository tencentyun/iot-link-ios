//
//  TIoTDemoTabBarController.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/25.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoTabBarController.h"
#import "UIImage+TIoTDemoExtensioni.h"
#import "TIoTDemoHomeViewController.h"
#import "TIoTDemoNavController.h"

@interface TIoTDemoTabBarController ()<UITabBarControllerDelegate>

@end

@implementation TIoTDemoTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tabBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]];
    self.tabBar.tintColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    
    TIoTDemoHomeViewController *homeVC = [[TIoTDemoHomeViewController alloc]init];
    [self addChildVc:homeVC title:@"首页" image:@"" selectedImage:@""];
    
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
    
    TIoTDemoNavController *nav = [[TIoTDemoNavController alloc] initWithRootViewController:childVc];
    // 设置子控制器的图片
    nav.tabBarItem.image = [[UIImage imageNamed:image]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 设置文字的样式
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = kFontColor;
    textAttrs[NSFontAttributeName] = [UIFont wcPfRegularFontOfSize:11];
    
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSForegroundColorAttributeName] = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    selectTextAttrs[NSFontAttributeName] = [UIFont wcPfRegularFontOfSize:11];;
    [nav.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    // 添加为子控制器
    [self addChildViewController:nav];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
