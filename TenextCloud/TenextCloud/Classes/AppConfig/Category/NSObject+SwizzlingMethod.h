//
//  NSObject+SwizzlingMethod.h
//  SEEXiaodianpu
//
//  Created by 黄锐灏 on 2019/2/13.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SwizzlingMethod)

+ (void)swizzlingMethod:(SEL)method replace:(SEL)replaceMethod;

@end

NS_ASSUME_NONNULL_END
