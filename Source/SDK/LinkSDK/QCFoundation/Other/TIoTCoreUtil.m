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

@end
