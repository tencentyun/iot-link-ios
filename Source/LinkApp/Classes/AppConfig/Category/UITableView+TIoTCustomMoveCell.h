//
//  UITableView+TIoTCustomMoveCell.h
//  LinkApp
//
//  Created by ccharlesren on 2021/5/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 自定义UITableView cell 拖拽
 */

NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTMoveCustomCellBlock)(NSMutableArray *newDataArray);

@interface UITableView (TIoTCustomMoveCell)

-(void)setupDataArray:(NSMutableArray *)dataSourceArray moveBlock:(TIoTMoveCustomCellBlock )moveBlock;
@end

NS_ASSUME_NONNULL_END
