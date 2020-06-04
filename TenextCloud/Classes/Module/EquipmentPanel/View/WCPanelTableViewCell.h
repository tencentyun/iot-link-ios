//
//  WCPanelTableViewCell.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCPanelTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSDictionary *dic;
@property (nonatomic, copy) void (^update)(NSDictionary *dic);

@end

NS_ASSUME_NONNULL_END
