//
//  UIDevice+TIoTDemoRotateScreen.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/30.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (TIoTDemoRotateScreen)
+ (void)changeOrientation:(UIInterfaceOrientation)orientation;
@end

NS_ASSUME_NONNULL_END
