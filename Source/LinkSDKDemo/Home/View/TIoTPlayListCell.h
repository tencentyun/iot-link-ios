//
//  TIoTPlayListCell.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/13.
//  Copyright © 2021 Tencent. All rights reserved.
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
