//
//  TIoTAutoIntelligentSectionTitleCell.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^AutoInteAddConditionBlock)(void);
typedef void(^AutoInteAddTaskBlock)(void);
typedef void(^AutoInteChooseCondition)(void);

typedef NS_ENUM(NSInteger,AutoIntelligentItemType) {
    AutoIntelligentItemTypeConditoin,
    AutoIntelligentItemTypeAction,
};


@interface TIoTAutoIntelligentSectionTitleCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) NSString *conditionTitleString;
@property (nonatomic, assign) BOOL isHideAddConditionButton;
@property (nonatomic, strong) UIImageView *choiceConditionImage;
@property (nonatomic, copy) AutoInteChooseCondition autoChooseConditionBlock; //选择条件
@property (nonatomic, assign) AutoIntelligentItemType autoIntelligentItemType;   //条件、任务类型，需要设置
@property (nonatomic, copy) AutoInteAddConditionBlock autoInteAddConditionBlock; //添加条件入口view
@property (nonatomic, copy) AutoInteAddTaskBlock autoInteAddTaskBlock;          //添加任务入口view
@end

NS_ASSUME_NONNULL_END
