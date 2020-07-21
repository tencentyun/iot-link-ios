//
//  MBProgressHUD+XDP.h
//  QCFoundation
//
//  Created by ccharlesren on 2020/7/21.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBProgressHUD (XDP)

//@property (nonatomic, strong)XDPHudLoadingView *loadingView;

//可交互
+ (void)showLodingEnabledInView:(UIView *)view withMessage:(NSString *)message;
//不可交互
+ (void)showLodingNoneEnabledInView:(UIView *)view withMessage:(NSString *)message;

+ (void)dismissInView:(UIView *)view;

+ (void)showMessage:(NSString *)message icon:(NSString *)icon;
+ (void)showMessage:(NSString *)message icon:(NSString *)icon toView:(UIView *)view;

+ (void)showMessageWithAttributed:(NSString *)message icon:(NSString *)icon;
+ (void)showMessageWithAttributed:(NSString *)message icon:(NSString *)icon toView:(UIView *)view;

+ (void)showSuccess:(NSString *)success;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

+ (void)showError:(NSString *)error;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (void)showNetErrorToView:(UIView *)view;

+ (void)hideHUD;
+ (void)hideHUDForView:(UIView *)view;

+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
