//
//  NSObject+TIoTDemoSwizzlingMethod.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "NSObject+TIoTDemoSwizzlingMethod.h"
#import <objc/runtime.h>
@implementation NSObject (TIoTDemoSwizzlingMethod)

+ (void)swizzlingMethod:(SEL)method replace:(SEL)replaceMethod
{
    Method objc_method = class_getInstanceMethod([self class],method);
    
    Method objc_methodReplace = class_getInstanceMethod([self class], replaceMethod);
    
    BOOL success = class_addMethod([self class], method, class_getMethodImplementation([self class], replaceMethod), method_getTypeEncoding(objc_methodReplace));
    
    if (!success) {
        method_exchangeImplementations(objc_method, objc_methodReplace);
        
    }else{
        class_replaceMethod([self class], replaceMethod, method_getImplementation(objc_method), method_getTypeEncoding(objc_methodReplace));
    }
}

@end
