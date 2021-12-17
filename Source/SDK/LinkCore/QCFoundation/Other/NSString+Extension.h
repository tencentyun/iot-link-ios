//
//  NSString+Extension.h
//  TenextCloud
//
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


/// NSData 转 16进制
/// @param data data
+ (NSString *)convertDataToHexStr:(NSData *)data;

/// NSData 转 16进制
+ (NSString *)transformStringWithData:(NSData *)data;
/// 16进制 转 data
+ (NSData *)convertHexStrToData:(NSString *)str;
/// 16进制字符串 获取外设Mac地址
+ (NSString *)macAddressWith:(NSString *)aString;
/// 16进制转byte 格式的NSdata
+ (NSData *)hexstringToBytes:(NSString *)hexString;
//16进制与2进制互转
+ (NSString *)getBinaryByhexString:(NSString *)hex binaryString:(NSString *)binary;

/**
 字符串精度截取
 */
+ (NSString *)getPrecisionStringWithOriginValue:(NSString *)originString precisionString:(NSString *)precisionString;

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

/// 获取当前毫秒时间戳
+(NSString *)getNowTimeTimestamp;

/// 计算两个时间戳的时间差
+ (NSInteger )timeDifferenceInfoWitFormTimeStamp:(NSTimeInterval )fromTimeStamp toTimeStamp:(NSTimeInterval )toTimeStamp dateFormatter:(NSString *)formatter timeType:(TIoTTimeType)timeType;

///时间戳转日期
+ (NSString *)convertTimestampToTime:(id)timestamp byDateFormat:(NSString *)format;

///字符串转时间戳
+ (NSString *)getTimeStampWithString:(NSString *)timeString withFormatter:(NSString *)formatter withTimezone:(NSString *)timezone;

///一天内秒转特定时间格式（xx:xx:xx）
+(NSString *)getDayFormatTimeFromSecond:(NSString *)secondTime;

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
//方法是将加密结果转成了十六进制字符串了 key为String text 类型 
+ (NSString *)HmacSha1_hex:(NSString *)key data:(NSString *)data;
//将加密结果转成了十六进制字符串 key为hex 类型hash; 输入的key为16进制string
+ (NSString *)HmacSha1_Keyhex:(NSString *)key data:(NSString *)data;

// MD5加密  32位 大写
+ (NSString *)MD5ForUpper32Bate:(NSString *)string;
//小写
+ (NSString *)MD5ForLower32Bate:(NSString *)string;

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

// 十六进制转Data
+ (NSData *)dataFromHexString:(NSString *)sHex;

// Data 转十六进制
+ (NSString *)getDataFromHexStr:(NSData *)data;

//10进制转16进制
+ (NSString *)getHexByDecimal:(NSInteger)decimal ;
//16进制转10进制
+ (NSInteger )getDecimalByHex:(NSString *)hex;

//普通字符串转换为十六进制的。
+ (NSString *)hexStringFromString:(NSString *)string;
+ (NSString *)hexStringFromData:(NSData *)data;

//十进制转二进制
+ (NSString *)getBinaryByDecimal:(NSInteger)decimalism;

//2进制转10进制
+ (NSInteger)getDecimalByBinary:(NSString *)binary;

//16进制字符串逆序
+ (NSString *)reverseWordsInString:(NSString *)oldString;

//2进制转16进制
+ (NSString *)getHexByBinary:(NSString *)binary;

//16进制转2进制
+ (NSString *)getBinaryByHex:(NSString *)hex;

//16进制转浮点型
+ (float)getFloatByHex:(NSString *)hexString;

//浮点数转16进制
+ (NSString *)getHexByFloat:(float )floatValue;

// 获取标识符
+ (NSString *)getBindIdentifierWithProductId:(NSString *)productId deviceName:(NSString *)deviceName;

//获取固定长度的字符串 不足为补0
+ (NSString *)getFixedLengthValueWithOriginValue:(NSString *)originValue bitString:(NSString *)bitString;

//将字符串转为浮点型（0.0.1）
+ (NSString *)getVersionWithString:(NSString *)originVersionString;

@end

NS_ASSUME_NONNULL_END
