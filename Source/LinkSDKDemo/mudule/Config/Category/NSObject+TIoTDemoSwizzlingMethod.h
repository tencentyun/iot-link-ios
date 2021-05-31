//
//  NSObject+TIoTDemoSwizzlingMethod.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TIoTDemoSwizzlingMethod)
+ (void)swizzlingMethod:(SEL)method replace:(SEL)replaceMethod;
@end

NS_ASSUME_NONNULL_END
