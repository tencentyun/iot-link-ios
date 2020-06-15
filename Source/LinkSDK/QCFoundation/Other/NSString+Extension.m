//
//  NSString+Extension.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "NSString+Extension.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@implementation NSString (Extension)

+ (NSString *)getNowTimeString{
    NSDate* date1 = [NSDate date];
    NSTimeInterval time1 =[date1 timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f",time1];
    return timeString;
}

///获取UTC格式时间
+ (NSString *)getNowUTCTimeString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss Z"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSString *locationTimeString = [dateFormatter stringFromDate:[NSDate date]];
    return locationTimeString;
}

+ (NSString *)convertTimestampToTime:(id)timestamp byDateFormat:(NSString *)format {

    long long time=[timestamp longLongValue];
    if ([NSString stringWithFormat:@"%@",timestamp].length == 13) {
        time = time / 1000;
    }
    
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time];

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];

    [formatter setDateFormat:format];

    NSString*timeString=[formatter stringFromDate:date];

    return timeString;

}

+ (NSString *)objectToJson:(id)obj{
    if (obj == nil) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:0
                                                         error:&error];
    
    if ([jsonData length] && error == nil){
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else{
        return nil;
    }
}

+ (id)jsonToObject:(NSString *)json{
    if (json == nil) {
        return nil;
    }
    //string转data
    NSData * jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    //json解析
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return obj;
}

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

///base64解码
+ (id)base64Decode:(NSString *)base64{
    NSData *data= [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    return obj;
}

+ (BOOL)judgePassWordLegal:(NSString*)pwd{

    BOOL result = false;
     if ([pwd length] >= 8 && [pwd length] <= 16){
     // 判断长度大于8位后再接着判断是否同时包含数字和字符
     NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$";
     NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
     result = [pred evaluateWithObject:pwd];
     }
     return result;

}

+ (BOOL)judgeEmailLegal:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)judgePhoneNumberLegal:(NSString *)phoneNum
{
    BOOL result = NO;
    NSString *regex = @"^1\\d{10}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    result = [pred evaluateWithObject:phoneNum];
    
    return result;
}

+ (NSString *)HmacSha1:(NSString *)key data:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];

    //sha1
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];

    NSString *hash = [HMAC base64EncodedStringWithOptions:0];//将加密结果进行一次BASE64编码。
    return hash;
}

@end
