//
//  MBProgressHUD+XDP.m
//  SEEXiaodianpu
//
//  Created by houxingyu on 2019/2/21.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "MBProgressHUD+XDP.h"
#import "WCHudLoadingView.h"

@implementation MBProgressHUD (WC)

//可交互
+ (void)showLodingEnabledInView:(UIView *)view withMessage:(NSString *)message{
    [self showLodingInView:view enabled:NO message:message];
}
//不可交互
+ (void)showLodingNoneEnabledInView:(UIView *)view withMessage:(NSString *)message{
    [self showLodingInView:view enabled:YES message:message];
}

+ (void)showLodingInView:(UIView *)view enabled:(BOOL)userEnabled message:(NSString *)message{
    if (view == nil) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.userInteractionEnabled = userEnabled;
    hud.bezelView.color = kRGBAColor(0, 0, 0, 0.85);
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.layer.cornerRadius = 4;
    hud.label.text = message;
    //设置文本颜色
    hud.contentColor = [UIColor whiteColor];
    hud.label.font = [UIFont systemFontOfSize:13];
    hud.margin = 16;
    //遮罩层
    hud.backgroundView.color = [UIColor clearColor];
    
    WCHudLoadingView *loadingView = [[WCHudLoadingView alloc] init];
    hud.customView = loadingView;
}

+ (void)dismissInView:(UIView *)view{
    if (view == nil) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    
//    MBProgressHUD *hud = [self HUDForView:view];
//    if ([hud.customView isKindOfClass:[XDPHudLoadingView class]]) {
//        XDPHudLoadingView *loadingView = (XDPHudLoadingView*)hud.customView;
//        [loadingView stopAnimation];
//    }
    
    [self hideHUDForView:view animated:YES];
}

/**
 显示信息

 @param message 信息内容
 @param icon 信息图片
 */
+ (void)showMessage:(NSString *)message icon:(NSString *)icon{
    [self show:message icon:icon view:nil];
}

/**
 显示信息

 @param message 信息内容
 @param icon 信息图片
 @param view 显示信息的视图
 */
+ (void)showMessage:(NSString *)message icon:(NSString *)icon toView:(UIView *)view{
    [self show:message icon:icon view:view];
}

/**
 显示信息
 
 @param message 富文本信息内容
 @param icon 信息图片
 */
+ (void)showMessageWithAttributed:(NSString *)message icon:(NSString *)icon{
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:icon];
    attachment.bounds = CGRectMake(0, -4, 17, 17);
    
    NSAttributedString *attStr = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
    NSAttributedString *tmpStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",message] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    [str appendAttributedString:tmpStr];
    
    [self showAttributedString:str icon:@"" view:nil];
}

/**
 显示信息
 
 @param message 富文本信息内容
 @param icon 信息图片
 @param view 显示信息的视图
 */
+ (void)showMessageWithAttributed:(NSString *)message icon:(NSString *)icon toView:(UIView *)view{
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:icon];
    attachment.bounds = CGRectMake(0, -4, 17, 17);
    
    NSAttributedString *attStr = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
    NSAttributedString *tmpStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",message] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    [str appendAttributedString:tmpStr];
    
    [self showAttributedString:str icon:@"" view:view];
}

/**
 *  显示成功信息
 *
 *  @param success 信息内容
 */
+ (void)showSuccess:(NSString *)success
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showSuccess:success toView:nil];
    });
}

/**
 *  显示成功信息
 *
 *  @param success 信息内容
 *  @param view    显示信息的视图
 */
+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success" view:view];
}

/**
 *  显示错误信息
 *
 */
+ (void)showError:(NSString *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showError:error toView:nil];
    });
}

/**
 *  显示错误信息
 *
 *  @param error 错误信息内容
 *  @param view  需要显示信息的视图
 */
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}


/**
 显示网络错误信息
 
 @param view 需要显示信息的视图
 */
+ (void)showNetErrorToView:(UIView *)view{
    [self show:@"似乎已断开与互联网的连接" icon:@"" view:view];
}

/**
 *  手动关闭MBProgressHUD
 */
+ (void)hideHUD
{
    [self hideHUDForView:nil];
}

/**
 *  手动关闭MBProgressHUD
 *
 *  @param view    显示MBProgressHUD的视图
 */
+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
//    MBProgressHUD *hud = [self HUDForView:view];
//    if ([hud.customView isKindOfClass:[XDPHudLoadingView class]]) {
//        XDPHudLoadingView *loadingView = (XDPHudLoadingView*)hud.customView;
//        [loadingView stopAnimation];
//    }
    [self hideHUDForView:view animated:YES];
    
}


/**
 *  显示信息
 *
 *  @param text 信息内容
 *  @param icon 图标
 *  @param view 显示的视图
 */
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];

    [self hideHUDForView:view];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    hud.userInteractionEnabled = NO;
    hud.label.text = text;
    hud.label.font = [UIFont systemFontOfSize:15];
    hud.label.textColor = [UIColor whiteColor];
    
    hud.bezelView.color = kRGBAColor(0, 0, 0, 0.85);
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.layer.cornerRadius = 8;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}

/**
 *  显示信息
 *
 *  @param text 富文本信息内容
 *  @param icon 图标
 *  @param view 显示的视图
 */
+ (void)showAttributedString:(NSAttributedString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [self hideHUDForView:view];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    hud.userInteractionEnabled = NO;
    hud.label.attributedText = text;
    hud.label.font = [UIFont systemFontOfSize:15];
    hud.label.textColor = [UIColor whiteColor];
    
    hud.bezelView.color = kRGBAColor(0, 0, 0, 0.85);
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.layer.cornerRadius = 8;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}

@end
