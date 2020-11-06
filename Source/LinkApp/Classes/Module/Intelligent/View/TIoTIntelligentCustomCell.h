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
@end

NS_ASSUME_NONNULL_END
