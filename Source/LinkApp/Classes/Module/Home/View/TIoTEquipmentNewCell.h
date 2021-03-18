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
typedef void(^TIoTQuickBtnBlcok)(NSDictionary *productData, NSDictionary *configData,NSArray *shortcutConfigArray);

@interface TIoTEquipmentNewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) NSArray <NSDictionary *>*dataArray; //@[@{},@{}]; 左右各一个Dictionary
@property (nonatomic, strong) NSArray <NSDictionary *>* deviceConfigDataArray;//请求接口后每个产品的配置详情数据

@property (nonatomic, copy) TIoTLeftDeviceBlock clickLeftDeviceBlock;
@property (nonatomic, copy) TIoTRightDeviceBlock clickRightDeviceBlock;
@property (nonatomic, copy) TIoTDeviceSwitchBlock clickDeviceSwitchBlock; //设备开关
@property (nonatomic, copy) TIoTQuickBtnBlcok clickQuickBtnBlock;         //设备快捷按钮

@end

NS_ASSUME_NONNULL_END
