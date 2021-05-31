//
//  UIDevice+TIoTDemoRotateScreen.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/5/31.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "UIDevice+TIoTDemoRotateScreen.h"

@implementation UIDevice (TIoTDemoRotateScreen)

+ (void)changeOrientation:(UIInterfaceOrientation)orientation {
    
    NSNumber *orientationNum = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationNum forKey:@"orientation"];
    NSNumber *orientationNew = [NSNumber numberWithInt:(int)orientation];
    [[UIDevice currentDevice] setValue:orientationNew forKey:@"orientation"];
}
@end
