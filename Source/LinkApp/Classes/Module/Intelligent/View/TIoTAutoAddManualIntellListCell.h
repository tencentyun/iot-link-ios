//
//  TIoTAutoAddManualIntellListCell.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 自动智能-添加任务中-选择手动cell
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTAutoAddManualIntellListCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSString *manualNameString;
@property (nonatomic, assign) BOOL isChoosed;
@end

NS_ASSUME_NONNULL_END
