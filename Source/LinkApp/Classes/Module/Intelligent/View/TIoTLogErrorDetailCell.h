//
//  TIoTLogErrorDetailCell.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/25.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTIntelligentLogModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIoTLogErrorDetailCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) TIoTActionResultsModel *resultModel;
@end

NS_ASSUME_NONNULL_END
