//
//  TIoTEquipmentNewCell.h
//  LinkApp
//
//  Created by ccharlesren on 2021/3/4.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTLeftDeviceBlock)(void);
typedef void(^TIoTRightDeviceBlock)(void);

@interface TIoTEquipmentNewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) NSArray <NSDictionary *>*dataArray; //@[@{},@{}]; 左右各一个Dictionary

@property (nonatomic, copy) TIoTLeftDeviceBlock clickLeftDeviceBlock;
@property (nonatomic, copy) TIoTRightDeviceBlock clickRightDeviceBlock;
@end

NS_ASSUME_NONNULL_END
