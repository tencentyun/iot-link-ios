//
//  WCHelpCell.h
//  TenextCloud
//
//  Created by Wp on 2019/10/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCHelpCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSDictionary *dic;

@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
