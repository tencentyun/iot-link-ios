//
//  UIImageView+WCWebImageView.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "UIImageView+WCWebImageView.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (WCWebImageView)

- (void)setImageWithURLStr:(NSString *_Nullable)str{
    [self sd_setImageWithURL:[NSURL URLWithString:str]];
}

- (void)setImageDefaultPlaceHolderWithURLStr:(NSString *_Nullable)str{
    [self sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@""]];
}

- (void)setImageWithURLStr:(NSString *_Nullable)str placeHolder:(NSString *_Nullable)placeHolder{
    [self sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:placeHolder]];
}

@end
