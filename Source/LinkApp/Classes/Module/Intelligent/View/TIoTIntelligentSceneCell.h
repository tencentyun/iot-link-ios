//
//  TIoTIntelligentSceneCell.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTIntelligentSceneCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) NSDictionary *dic;
@property (nonatomic, strong) NSString *deviceNum;
@end

NS_ASSUME_NONNULL_END
