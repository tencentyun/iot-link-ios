//
//  NSString+Extension.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TIoTTimeType) {
    TIoTTimeTypeYear,
    TIoTTimeTypeMonth,
    TIoTTimeTypeDay,
    TIoTTimeTypeHour,
    TIoTTimeTypeMinute,
    TIoTTimeTypeSecont,
};

@interface NSString (Extension)

/**
 字典数组转为json

 @param obj 字典或者数组对象
 @return json字符串
 */
+ (NSString *)objectToJson:(id)obj;

/**
 json 字符串中包括中文和转义字符 的 转化
 */
+ (NSString *)URLEncode:(NSString *)value;

/**
 json字符串转化为数组或者字典
 
 @param json 待转换的json
 @return 转换后的数组或者字典
 */
+(id)jsonToObject:(NSString *)json;



/// 字符串是否有数字和字母
/// @param pwd bool
+ (BOOL)judgePassWordLegal:(NSString*)pwd;


/// 邮箱是否合法
/// @param email 邮箱地址
+ (BOOL)judgeEmailLegal:(NSString *)email;

/**
 判断是否全是空格
 */
+ (BOOL)isFullSpaceEmpty:(NSString *)string;

/**
 手机号格式校验
 */
+ (BOOL)judgePhoneNumberLegal:(NSString *)phoneNum withRegionID:(NSString *)regionID;

//返回设置时区当前时间
+ (NSString *)getNowTimeStingWithTimeZone:(NSString *)tiemzone formatter:(NSString *)formatter;

/// 获取当前时间时间戳
+ (NSString *)getNowTimeString;

/// 计算两个时间戳的时间差
+ (NSInteger )timeDifferenceInfoWitFormTimeStamp:(NSTimeInterval )fromTimeStamp toTimeStamp:(NSTimeInterval )toTimeStamp dateFormatter:(NSString *)formatter timeType:(TIoTTimeType)timeType;

///时间戳转日期
+ (NSString *)convertTimestampToTime:(id)timestamp byDateFormat:(NSString *)format;

///字符串转时间戳
+ (NSString *)getTimeStampWithString:(NSString *)timeString withFormatter:(NSString *)formatter withTimezone:(NSString *)timezone;

///时间转时区
+ (NSString *)convertTimestampToTimeZone:(id)timestamp byDataFormat:(NSString *)format timezone:(NSString *)timezone;

///时间转特定格式的字符串
+ (NSString *)converDataToFormat:(NSString *)format withData:(NSDate *)date;

///获取UTC格式时间
+ (NSString *)getNowUTCTimeString;

/// UTC格式转固定标准字符串
+ (NSString *)getTimeToStr:(NSString *)timeStr withFormat:(NSString *)formatString withTimeZone:(NSString *)timeZone;

///base64编码
+ (NSString *)base64Encode:(id)object;

///base64解码
+ (id)base64Decode:(NSString *)base64;

//base64解码，上面的方法不是单纯的base64解码
+ (NSData *)decodeBase64String:(NSString *)base64Str;
+ (NSString *)decodeBase64ToString:(NSString *)base64Str;

/// HmacSha1->base64
+ (NSString *)HmacSha1:(NSString *)key data:(NSString *)data;

/// 获取网关
+ (NSString *)getGateway;

/// 检测中文
+ (BOOL)matchSinogram:(NSString *)checkString;

/// 检测版本号  要求，必须是三位，x.x.x的形式  每位x的范围分别为1-99,0-99,0-99。
+ (NSString *)matchVersionNum:(NSString *)checkString;

/// 判断是否是纯数字
+ (BOOL)isPureIntOrFloat:(NSString *)string;

/// 截取指定指定字符串之间的String
+ (NSString *)interceptingString:(NSString *)originString withFrom:(NSString *)startString end:(NSString *)endString;

///纯数字摄氏度转华氏度转换（模糊匹配 以F: 华氏  C: 摄氏）
+ (NSString *)changeTemperatureValue:(NSString *)temperatureString userConfig:(NSString *)configStrin;

/// 模糊匹配摄氏温度和华氏温度转换方法 (模糊匹配 以F: 华氏  C: 摄氏）
+ (NSString *)judepTemperatureWithUserConfig:(NSString *)configString templeUnit:(NSString *)unitString;

// 十六进制转换为普通字符串的。
+ (NSString *)stringFromHexString:(NSString *)hexString;

//普通字符串转换为十六进制的。
+ (NSString *)hexStringFromString:(NSString *)string;
+ (NSString *)hexStringFromData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
