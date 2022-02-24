//
//  TIoTAreaNetworkPreviewVC.h
//  LinkSDKDemo

#import <UIKit/UIKit.h>
#import "TIoTAreaNetDetectionModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 局域网探测设备 预览控制器
@interface TIoTAreaNetworkPreviewVC : UIViewController
@property (nonatomic, strong) TIoTAreaNetDetectionModel *model;
@property (nonatomic, strong) NSString *productID;
@end

NS_ASSUME_NONNULL_END
