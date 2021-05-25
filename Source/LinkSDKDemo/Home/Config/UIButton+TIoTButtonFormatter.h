//
//  UIButton+TIoTButtonFormatter.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/24.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (TIoTButtonFormatter)

/**
 设置Button样式
 */
- (void)setButtonFormateWithTitlt:(NSString *)titlt titleColorHexString:(NSString *)titleColorString font:(UIFont *)font;
@end

NS_ASSUME_NONNULL_END
