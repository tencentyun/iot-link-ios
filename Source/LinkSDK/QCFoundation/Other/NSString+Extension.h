//
//  NSString+Extension.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/29.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extension)

/**
 字典数组转为json

 @param obj 字典或者数组对象
 @return json字符串
 */
+ (NSString *)objectToJson:(id)obj;

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
 手机号格式校验
 */
+ (BOOL)judgePhoneNumberLegal:(NSString *)phoneNum;


/// 获取当前时间时间戳
+ (NSString *)getNowTimeString;

///时间戳转日期
+ (NSString *)convertTimestampToTime:(id)timestamp byDateFormat:(NSString *)format;

///时间转特定格式的字符串
+ (NSString *)converDataToFormat:(NSString *)format withData:(NSDate *)date;

///获取UTC格式时间
+ (NSString *)getNowUTCTimeString;


///base64编码
+ (NSString *)base64Encode:(id)object;

///base64解码
+ (id)base64Decode:(NSString *)base64;


/// HmacSha1->base64
+ (NSString *)HmacSha1:(NSString *)key data:(NSString *)data;

/// 获取网关
+ (NSString *)getGateway;
/// 获取网关IP
+ (NSString *)getGatewayIP;

/// 检测中文
+ (BOOL)matchSinogram:(NSString *)checkString;

/// 检测版本号  要求，必须是三位，x.x.x的形式  每位x的范围分别为1-99,0-99,0-99。
+ (NSString *)matchVersionNum:(NSString *)checkString;

/// 判断是否是纯数字
+ (BOOL)isPureIntOrFloat:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
