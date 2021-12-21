//
//  TIoTAreaNetworkDeviceCell.h
//  LinkSDKDemo
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 设备预览代理
@protocol TIoTAreaNetworkDeviceCellDelegate <NSObject>

- (void)previewAreaNetworkDetectDevice;

@end
/// 局域网 设备列表cell
@interface TIoTAreaNetworkDeviceCell : UITableViewCell
@property (nonatomic, weak)id<TIoTAreaNetworkDeviceCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
