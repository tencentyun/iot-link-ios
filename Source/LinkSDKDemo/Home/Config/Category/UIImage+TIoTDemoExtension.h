//
//  UIImage+TIoTDemoExtension.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/25.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TIoTDemoExtensioni)
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)getGradientImageWithColors:(NSArray*)colors imgSize:(CGSize)imgSize;
@end

NS_ASSUME_NONNULL_END
