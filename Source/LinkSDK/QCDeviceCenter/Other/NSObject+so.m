//
//  NSObject+so.m
//  QCDeviceCenter
//
//  Created by Wp on 2019/12/9.
//  Copyright © 2019 Reo. All rights reserved.
//

#import "NSObject+so.h"

@implementation NSObject (so)

///base64编码
+ (NSString *)base64Encode:(id)object{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    NSString *payloadStr = @"";
    if (error == nil) {
        payloadStr = [jsonData base64EncodedStringWithOptions:0];
    }
    
    return payloadStr;
}

+ (id)base64Decode:(NSString *)base64String{
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSError *error = nil;
    id payload = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (error == nil) {
        return payload;
    }
    
    return @{};
}


+ (BOOL)isEmptyWithObject:(id)obj
{
    if (obj == nil || [obj isEqual:[NSNull null]]) {
        return YES;
    }
    
    return NO;
}

@end
