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

#import <arpa/inet.h>
#import <ifaddrs.h>
#import "getgateway.h"

@implementation NSString (Extension)

+ (NSString *)getNowTimeString{
    NSDate* date1 = [NSDate date];
    NSTimeInterval time1 =[date1 timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f",time1];
    return timeString;
}

+ (NSString *)getNowTimeStingWithTimeZone:(NSString *)tiemzone formatter:(NSString *)timeFormatter {
    
     NSDate *dateNow = [NSDate date];

    //以秒为单位先获取当前时区时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat: timeFormatter]; // 设置想要的格式，hh与HH的区别:分别表示12小时制,24小时制
     //设置时区,这一点对时间的处理很重要
    NSTimeZone *timeZoneObj = nil;
    if (tiemzone == nil || [tiemzone isEqualToString:@""]) {
        timeZoneObj=[NSTimeZone timeZoneWithName:tiemzone];
    }else {
        timeZoneObj=[NSTimeZone systemTimeZone];
    }
     [formatter setTimeZone:timeZoneObj];

    NSString *timeString = [formatter stringFromDate:dateNow];
    
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

+ (NSString *)getTimeStampWithString:(NSString *)timeString withFormatter:(NSString *)formatter withTimezone:(NSString *)timezone{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:formatter]; //设定时间的格式
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:timezone];
    NSDate *tempDate = [dateFormatter dateFromString:timeString];//将字符串转换为时间对象
    NSString *timeStr = [NSString stringWithFormat:@"%ld", (long)[tempDate timeIntervalSince1970]];//字符串转成时间戳,精确到毫秒*1000
    return timeStr;
}

+ (NSString *)convertTimestampToTimeZone:(id)timestamp byDataFormat:(NSString *)format timezone:(NSString *)timezone {
    
    long long time=[timestamp longLongValue];
    if ([NSString stringWithFormat:@"%@",timestamp].length == 13) {
        time = time / 1000;
    }
    
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time];

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    formatter.timeZone = [NSTimeZone timeZoneWithName:timezone];
    
    [formatter setDateFormat:format];

    NSString*timeString=[formatter stringFromDate:date];

    return timeString;
    
}

+ (NSString *)converDataToFormat:(NSString *)format withData:(NSDate *)date {
    NSDate *destinationDate = date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];

    [formatter setDateFormat:format];

    NSString*timeString=[formatter stringFromDate:destinationDate];

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
//    ‘en-US’: /^(1?|(1\-)?)\d{10,12}$/
//    'en-US': /^(\+?1)?[2-9]\d{2}[2-9](?!11)\d{6}$/
    NSString *regex = @"^1\\d{10}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    NSString *regexUS = @"^[0-9]\\d{9}$";
    NSPredicate *predUS = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexUS];
    if ([pred evaluateWithObject:phoneNum] || [predUS evaluateWithObject:phoneNum]) {
        return  YES;
    }else {
        return NO;
    }
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

+ (NSString *)getGateway {
    NSString *ipString = nil;
    struct in_addr gatewayaddr;
    int r = getdefaultgateway(&(gatewayaddr.s_addr));
    if(r >= 0) {
        ipString = [NSString stringWithFormat: @"%s",inet_ntoa(gatewayaddr)];
        NSLog(@"default gateway : %@", ipString );
    } else {
        NSLog(@"getdefaultgateway() failed");
    }
    
    return ipString;
}

+ (BOOL)matchSinogram:(NSString *)checkString {
    if (checkString == nil || [checkString isEqualToString:@""]) {
        return NO;
    }
    
    NSString *pattern = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:checkString options:0 range:NSMakeRange(0, checkString.length)];
    if (results.count > 0) {
        return YES;
    }
    return NO;
}


+ (NSString *)matchVersionNum:(NSString *)checkString {
    if (checkString == nil || [checkString isEqualToString:@""]) {
        return @"";
    }
    
    NSString *pattern = @"([1-9]\\d|[1-9])(\\.([1-9]\\d|\\d)){2}";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSArray *results = [regular matchesInString:checkString options:0 range:NSMakeRange(0, checkString.length)];
    if (results.count > 0) {
        NSTextCheckingResult* result = results[0];
        //从NSTextCheckingResult类中取出range属性
        NSRange range = result.range;
        //从原文本中将字段取出并存入一个NSMutableArray中
        NSString *string = [checkString substringWithRange:range];
        return string;
    }
    return @"";
}


+ (BOOL)isPureIntOrFloat:(NSString *)string {
    
    NSScanner* scanInt = [NSScanner scannerWithString:string];
    int valInt;
    
    NSScanner* scanFloat = [NSScanner scannerWithString:string];
    float valFloat;
    
    if (([scanInt scanInt:&valInt] && [scanInt isAtEnd]) || ([scanFloat scanFloat:&valFloat] && [scanFloat isAtEnd])) {
        return YES;
    }else {
        return NO;
    }
    
}

+ (NSString *)interceptingString:(NSString *)originString withFrom:(NSString *)startString end:(NSString *)endString {
    NSRange startRange = [originString rangeOfString:startString];
    NSRange endRange = [originString rangeOfString:endString];
    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location + 1  - startRange.location - startRange.length);
    NSString *result = [originString substringWithRange:range];
    return result;
}

///纯数字摄氏度转华氏度转换（模糊匹配 以F: 华氏  C: 摄氏）
+ (NSString *)changeTemperatureValue:(NSString *)temperatureString userConfig:(NSString *)configString {
    if ([configString isEqualToString:@"F"]) {
        if ([NSString isPureIntOrFloat:[temperatureString copy]]) {
            if (@available(iOS 10.0, *)) {
                NSMeasurement *measurement = [[NSMeasurement alloc]initWithDoubleValue:temperatureString.floatValue unit:NSUnitTemperature.fahrenheit];
                NSMeasurement *celsiusMeasurement = [measurement measurementByConvertingToUnit:NSUnitTemperature.celsius];
                return [NSString stringWithFormat:@"%f",celsiusMeasurement.doubleValue];
            } else {
                // Fallback on earlier versions
                return temperatureString;
            }
        }else {
            return temperatureString;
        }
    }else if ([configString isEqualToString:@"C"]) {
        if ([NSString isPureIntOrFloat:[temperatureString copy]]) {
            if (@available(iOS 10.0, *)) {
                NSMeasurement *measurement = [[NSMeasurement alloc]initWithDoubleValue:temperatureString.floatValue unit:NSUnitTemperature.celsius];
                NSMeasurement *fahrenheitMeasurement = [measurement measurementByConvertingToUnit:NSUnitTemperature.fahrenheit];
                return [NSString stringWithFormat:@"%f",fahrenheitMeasurement.doubleValue];
            } else {
                // Fallback on earlier versions
                return temperatureString;
            };
            
        }else {
            return temperatureString;
        }
    }else {
        return temperatureString;
    }
}

+ (NSString *)judepTemperatureWithUserConfig:(NSString *)configString templeUnit:(NSString *)unitString {
    if ([configString isEqualToString:@"F"]) {
        if ([unitString containsString:@"摄氏"] || [unitString containsString:@"℃"]) {
            return [self chanageTemperatureUnitWith:unitString];
        }else {
            return unitString;
        }
    }else if ([configString isEqualToString:@"C"]) {
        if ([unitString containsString:@"华氏"] || [unitString containsString:@"℉"]) {
            return [self chanageTemperatureUnitWith:unitString];
        }else {
            return unitString;
        }
    }else {
        return unitString;
    }
}

///字符串模糊匹配摄氏度与华氏度转化 （"摄氏" "℃" "华氏" "℉"）
+ (NSString *)chanageTemperatureUnitWith:(NSString *)temperatureString {
    
        if ([temperatureString containsString:@"摄氏"] || [temperatureString containsString:@"℃"]) {
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"℃" withString:@""];
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"摄氏" withString:@""];
            if ([NSString isPureIntOrFloat:[temperatureString copy]]) {
                if (@available(iOS 10.0, *)) {
                    NSMeasurement *measurement = [[NSMeasurement alloc]initWithDoubleValue:temperatureString.floatValue unit:NSUnitTemperature.fahrenheit];
                    NSMeasurement *celsiusMeasurement = [measurement measurementByConvertingToUnit:NSUnitTemperature.celsius];
                    return [NSString stringWithFormat:@"%f℉",celsiusMeasurement.doubleValue];
                } else {
                    // Fallback on earlier versions
                    return [NSString stringWithFormat:@"%@℉",temperatureString];
                }
            }else {
                return [NSString stringWithFormat:@"%@℉",temperatureString];
            }
            
        }else if ([temperatureString containsString:@"华氏"] || [temperatureString containsString:@"℉"]){
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"℉" withString:@""];
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"华氏" withString:@""];
            if ([NSString isPureIntOrFloat:[temperatureString copy]]) {
                if (@available(iOS 10.0, *)) {
                    NSMeasurement *measurement = [[NSMeasurement alloc]initWithDoubleValue:temperatureString.floatValue unit:NSUnitTemperature.celsius];
                    NSMeasurement *fahrenheitMeasurement = [measurement measurementByConvertingToUnit:NSUnitTemperature.fahrenheit];
                    return [NSString stringWithFormat:@"%f℃",fahrenheitMeasurement.doubleValue];
                } else {
                    // Fallback on earlier versions
                    return [NSString stringWithFormat:@"%@℃",temperatureString];
                }
                
            }else {
                return [NSString stringWithFormat:@"%@℃",temperatureString];
            }
        }else {
            return temperatureString;
        }
}
@end
