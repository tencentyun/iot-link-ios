//
//  UIImageView+WCWebImageView.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (WCWebImageView)

- (void)setImageWithURLStr:(NSString *_Nullable)str;

- (void)setImageDefaultPlaceHolderWithURLStr:(NSString *_Nullable)str;

- (void)setImageWithURLStr:(NSString *_Nullable)str placeHolder:(NSString *_Nullable)placeHolder;

@end

NS_ASSUME_NONNULL_END
