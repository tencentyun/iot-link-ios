//
//  TIoTIntelligentCustomCell.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTIntelligentProductConfigModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TIoTIntelligentCustomCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) TIoTPropertiesModel *model;
@property (nonatomic, strong) NSString *subTitleString;
@property (nonatomic, strong) TIoTIntelligentProductConfigModel *productModel;

@property (nonatomic, copy) NSString *delayTimeString;

@property (nonatomic, assign) BOOL isHideBlankAddView; //自动智能cell 是否显示（默认不显示，条件和任务个数为0时显示）
@property (nonatomic, strong) NSString *blankAddTipString;   //自动智能添加条件和任务文案提示
@end

NS_ASSUME_NONNULL_END
