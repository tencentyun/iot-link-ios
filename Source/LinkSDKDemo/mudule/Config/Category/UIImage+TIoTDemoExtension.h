//
//  UIImage+TIoTDemoExtension.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TIoTDemoExtensioni)
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)getGradientImageWithColors:(NSArray*)colors imgSize:(CGSize)imgSize;
@end

NS_ASSUME_NONNULL_END
