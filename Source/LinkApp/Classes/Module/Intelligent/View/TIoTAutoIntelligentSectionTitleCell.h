//
//  TIoTAutoIntelligentSectionTitleCell.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTAutoIntelligentSectionTitleCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) NSString *conditionTitleString;
@property (nonatomic, assign) BOOL isHideChoiceConditionButton;
@property (nonatomic, assign) BOOL isHideAddConditionButton;
@end

NS_ASSUME_NONNULL_END
