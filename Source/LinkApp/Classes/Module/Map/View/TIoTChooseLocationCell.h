//
//  TIoTChooseLocationCell.h
//  LinkApp
//
//  Created by ccharlesren on 2021/2/26.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTChooseLocationCell : UITableViewCell
@property (nonatomic, strong) NSString *cellString;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
