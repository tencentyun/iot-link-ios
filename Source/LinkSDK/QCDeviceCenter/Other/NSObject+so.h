//
//  NSObject+so.h
//  QCDeviceCenter
//
//  Created by Wp on 2019/12/9.
//  Copyright © 2019 Reo. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (so)

///base64编码
+ (NSString *)base64Encode:(id)object;

/// 解码base64字符串
+ (id)base64Decode:(NSString *)base64String;

+ (BOOL)isEmptyWithObject:(id)obj;

@end

NS_ASSUME_NONNULL_END
