//
//  NSObject+ro.h
//  QCFrameworkDemo
//
//  Created by Wp on 2019/12/10.
//  Copyright © 2019 Reo. All rights reserved.
//



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ro)
- (BOOL)isNullOrNilWithObject;

+ (CGFloat)navigationBarHeight;
+ (CGFloat)tabbarAddHeight;
@end

NS_ASSUME_NONNULL_END
