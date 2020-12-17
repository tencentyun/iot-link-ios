//
//  TIoTCoreUtil.h
//  Pods
//
//  Created by eagleychen on 2020/8/27.
//

#import <Foundation/Foundation.h>
#import "TIoTVideoDistributionNetModel.h"

@class TIoTVideoDistributionNetModel;

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreUtil : NSObject

+ (NSDictionary *)getWifiSsid;

+ (UIViewController *)topViewController;

/**
 二维码扫码配网
 *  @param infoModel 配网所需信息
 */
+ (UIImage *)generateQrCodeNetWorkInfo:(TIoTVideoDistributionNetModel *)infoModel imageSize:(CGSize )size;

@end

NS_ASSUME_NONNULL_END
