//
//  UIImageView+TIoTDemoWebImage.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (TIoTDemoWebImage)
- (void)setImageWithURLStr:(NSString *_Nullable)str placeHolder:(NSString *_Nullable)placeHolder;
@end

NS_ASSUME_NONNULL_END
