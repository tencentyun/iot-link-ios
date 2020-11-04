//
//  TIoTSettingIntelligentCell.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTSettingIntelligentCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) NSDictionary *dic;
@end

NS_ASSUME_NONNULL_END
