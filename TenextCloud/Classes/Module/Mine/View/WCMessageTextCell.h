//
//  WCMessageTextCell.h
//  TenextCloud
//
//  Created by Wp on 2019/11/6.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WCMessageTextCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, copy) NSDictionary *msgData;

@end

NS_ASSUME_NONNULL_END
