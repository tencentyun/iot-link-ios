//
//  UIImage+TIoTDemoExtension.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TIoTDemoExtensioni)
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)getGradientImageWithColors:(NSArray*)colors imgSize:(CGSize)imgSize;
+ (UIImage *)makeRoundCornersWithRadius:(const CGFloat)RADIUS withImage:(UIImage *)senderImage;
@end

NS_ASSUME_NONNULL_END
