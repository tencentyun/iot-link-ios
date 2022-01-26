//
//  TIoTCoreUtil.m
//  Pods
//
//

#import "TIoTCoreUtil.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "NSString+Extension.h"
#import "TIoTVideoDistributionNetModel.h"
#import <objc/runtime.h>
#import "TIoTCoreAddDevice.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "TIoTCoreWMacros.h"
#import "UIDevice+Until.h"
#import "TIoTCoreUserManage.h"

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
            
            NSString *wifiname = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            NSString *pwd = [[[TIoTCoreUserManage shared] wifiMap] objectForKey:wifiname?:@"wifiname"];
            wifiDic = @{@"name":[networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID],@"bssid":[networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeyBSSID], @"pwd":pwd?:@""};
            DDLogInfo(@"network info -> %@", wifiDic);
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
    
    DDLogInfo(@"payload %@ hashedRequestPayload %@", payload, hashedRequestPayload);
    
    NSMutableString *canonicalRequest = [[NSMutableString alloc] init];
    [canonicalRequest appendFormat:@"%@\n", httpRequestMethod];
    [canonicalRequest appendFormat:@"%@\n", canonicalURI];
    [canonicalRequest appendFormat:@"%@\n", canonicalQueryString];
    [canonicalRequest appendFormat:@"%@\n", canonicalHeaders];
    [canonicalRequest appendFormat:@"%@\n", signedHeaders];
    [canonicalRequest appendFormat:@"%@", hashedRequestPayload];
    
    DDLogInfo(@"canonicalRequest %@", canonicalRequest);
    
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
    
    DDLogInfo(@"stringToSign %@", stringToSign);
    
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
    DDLogInfo(@"authorization %@ timestamp %ld", authorization, requestTimestamp.integerValue);
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



//回调方法
+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    
    [self showAlertViewWithText:msg];
}

+ (void)screenshotWithView:(UIView *)view {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

/**
 视频存入相册
 */

+ (void)saveVideoToPhotoAlbum:(NSString *)videoPathString {
    if (videoPathString) {
            NSURL *videoUrl = [NSURL URLWithString:videoPathString];
            BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([videoUrl path]);
            if (compatible) {
                UISaveVideoAtPathToSavedPhotosAlbum([videoUrl path], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
            }else {
                [self showAlertViewWithText:@"该音视频格式不支持录像"];
            }
        }
}

+ (void)savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存视频失败" ;
    }else{
        msg = @"保存视频成功" ;
    }
    [self showAlertViewWithText:msg];
}

+ (void)showAlertViewWithText:(NSString *)alertText {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:alertText?:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self.topViewController presentViewController:alert animated:YES completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

+ (void)showSingleActionAlertWithTitle:(NSString *)title content:(NSString *)content confirmText:(NSString *)confirmText {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString *messageString = content?:@"";
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title?:@"" message:messageString preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:confirmText?:@"" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertC addAction:alertA];
        [self.topViewController presentViewController:alertC animated:YES completion:nil];
    });
}

/*
获取APP版本号
 */
+ (NSString *)getAPPVersion {
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

/*
 获取手机系统版本号
 */
+ (NSString *)getSystemVersion {
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    return sysVersion;
}

/*
 获取系统语言
 */
+ (NSString *)getCurrentLanguage {
    NSString * currentLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    return currentLang;
}

+ (NSString *)getSysUserAgent {
    //连连版本号
    NSString *appVersion = [TIoTCoreUtil getAPPVersion];//[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //系统版本号
    NSString *strSysVersion = [TIoTCoreUtil getSystemVersion];//[[UIDevice currentDevice] systemVersion];
    //获取手机型号
    NSString *iphoneModel = [UIDevice deviceModel];
    //语言
    NSString *currentLang = [TIoTCoreUtil getCurrentLanguage];//CURR_LANG;
    NSString *agentString = [NSString stringWithFormat:@"ios/%@(ios %@;%@;%@)",appVersion,strSysVersion,iphoneModel,currentLang];
    return agentString;
}

/*
 用于摄像头和麦克风权限判断
 */
+ (BOOL)requestMediaAuthorization:(AVMediaType)mediaType {
    __block BOOL isAccess = NO;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType
                                 completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    //同意授权
                    isAccess = YES;
                } else {
                    //拒绝授权
                    isAccess = NO;
                }
            });
        }];
    } else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        //拒绝授权
        isAccess = NO;
    } else if (authStatus == AVAuthorizationStatusAuthorized) {
        //同意授权
        isAccess = YES;
    }
    return isAccess;
}

/**
 获取摄像头和麦克风权限状态（无弹框）
 */
+ (BOOL)userAccessMediaAuthorization:(AVMediaType)mediaType; {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    BOOL isAccess = NO;
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        isAccess = NO;
    } else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        //拒绝授权
        isAccess = NO;
    } else if (authStatus == AVAuthorizationStatusAuthorized) {
        //同意授权
        isAccess = YES;
    }
    return isAccess;
}
@end
