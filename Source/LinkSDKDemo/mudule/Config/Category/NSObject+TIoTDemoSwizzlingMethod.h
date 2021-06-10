//
//  NSObject+TIoTDemoSwizzlingMethod.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TIoTDemoSwizzlingMethod)
+ (void)swizzlingMethod:(SEL)method replace:(SEL)replaceMethod;
@end

NS_ASSUME_NONNULL_END
