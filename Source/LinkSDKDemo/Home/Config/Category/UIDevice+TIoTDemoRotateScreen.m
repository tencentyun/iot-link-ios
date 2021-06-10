//
//  UIDevice+TIoTDemoRotateScreen.m
//  LinkSDKDemo
//
//

#import "UIDevice+TIoTDemoRotateScreen.h"

@implementation UIDevice (TIoTDemoRotateScreen)

+ (void)changeOrientation:(UIInterfaceOrientation)orientation {
    
    NSNumber *orientationNum = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationNum forKey:@"orientation"];
    NSNumber *orientationNew = [NSNumber numberWithInt:(int)orientation];
    [[UIDevice currentDevice] setValue:orientationNew forKey:@"orientation"];
}

+ (BOOL)judgeScreenOrientationPortrait {
    if(([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)){//竖屏
        return YES;
        }else{//横屏
            return NO;
        }
}
@end
