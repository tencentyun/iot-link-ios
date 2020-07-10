//
//  NSObject+additions.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/8.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (additions)

+ (BOOL)isNullOrNilWithObject:(id)object;
+ (id)base64Decode:(NSString *)base64String;
@end

NS_ASSUME_NONNULL_END
