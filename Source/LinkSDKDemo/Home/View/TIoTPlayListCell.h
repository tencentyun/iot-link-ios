//
//  TIoTPlayListCell.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/13.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIotPlayFunctionBlock)(void);
@interface TIoTPlayListCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, copy) TIotPlayFunctionBlock playLeftBlock;
@property (nonatomic, copy) TIotPlayFunctionBlock playMiddBlock;
@property (nonatomic, copy) TIotPlayFunctionBlock playRightBlock;
@end

NS_ASSUME_NONNULL_END
