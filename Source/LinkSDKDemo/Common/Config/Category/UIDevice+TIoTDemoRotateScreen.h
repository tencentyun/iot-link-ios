//
//  UIDevice+TIoTDemoRotateScreen.h
//  LinkSDKDemo
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (TIoTDemoRotateScreen)
+ (void)changeOrientation:(UIInterfaceOrientation)orientation;
+ (BOOL)judgeScreenOrientationPortrait;
@end

NS_ASSUME_NONNULL_END
