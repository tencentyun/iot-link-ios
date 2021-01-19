//
//  TIoTCoreUtil.h
//  Pods
//
//  Created by eagleychen on 2020/8/27.
//

#import <Foundation/Foundation.h>

#import "TIoTVideoDistributionNetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCoreUtil : NSObject

+ (NSDictionary *)getWifiSsid;

+ (UIViewController *)topViewController;

/**
 二维码扫码配网
 *  @param infoModel 配网所需信息
 */
+ (UIImage *)generateQrCodeNetWorkInfo:(TIoTVideoDistributionNetModel *)infoModel imageSize:(CGSize )size;

+ (NSString *)generateSignature:(NSDictionary *)allParams params:(NSDictionary *)params server:(NSString *)serverHost;

+ (NSString *)qcloudasrutil_sortedJSONTypeQueryParams:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
