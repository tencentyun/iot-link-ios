//
//  WCCategoryTableViewCell.h
//  TenextCloud
//
//  Created by Sun on 2020/5/27.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCCategoryTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSDictionary *dic;

@end

NS_ASSUME_NONNULL_END
