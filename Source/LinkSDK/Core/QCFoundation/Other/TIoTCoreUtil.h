//
//  TIoTCoreUtil.h
//  Pods
//
//  Created by eagleychen on 2020/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreUtil : NSObject

+ (NSDictionary *)getWifiSsid;

+ (UIViewController *)topViewController;

/**
生成二维码
 */
+ (UIImage *)qrCodeImageWithInfo:(NSString *)info width:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
