//
//  TIoTPlayListCell.h
//  LinkSDKDemo
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIotPlayFunctionBlock)(void);
@interface TIoTPlayListCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSString *deviceNameString;
@property (nonatomic, copy) TIotPlayFunctionBlock playRealTimeMonitoringBlock; //实时监控
@property (nonatomic, copy) TIotPlayFunctionBlock playLocalPlaybackBlock; //本地回放
@property (nonatomic, copy) TIotPlayFunctionBlock playCloudStorageBlock; //云端存储

@end

NS_ASSUME_NONNULL_END
