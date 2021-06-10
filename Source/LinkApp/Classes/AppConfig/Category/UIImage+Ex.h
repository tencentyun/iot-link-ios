//
//  UIImage+Ex.h
//  TenextCloud
//
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Ex)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)getGradientImageWithColors:(NSArray*)colors imgSize:(CGSize)imgSize;

+ (UIImage *)changeGrayImage:(UIImage *)oldImage;

+ (UIImage*)makeRoundCornersWithRadius:(const CGFloat)RADIUS withImage:(UIImage *)senderImage;
@end

NS_ASSUME_NONNULL_END
