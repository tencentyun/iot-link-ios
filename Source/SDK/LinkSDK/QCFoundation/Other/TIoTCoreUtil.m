//
//  TIoTCoreUtil.m
//  Pods
//
//  Created by eagleychen on 2020/8/27.
//

#import "TIoTCoreUtil.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "NSString+Extension.h"
#import "TIoTVideoDistributionNetModel.h"
#import <objc/runtime.h>
#import "TIoTCoreAddDevice.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@interface TIoTCoreUtil ()<TIoTCoreAddDeviceDelegate>
@property (nonatomic, strong) TIoTCoreSoftAP   *softAP;
@end

@implementation TIoTCoreUtil

+ (NSDictionary *)getWifiSsid{
    
   NSDictionary *wifiDic;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
    
            wifiDic = @{@"name":[networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID],@"bssid":[networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeyBSSID]};
            NSLog(@"network info -> %@", wifiDic);
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiDic;
}


+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    
    UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
    resultVC = [self _topViewController:[mainWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

/**
 二维码扫码配网
 */
+ (UIImage *)generateQrCodeNetWorkInfo:(TIoTVideoDistributionNetModel *)infoModel imageSize:(CGSize )size{
    if (infoModel == nil) {
        return nil;
    }
    
    NSArray *keyArray = [self getObjectKeyArray:infoModel];
    NSDictionary *dic = [infoModel dictionaryWithValuesForKeys:keyArray];
    NSString *infoJsonString = [NSString objectToJson:dic];
    
    UIImage *image = [self qrCodeImageWithInfo:infoJsonString size:size]?:[UIImage new];
     
    return  image;
}


/**
生成二维码
 */
+ (UIImage *)qrCodeImageWithInfo:(NSString *)info size:(CGSize)size

{
    if (!info) {
        return nil;
    }
    
    NSData *strData = [info dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    
    //创建二维码滤镜
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [qrFilter setValue:strData forKey:@"inputMessage"];
    
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    
    CGRect qrRect = qrImage.extent;
    CGImageRef imageRef = [[CIContext context] createCGImage:qrImage fromRect:qrRect];
    CGFloat scale = fminf(size.width / qrRect.size.width, size.width / qrRect.size.height) * [UIScreen mainScreen].scale;
    size_t contextW = ceilf(qrRect.size.width * scale);
    size_t contextH = ceilf(qrRect.size.height * scale);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef contextRef = CGBitmapContextCreate(nil, contextW, contextH, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpaceRef);
    
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, scale, scale);
    CGContextDrawImage(contextRef, qrRect, imageRef);
    CGImageRelease(imageRef);
    
    CGImageRef resultImageRef = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    
    UIImage *resultImage = [UIImage imageWithCGImage:resultImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(resultImageRef);
    
    return resultImage;
    
}

+ (NSArray <NSString *>*)getObjectKeyArray:(TIoTVideoDistributionNetModel *)model {
    
    u_int keyCount;
    objc_property_t *properties  =class_copyPropertyList([model class], &keyCount);
    NSMutableArray *propertiesArray = [NSMutableArray array];
    for (int k = 0; k < keyCount; k++)
    {
        const char *propertyName = property_getName(properties[k]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;

}

+ (NSString *)generateSignature:(NSDictionary *)allParams params:(NSDictionary *)params server:(NSString *)serverHost{
    NSString *contentType = @"application/json; charset=utf-8";
    //1.拼接规范请求串
    NSString *httpRequestMethod = @"POST";
    NSString *canonicalURI = @"/";
    NSString *canonicalQueryString = @"";
    
    NSString *canonicalHeaders = [NSString stringWithFormat:@"content-type:%@\nhost:%@.tencentcloudapi.com\n", contentType,serverHost?:@""];
    NSString *signedHeaders = @"content-type;host";
    
    NSString *payload = [self qcloudasrutil_sortedJSONTypeQueryParams:allParams];
    NSString *hashedRequestPayload = [[TIoTCoreUtil qcloudasrutil_SHA256Hex:payload] lowercaseString];
    
    NSLog(@"payload %@ hashedRequestPayload %@", payload, hashedRequestPayload);
    
    NSMutableString *canonicalRequest = [[NSMutableString alloc] init];
    [canonicalRequest appendFormat:@"%@\n", httpRequestMethod];
    [canonicalRequest appendFormat:@"%@\n", canonicalURI];
    [canonicalRequest appendFormat:@"%@\n", canonicalQueryString];
    [canonicalRequest appendFormat:@"%@\n", canonicalHeaders];
    [canonicalRequest appendFormat:@"%@\n", signedHeaders];
    [canonicalRequest appendFormat:@"%@", hashedRequestPayload];
    
    NSLog(@"canonicalRequest %@", canonicalRequest);
    
    //2. 拼接待签名字符串
    static NSDateFormatter *yyyy_mm_ddFormatter;
    if (!yyyy_mm_ddFormatter) {
        yyyy_mm_ddFormatter = [[NSDateFormatter alloc] init];
        yyyy_mm_ddFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [yyyy_mm_ddFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    
    NSString *service = serverHost?:@"";
    NSString *algorithm = @"TC3-HMAC-SHA256";
    NSString *requestTimestamp = [params objectForKey:@"X-TC-Timestamp"];
    NSString *date = [yyyy_mm_ddFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:requestTimestamp.integerValue]];
    NSString *credentialScope = [NSString stringWithFormat:@"%@/%@/%@", date, service, @"tc3_request"];
    NSString *hashedCanonicalRequest = [[TIoTCoreUtil qcloudasrutil_SHA256Hex:canonicalRequest] lowercaseString];
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", algorithm, requestTimestamp, credentialScope, hashedCanonicalRequest];
    
//    NSString *service = @"cvm";
//    NSString *algorithm = @"TC3-HMAC-SHA256";
//    NSString *requestTimestamp = @"1551113065";
//    NSString *date = @"2019-02-25";
//    NSString *credentialScope = [NSString stringWithFormat:@"%@/%@/%@", date, service, @"tc3_request"];
//    NSString *hashedCanonicalRequest = [[QCloudASRUtil qcloudasrutil_SHA256Hex:canonicalRequest] lowercaseString];
//    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", algorithm, requestTimestamp, credentialScope, hashedCanonicalRequest];
    
    NSLog(@"stringToSign %@", stringToSign);
    
    //3. 计算签名
    NSString *secretKey = [params objectForKey:@"secretKey"];//params.secretKey;
    NSString *key = [NSString stringWithFormat:@"TC3%@", secretKey];
    
//    NSString *secretDate = [self qcloudasrutil_HmacSha256:key data:date];
//    QCloudASRLogDebug(@"secretDate %@", secretDate);
    const char *cKey  = [key UTF8String];
    const char *cData = [date UTF8String];
    unsigned char cDateHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cDateHMAC);
    
//    NSString *secretService = [self qcloudasrutil_HmacSha256:secretDate data:service];
//    QCloudASRLogDebug(@"secretService %@", secretService);
    cData = [service UTF8String];
    unsigned char cServiceHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cDateHMAC, sizeof(cDateHMAC), cData, strlen(cData), cServiceHMAC);
    
//    NSString *secretSigning = [self qcloudasrutil_HmacSha256:secretService data:@"tc3_request"];
//    QCloudASRLogDebug(@"secretSigning %s", secretSigning);
    cData = [@"tc3_request" UTF8String];
    unsigned char cSignHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cServiceHMAC, sizeof(cServiceHMAC), cData, strlen(cData), cSignHMAC);
    
//    NSString *signature = @"";//[self qcloudasrutil_HmacSha256:secretSigning data:stringToSign];
//    QCloudASRLogDebug(@"secretSigning %s", secretSigning);
    cData = [stringToSign UTF8String];
    unsigned char cSignatureHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cSignHMAC, sizeof(cSignHMAC), cData, strlen(cData), cSignatureHMAC);
    
    NSData *HMACData = [NSData dataWithBytes:cSignatureHMAC length:sizeof(cSignatureHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSMutableString *signature = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i){
        [signature appendFormat:@"%02x", buffer[i]];
    }
    
    //4. 拼接 Authorization
    NSMutableString *authorization = [[NSMutableString alloc] init];
    [authorization appendString:algorithm];
    [authorization appendString:@" "];
    [authorization appendFormat:@"Credential=%@/%@,", [params objectForKey:@"secretId"], credentialScope];
    [authorization appendString:@" "];
    [authorization appendFormat:@"SignedHeaders=%@,", signedHeaders];
    [authorization appendString:@" "];
    [authorization appendFormat:@"Signature=%@", signature];
    NSLog(@"authorization %@ timestamp %ld", authorization, requestTimestamp.integerValue);
    return authorization;
}

+ (NSString *)qcloudasrutil_sortedJSONTypeQueryParams:(NSDictionary *)params
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendString:@"{"];
    if ([params count]) {
        NSArray *allKeys = [[params allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for (NSString *key in allKeys) {
            if ([params[key] isKindOfClass:[NSNumber class]]) {
//                [result appendFormat:@"\"%@\":%ld,", key, [params[key] integerValue]];
                
                const char * objCType = [((NSNumber*)params[key]) objCType];
                const char * charType = "c"; //char 和 bool 类型
                if (strcmp(objCType, @encode(long)) == 0) {
                    [result appendFormat:@"\"%@\":%ld,", key, [params[key] integerValue]];
                }else if (strcmp(objCType, charType) == 0) {
                    NSNumber *num = (NSNumber*)params[key];
                    if ([NSStringFromClass(num.class) isEqualToString:@"__NSCFBoolean"]) {
                        [result appendFormat:@"\"%@\":%@,", key, [params[key] boolValue]?@"true":@"false"];
                    }
                }
                
            }
            else {
                [result appendFormat:@"\"%@\":\"%@\",", key, params[key]];
            }
        }
        if ([result length]) {
            [result deleteCharactersInRange:NSMakeRange([result length] - 1, 1)];
        }
    }
    [result appendString:@"}"];
    return result;
}

+ (NSString*)qcloudasrutil_SHA256Hex:(NSString*)source
{
    if (!source || ![source length]) {
        return @"";
    }
    const char *str = [source UTF8String];
    uint8_t result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    return ret;
}

@end
