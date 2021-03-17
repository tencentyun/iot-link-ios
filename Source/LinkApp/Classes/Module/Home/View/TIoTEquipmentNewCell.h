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
typedef void(^TIoTDeviceSwitchBlock)(void);
typedef void(^TIoTQuickBtnBlcok)(void);
@interface TIoTEquipmentNewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) NSArray <NSDictionary *>*dataArray; //@[@{},@{}]; 左右各一个Dictionary

@property (nonatomic, copy) TIoTLeftDeviceBlock clickLeftDeviceBlock;
@property (nonatomic, copy) TIoTRightDeviceBlock clickRightDeviceBlock;
@property (nonatomic, copy) TIoTDeviceSwitchBlock clickDeviceSwitchBlock; //设备开关
@property (nonatomic, copy) TIoTQuickBtnBlcok clickQuickBtnBlock;         //设备快捷按钮

@property (nonatomic, assign) BOOL isHideLeftSwitch;
@property (nonatomic, assign) BOOL isHideRightSwitch;
@property (nonatomic, assign) BOOL isHideLeftShortcut;
@property (nonatomic, assign) BOOL isHideRightShortcut;
@end

NS_ASSUME_NONNULL_END
