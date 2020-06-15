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

///获取UTC格式时间
+ (NSString *)getNowUTCTimeString;


///base64编码
+ (NSString *)base64Encode:(id)object;

///base64解码
+ (id)base64Decode:(NSString *)base64;


/// HmacSha1->base64
+ (NSString *)HmacSha1:(NSString *)key data:(NSString *)data;
@end

NS_ASSUME_NONNULL_END
