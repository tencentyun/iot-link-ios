//
//  TIoTEquipmentNewCell.h
//  LinkApp
//
//  Created by ccharlesren on 2021/3/4.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTLeftDeviceBlock)(NSIndexPath *leftIndexPath);
typedef void(^TIoTRightDeviceBlock)(NSIndexPath *rightIndexPath);
typedef void(^TIoTDeviceSwitchBlock)(void);
typedef void(^TIoTQuickBtnBlcok)(NSDictionary *productData, NSDictionary *configData,NSArray *shortcutConfigArray);

@interface TIoTEquipmentNewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;

/// @[@{},@{}]; 左右各一个Dictionary
/// @param dataArray cell 一行两个设备组成的数组
- (void)setCellDataArray:(NSArray<NSDictionary *> * _Nonnull)dataArray;

/// 请求接口后每个产品的配置详情数据
/// @param deviceConfigDataArray 每个设备配置全部信息
- (void)setDeviceConfigArray:(NSArray<NSDictionary *> * _Nonnull)deviceConfigDataArray;

/// 选中的indexpath （每一行两device是同一个indexpath）
/// @param indexPatch 用户选则的indexpath
- (void)setSelectIndexPatch:(NSIndexPath *)indexPatch;

@property (nonatomic, copy) TIoTLeftDeviceBlock clickLeftDeviceBlock;
@property (nonatomic, copy) TIoTRightDeviceBlock clickRightDeviceBlock;
@property (nonatomic, copy) TIoTDeviceSwitchBlock clickDeviceSwitchBlock; //设备开关
@property (nonatomic, copy) TIoTQuickBtnBlcok clickQuickBtnBlock;         //设备快捷按钮

@end

NS_ASSUME_NONNULL_END
