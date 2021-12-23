//
//  TIoTAreaNetworkDeviceCell.h
//  LinkSDKDemo
//

#import <UIKit/UIKit.h>
#import "TIoTAreaNetDetectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TIoTAreaNetworkDeviceCellDelegate <NSObject>

- (void)previewAreaNetworkDetectDevice;

@end
/// 局域网 设备列表cell
@interface TIoTAreaNetworkDeviceCell : UITableViewCell
@property (nonatomic, weak)id<TIoTAreaNetworkDeviceCellDelegate>delegate;
@property (nonatomic, strong) TIoTAreaNetDetectionModel *rspDetectionDeviceModel; //探测到的响应设备
@end

NS_ASSUME_NONNULL_END
