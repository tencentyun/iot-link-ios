//
//  NSString+Extension.m
//  TenextCloud
//
//

#import "NSString+Extension.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "TIoTCoreWMacros.h"

#import <arpa/inet.h>
#import <ifaddrs.h>
#import "TIoTGetgateway.h"

union u{
    Float32 f;
    int32_t i;
}u;

@implementation NSString (Extension)

+ (NSString *)getNowTimeString{
    NSDate* date1 = [NSDate date];
    NSTimeInterval time1 =[date1 timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f",time1];
    return timeString;
}

+(NSString *)getNowTimeTimestamp {

    NSDate *datenow = [NSDate date];

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)];

    return timeSp;
}

+ (NSString *)getNowTimeStingWithTimeZone:(NSString *)tiemzone formatter:(NSString *)timeFormatter {
    
     NSDate *dateNow = [NSDate date];

    //以秒为单位先获取当前时区时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat: timeFormatter]; // 设置想要的格式，hh与HH的区别:分别表示12小时制,24小时制
     //设置时区,这一点对时间的处理很重要
    NSTimeZone *timeZoneObj = nil;
    if (!(tiemzone == nil || [tiemzone isEqualToString:@""])) {
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

+ (NSString *)getTimeToStr:(NSString *)timeStr withFormat:(NSString *)formatString withTimeZone:(NSString *)timeZone{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    if (timeZone == nil) {
        timeZone = @"Asia/Shanghai";
    }
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:timeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:timeStr];
    // 这里设置自己想要的格式 @"yyyy-MM-dd HH:mm:ss"
    if (formatString == nil) {
        formatString = @"yyyy-MM-dd HH:mm:ss";
    }
    [dateFormatter setDateFormat:formatString];
    
    NSString *locationTimeString=[dateFormatter stringFromDate:dateFormatted];
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

/// 计算两个时间戳的时间差
+ (NSInteger )timeDifferenceInfoWitFormTimeStamp:(NSTimeInterval )fromTimeStamp toTimeStamp:(NSTimeInterval )toTimeStamp dateFormatter:(NSString *)formatter timeType:(TIoTTimeType)timeType {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter?:@"YYYY-MM-dd HH:mm:ss"];
        //获取此时时间戳长度
    NSInteger timeInt = fromTimeStamp - toTimeStamp; //时间差
        
    NSInteger year = timeInt / (3600 * 24 * 30 *12);
    NSInteger month = timeInt / (3600 * 24 * 30);
    NSInteger day = timeInt / (3600 * 24);
    NSInteger hour = timeInt / 3600;
    NSInteger minute = timeInt / 60;
    NSInteger second = timeInt;
    
    switch (timeType) {
        case TIoTTimeTypeYear:
        {
            return year;
            break;
        }
        case TIoTTimeTypeMonth: {
            return month;
            break;
        }
        case TIoTTimeTypeDay: {
            return day;
            break;
        }
        case TIoTTimeTypeHour: {
            return hour;
            break;
        }
        case TIoTTimeTypeMinute: {
            return minute;
            break;
        }
        case TIoTTimeTypeSecont: {
            return second;
            break;
        }
        default:
            break;
    }
        
    
}

+ (NSString *)getTimeStampWithString:(NSString *)timeString withFormatter:(NSString *)formatter withTimezone:(NSString *)timezone{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:formatter]; //设定时间的格式
    if (timezone == nil || [timezone isEqualToString:@""]) {
        dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    }else {
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:timezone];
    }
    
    NSDate *tempDate = [dateFormatter dateFromString:timeString];//将字符串转换为时间对象
    NSString *timeStr = [NSString stringWithFormat:@"%ld", (long)[tempDate timeIntervalSince1970]];//字符串转成时间戳,精确到毫秒*1000
    return timeStr;
}

+ (NSString *)getDayFormatTimeFromSecond:(NSString *)secondTime{
    
    NSInteger seconds = [secondTime integerValue];
    
    NSString *hourString = [NSString stringWithFormat:@"%02ld",seconds/3600];
    
    NSString *minuteString = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    
    NSString *secondString = [NSString stringWithFormat:@"%02ld",seconds%60];
    
    NSString *formatTimeString = [NSString stringWithFormat:@"%@:%@:%@",hourString,minuteString,secondString];
    
    if (seconds == 0 || seconds == 86400) {
        return formatTimeString = @"00:00:00";
    }
    return formatTimeString;
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

+ (NSString *)URLEncode:(NSString *)value
{
  return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                               (CFStringRef)value,
                                                                               NULL, // characters to leave unescaped
                                                                               CFSTR(":!*();@/&?+$,='"),
                                                                               kCFStringEncodingUTF8);
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


/// NSData 转16进制
+ (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

// NSData 转 16进制
+ (NSString *)transformStringWithData:(NSData *)data {
     NSString *result;
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    if (!dataBuffer) {
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; i++) {
        //02x 表示两个位置 显示的16进制
        [hexString appendString:[NSString stringWithFormat:@"%02lx",(unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    
    return result;
}
/// 16进制 转 data
+ (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

//16进制字符串 获取外设Mac地址
+ (NSString *)macAddressWith:(NSString *)aString{
    NSMutableString *macString = [[NSMutableString alloc] init];
        if (aString.length %2 == 0) {
            if (aString.length == 2) {
                [macString appendString:[[aString substringWithRange:NSMakeRange(0, 2)] uppercaseString]];
            }else {
                for (int i = 0; i<aString.length; i+=2) {
                        [macString appendString:[[aString substringWithRange:NSMakeRange(i, 2)] uppercaseString]];
                    
                    if (i+2 < aString.length) {
                        [macString appendString:@":"];
                    }
                }
            }
            
        }
    return macString;
}

/// 16进制转byte 格式的NSdata
+ (NSData *)hexstringToBytes:(NSString *)hexString {
    int j=0;
    Byte bytes[hexString.length / 2];
    for(int i=0;i<[hexString length];i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
        {
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        }
        else if(hex_char1 >= 'A' && hex_char1 <='F')
        {
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        }
        else
        {
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        }
        i++;
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
        {
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        }
        else if(hex_char1 >= 'A' && hex_char1 <='F')
        {
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        }
        else
        {
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        }
        int_ch = int_ch1+int_ch2;
        DDLogInfo(@"int_ch=%d",int_ch);
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:hexString.length / 2];
    return newData;
    
}

///16进制与2进制互转
+ (NSString *)getBinaryByhexString:(NSString *)hex binaryString:(NSString *)binary{
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] init];
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"a"];
    [hexDic setObject:@"1011" forKey:@"b"];
    [hexDic setObject:@"1100" forKey:@"c"];
    [hexDic setObject:@"1101" forKey:@"d"];
    [hexDic setObject:@"1110" forKey:@"e"];
    [hexDic setObject:@"1111" forKey:@"f"];

    NSMutableString *binaryStr=[[NSMutableString alloc] init];
    if (hex.length) {
        for (int i=0; i<[hex length]; i++) {
            NSRange rage;
            rage.length = 1;
            rage.location = i;
            NSString *key = [hex substringWithRange:rage];
            [binaryStr appendString:hexDic[key]];
        }
    }else{
        for (int i=0; i<binary.length; i+=4) {
            NSString *subStr = [binary substringWithRange:NSMakeRange(i, 4)];
            int index = 0;
            for (NSString *str in hexDic.allValues) {
                index ++;
                if ([subStr isEqualToString:str]) {
                    [binaryStr appendString:hexDic.allKeys[index-1]];
                    break;
                }
            }
        }
    }
    return binaryStr;
}

/// 字符串精度截取
+ (NSString *)getPrecisionStringWithOriginValue:(NSString *)originString precisionString:(NSString *)precisionString {
    NSString * result = @"";
    NSString *stepString = precisionString?:@".1";
    NSString *stepNumber = [stepString componentsSeparatedByString:@"."].lastObject ?:@"1";
    
    NSInteger floatNumber = 0;
    for (int i = 0; i < stepNumber.length; i++) {
        NSString * subString = [stepString substringToIndex:i];
        if (subString.intValue == 0) {
            floatNumber ++ ;
        }else if (subString.intValue == 1) {
            floatNumber ++;
            break;
        }

    }
    
    NSDecimalNumberHandler *valueHandlar = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:floatNumber raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    
    NSString *sliderValue = originString;
    
    NSDecimalNumber *valueNumber =  [NSDecimalNumber decimalNumberWithString:sliderValue?:@""];
    result = [NSString stringWithFormat:@"%@",[valueNumber decimalNumberByRoundingAccordingToBehavior:valueHandlar]];
    return result;
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
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    NSError *error = nil;
    id payload = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (error == nil) {
        return payload;
    }
    
    return @{};
}

+ (NSData *)decodeAsData:(NSString *)string {
    if (!string) {
        return nil;
    }
    
    int needPadding = string.length % 4;
    if (needPadding > 0) {
        needPadding = 4 - needPadding;
        string = [string stringByPaddingToLength:string.length+needPadding withString:@"=" startingAtIndex:0];
    }
    
    return [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

+ (NSData *)decodeBase64String:(NSString *)base64Str {
    
    NSData *data = [self decodeAsData:base64Str];
    return data;
//    if (!data) {
//        return nil;
//    }
//    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

//base64解码，上面的方法不是单纯的base64解码
+ (NSString *)decodeBase64ToString:(NSString *)base64Str {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    NSString *base64DecodeStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64DecodeStr;
}
// MD5加密  32位 大写
+ (NSString *)MD5ForUpper32Bate:(NSString *)string {
    
    //要进行UTF8的转码
    const char* input = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    
    return digest;
}
//小写
+ (NSString *)MD5ForLower32Bate:(NSString *)string {
    
    //要进行UTF8的转码
    const char* input = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
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

+ (BOOL)judgePhoneNumberLegal:(NSString *)phoneNum withRegionID:(NSString *)regionID;
{
//    ‘en-US’: /^(1?|(1\-)?)\d{10,12}$/
//    'en-US': /^(\+?1)?[2-9]\d{2}[2-9](?!11)\d{6}$/
    NSString *regex = @"^1\\d{10}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    NSString *regexUS = @"^[0-9]\\d{9}$";
    NSPredicate *predUS = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexUS];
    
    
    if (regionID != nil) {
        if ([regionID isEqualToString:@"1"]) { //国内
            if ([pred evaluateWithObject:phoneNum]) {
                return YES;
            }else {
                return NO;
            }
        }else if ([regionID isEqualToString:@"22"]) {//美东
            if ([predUS evaluateWithObject:phoneNum]) {
                return YES;
            }else {
                return NO;
            }
        }else {
            if ([pred evaluateWithObject:phoneNum] || [predUS evaluateWithObject:phoneNum]) {
                return  YES;
            }else {
                return NO;
            }
        }
    }else {
        return NO;
    }
}

+ (NSString *)HmacSha1:(NSString *)key data:(NSString *)data
{
    if ([NSString matchSinogram:data]) {
        return @"";
    }
    
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

//方法是将加密结果转成了十六进制字符串了 key为String text 类型
+ (NSString *)HmacSha1_hex:(NSString *)key data:(NSString *)data
{
    if ([NSString matchSinogram:data]) {
        return @"";
    }
    
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];

    //sha1
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hexString = [self hexStringFromData:HMAC];
    
    return hexString;
}

//将加密结果转成了十六进制字符串 key为hex 类型hash; 输入的key为16进制string
+ (NSString *)HmacSha1_Keyhex:(NSString *)key data:(NSString *)data
{
        
        NSData *keyData = [self dataFromHexString:key];
        
        const char *cKey  = [keyData bytes];
        
        const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];

        //sha1
        unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA1, cKey, keyData.length, cData, strlen(cData), cHMAC);

        NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
        NSString *hexString = [self hexStringFromData:HMAC];
        
        return hexString;
}

// 十六进制转Data
+ (NSData *)dataFromHexString:(NSString *)sHex {
    const char *chars = [sHex UTF8String];
    int i = 0;
    NSUInteger len = sHex.length;

    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;

    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }

    return data;
}

+ (NSString *)getGateway {
    NSString *ipString = nil;
    struct in_addr gatewayaddr;
    int r = getdefaultgateway(&(gatewayaddr.s_addr));
    if(r >= 0) {
        ipString = [NSString stringWithFormat: @"%s",inet_ntoa(gatewayaddr)];
        DDLogInfo(@"default gateway : %@", ipString );
    } else {
        DDLogInfo(@"getdefaultgateway() failed");
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
        if ([unitString containsString:NSLocalizedString(@"celsius_Hanzi", @"摄氏")] || [unitString containsString:@"℃"]) {
            return [self chanageTemperatureUnitWith:unitString];
        }else {
            return unitString;
        }
    }else if ([configString isEqualToString:@"C"]) {
        if ([unitString containsString:NSLocalizedString(@"Fahrenheit_Hanzi", @"华氏")] || [unitString containsString:@"℉"]) {
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
    
        if ([temperatureString containsString:NSLocalizedString(@"celsius_Hanzi", @"摄氏")] || [temperatureString containsString:@"℃"]) {
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"℃" withString:@""];
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:NSLocalizedString(@"celsius_Hanzi", @"摄氏") withString:@""];
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
            
        }else if ([temperatureString containsString:NSLocalizedString(@"Fahrenheit_Hanzi", @"华氏")] || [temperatureString containsString:@"℉"]){
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"℉" withString:@""];
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:NSLocalizedString(@"Fahrenheit_Hanzi", @"华氏") withString:@""];
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

//判断是否全是空格
+ (BOOL)isFullSpaceEmpty:(NSString *)string {
    if (!string) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [string stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }

}

//10进制转16进制
+ (NSString *)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
            
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}

+ (NSInteger )getDecimalByHex:(NSString *)hex {
    NSString * decimal = [NSString stringWithFormat:@"%lu",strtoul([hex UTF8String],0,16)];
    return decimal.integerValue;
}

// 十六进制转换为普通字符串的。
+ (NSString*)stringFromHexString:(NSString*)hexString
{
    NSMutableString *strAscii = [NSMutableString string];
    for (int i=0;i<hexString.length;i+=2) {
        NSString *charValue = [hexString substringWithRange:NSMakeRange(i,2)];
        unsigned int _byte;
        [[NSScanner scannerWithString:charValue] scanHexInt: &_byte];
        if (_byte >= 32 && _byte < 127) {
            [strAscii appendFormat:@"%c", _byte];
            
        } else if(_byte == 0) {
            [strAscii appendString:@"NUL"];
        } else {
            [strAscii appendFormat:@"[%d]", _byte];
        }
    }
    DDLogInfo(@"Hex: %@", hexString);
    DDLogInfo(@"Ascii: %@", strAscii);
    return strAscii;
}
/*
+ (NSString *)stringFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
    
    
}*/

//普通字符串转换为十六进制的。

+ (NSString *)hexStringFromString:(NSString *)string{
    if (string == nil) {
        return @"";
    }
    
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+ (NSString *)hexStringFromData:(NSData *)data {
    if (data == nil) {
        return @"";
    }
    Byte *bytes = (Byte *)[data bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

// NSData转16进制 第一种
+ (NSString *)getDataFromHexStr:(NSData *)data {
   if (!data || [data length] == 0) {
       return @"";
   }
   NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
   
   [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
       unsigned char *dataBytes = (unsigned char*)bytes;
       for (NSInteger i = 0; i < byteRange.length; i++) {
           NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
           if ([hexStr length] == 2) {
               [string appendString:hexStr];
           } else {
               [string appendFormat:@"0%@", hexStr];
           }
       }
   }];
   return string;
}

//十进制转二进制
+ (NSString *)getBinaryByDecimal:(NSInteger)decimalism {
    NSString *binary = @"";
        while (decimalism) {
            
            binary = [[NSString stringWithFormat:@"%ld", decimalism % 2] stringByAppendingString:binary];
            if (decimalism / 2 < 1) {
                
                break;
            }
            decimalism = decimalism / 2 ;
        }
        if (binary.length % 4 != 0) {
            
            NSMutableString *mStr = [[NSMutableString alloc]init];;
            for (int i = 0; i < 4 - binary.length % 4; i++) {
                
                [mStr appendString:@"0"];
            }
            binary = [mStr stringByAppendingString:binary];
        }
        return binary;
}

//2进制转10进制
+ (NSInteger)getDecimalByBinary:(NSString *)binary {
    
    NSInteger decimal = 0;
    for (int i=0; i<binary.length; i++) {
        
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            
            decimal += pow(2, i);
        }
    }
    return decimal;
}

//16进制字符串逆序
+ (NSString *)reverseWordsInString:(NSString *)oldString {
    NSMutableString *newString = [NSMutableString stringWithCapacity:oldString.length];
    NSMutableString *tempString = [NSMutableString stringWithCapacity:2];
    
    for (int i = (int)oldString.length - 1; i >= 0; i--) {
        
        unichar character = [oldString characterAtIndex:i];
        
        if (i%2 == 0) {
            [tempString appendFormat:@"%c",character];
            
            NSMutableString *string= [[NSMutableString alloc] init];
            
            for(int i = 0; i < tempString.length; i++){
                [string appendString:[tempString substringWithRange:NSMakeRange(tempString.length-i-1, 1)]];
            }
            
            tempString = string;
            
            [newString appendFormat:@"%@",tempString];
            [tempString deleteCharactersInRange:NSMakeRange(0, 2)];
            
        }else {
            [tempString appendFormat:@"%c",character];
        }
        
    }
    return newString;
}

//2进制转16进制
+ (NSString *)getHexByBinary:(NSString *)binary {
    
    NSMutableDictionary *binaryDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [binaryDic setObject:@"0" forKey:@"0000"];
    [binaryDic setObject:@"1" forKey:@"0001"];
    [binaryDic setObject:@"2" forKey:@"0010"];
    [binaryDic setObject:@"3" forKey:@"0011"];
    [binaryDic setObject:@"4" forKey:@"0100"];
    [binaryDic setObject:@"5" forKey:@"0101"];
    [binaryDic setObject:@"6" forKey:@"0110"];
    [binaryDic setObject:@"7" forKey:@"0111"];
    [binaryDic setObject:@"8" forKey:@"1000"];
    [binaryDic setObject:@"9" forKey:@"1001"];
    [binaryDic setObject:@"A" forKey:@"1010"];
    [binaryDic setObject:@"B" forKey:@"1011"];
    [binaryDic setObject:@"C" forKey:@"1100"];
    [binaryDic setObject:@"D" forKey:@"1101"];
    [binaryDic setObject:@"E" forKey:@"1110"];
    [binaryDic setObject:@"F" forKey:@"1111"];
    
    if (binary.length % 4 != 0) {
        
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    NSString *hex = @"";
    for (int i=0; i<binary.length; i+=4) {
        
        NSString *key = [binary substringWithRange:NSMakeRange(i, 4)];
        NSString *value = [binaryDic objectForKey:key];
        if (value) {
            
            hex = [hex stringByAppendingString:value];
        }
    }
    return hex;
}

+ (NSString *)getBinaryByHex:(NSString *)hex {
    
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[hex length]; i++) {
        
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}

//16进制转浮点型
+ (float)getFloatByHex:(NSString *)hexString {
    NSString *revertHex = [self reverseWordsInString:hexString?:@""];
    NSString *tempStr = [NSString stringWithFormat:@"0x%@",[revertHex uppercaseString]];
    sscanf([tempStr UTF8String], "%x", &u.i);
    float floatValue = u.f;
    return floatValue;
}

//浮点数转16进制
+ (NSString *)getHexByFloat:(float )floatValue {

    NSString *hexTempString = [NSString stringWithFormat:@"%X",*(int*)&floatValue];
    NSString *hexString = [self reverseWordsInString:hexTempString?:@""];
    return hexString;
}

// 获取标识符
+ (NSString *)getBindIdentifierWithProductId:(NSString *)productId deviceName:(NSString *)deviceName {
    
    NSString *deviceIdString = [NSString stringWithFormat:@"%@%@",productId,deviceName];
    NSString *deviceMd5String = [NSString MD5ForUpper32Bate:deviceIdString];
    NSString *deviceIdPreHex = [deviceMd5String substringToIndex:16];
    NSString *deviceIdEndHex = [deviceMd5String substringFromIndex: deviceMd5String.length - 16];
    
    NSInteger deviceIdPreInt = strtoul([deviceIdPreHex UTF8String],0,16);
    NSInteger deviceIdEndInt = strtoul([deviceIdEndHex UTF8String],0,16);
    NSInteger resultInt = deviceIdPreInt ^ deviceIdEndInt;
    NSString *resuleStringHex = [[NSString stringWithFormat:@"%lx",(long)resultInt] uppercaseString];
    
    return resuleStringHex;
}

//获取固定长度的字符串 不足为补0
+ (NSString *)getFixedLengthValueWithOriginValue:(NSString *)originValue bitString:(NSString *)bitString {
    NSString *value = @"";
    NSString *preTempValue = [bitString substringToIndex:bitString.length - originValue.length];
    NSString *resultValue= [NSString stringWithFormat:@"%@%@",preTempValue,originValue];
    value = resultValue;
    return value;
}

//将字符串转为浮点型（0.0.1）
+ (NSString *)getVersionWithString:(NSString *)originVersionString {
    NSString *versionString = @"";
    NSArray *versionArray = [originVersionString componentsSeparatedByString:@"."];
    for (NSString *numStr in versionArray) {
        versionString = [versionString stringByAppendingString:numStr];
    }
    return versionString = [self getTheCorrectNum:versionString];
}

//去除字符串前端为0
+ (NSString*)getTheCorrectNum:(NSString*)tempString {
    while ([tempString hasPrefix:@"0"])
    {
        tempString = [tempString substringFromIndex:1];
    }
        return tempString;
}
@end
