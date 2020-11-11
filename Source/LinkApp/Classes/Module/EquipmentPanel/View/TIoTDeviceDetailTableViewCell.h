//
//  WCDeviceDetailTableViewCell.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/24.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTDeviceDetailTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSDictionary *dic;
@property (nonatomic, assign) BOOL isAddTimePriod;  //自动智能才会显示
@property (nonatomic, copy) UIFont *timePriodNumFont; 
@end

NS_ASSUME_NONNULL_END
