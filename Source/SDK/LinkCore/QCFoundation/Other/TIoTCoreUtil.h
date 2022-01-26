//
//  TIoTCoreUtil.h
//  Pods
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
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

/**
 截屏
 */
+ (void)screenshotWithView:(UIView *)view;

/**
 视频存入相册
 */

+ (void)saveVideoToPhotoAlbum:(NSString *)videoPathString;

/**
 提示
 */
+ (void)showAlertViewWithText:(NSString *)alertText;

/**
 弹框提示
 */
+ (void)showSingleActionAlertWithTitle:(NSString *)title content:(NSString *)content confirmText:(NSString *)confirmText;

/*
获取APP版本号
 */
+ (NSString *)getAPPVersion;

/*
 获取手机系统版本号
 */
+ (NSString *)getSystemVersion;

/*
 获取系统语言
 */
+ (NSString *)getCurrentLanguage;

/*
 用于 TRTC和P2P Video 中 _sys_user_agent 参数拼接组成
 */
+ (NSString *)getSysUserAgent;

/*
 用于摄像头和麦克风权限判断
 */
+ (BOOL)requestMediaAuthorization:(AVMediaType)mediaType;

/**
 用户是否授权摄像头和麦克风权限（无弹框）
 */
+ (BOOL)userAccessMediaAuthorization:(AVMediaType)mediaType;
@end

NS_ASSUME_NONNULL_END
