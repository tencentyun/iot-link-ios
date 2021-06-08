//
//  UIImageView+TIoTDemoWebImage.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "UIImageView+TIoTDemoWebImage.h"
#import "UIImageView+WebCache.h"
@implementation UIImageView (TIoTDemoWebImage)
- (void)setImageWithURLStr:(NSString *_Nullable)str placeHolder:(NSString *_Nullable)placeHolder{
    [self sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:placeHolder]];
}
@end



