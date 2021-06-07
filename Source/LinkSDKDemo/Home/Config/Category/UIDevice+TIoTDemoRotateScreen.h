//
//  UIDevice+TIoTDemoRotateScreen.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/5/31.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (TIoTDemoRotateScreen)
+ (void)changeOrientation:(UIInterfaceOrientation)orientation;
+ (BOOL)judgeScreenOrientationPortrait;
@end

NS_ASSUME_NONNULL_END
