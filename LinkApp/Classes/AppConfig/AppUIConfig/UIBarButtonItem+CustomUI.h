//
//  UIBarButtonItem+CustomUI.h
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/2/13.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (CustomUI)

+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image selectImage:(NSString *)selectImage;

@end

NS_ASSUME_NONNULL_END
