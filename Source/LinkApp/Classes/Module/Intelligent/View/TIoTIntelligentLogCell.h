//
//  TIoTIntelligentLogCell.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/23.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTIntelligentLogModel.h"

typedef void(^IntelligentLogDetailBlock)(BOOL isShow,NSIndexPath * _Nullable selectedIndex);

NS_ASSUME_NONNULL_BEGIN

@interface TIoTIntelligentLogCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
//@property (nonatomic, assign) BOOL executedResult;
@property (nonatomic, copy) IntelligentLogDetailBlock logDetailBlock;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, assign) BOOL isCellOpen;

@property (nonatomic, strong) TIoTLogMsgsModel *msgModel;
@end

NS_ASSUME_NONNULL_END
