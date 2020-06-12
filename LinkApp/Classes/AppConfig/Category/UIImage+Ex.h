//
//  UIImage+Ex.h
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Ex)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)getGradientImageWithColors:(NSArray*)colors imgSize:(CGSize)imgSize;

+ (UIImage *)changeGrayImage:(UIImage *)oldImage;
@end

NS_ASSUME_NONNULL_END
