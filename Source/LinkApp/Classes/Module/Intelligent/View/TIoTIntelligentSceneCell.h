//
//  TIoTIntelligentSceneCell.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, IntelligentSceneType) {
    IntelligentSceneTypeManual,
    IntelligentSceneTypeAuto,
};

@protocol TIoTIntelligentSceneCellDelegate <NSObject>

- (void)runManualSceneWithSceneID:(NSString *)sceneID withDic:(NSDictionary *)dataArraySelectDic;
- (void)changeSwitchStatus:(UISwitch *)switchControl withAutoScendData:(NSDictionary *)autoSceneDic withIndexNum:(NSInteger)indexNum;

@end

@interface TIoTIntelligentSceneCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) NSDictionary *dic;
@property (nonatomic, strong) NSString *deviceNum;
@property (nonatomic, assign) IntelligentSceneType sceneType;
@property (nonatomic, weak)id<TIoTIntelligentSceneCellDelegate>delegate;
@property (nonatomic, assign) NSInteger switchIndex;
@end

NS_ASSUME_NONNULL_END
