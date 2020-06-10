//
//  WCActionTypeTableViewCell.h
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/19.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCActionTypeTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSString *nameStr;

@end

NS_ASSUME_NONNULL_END
