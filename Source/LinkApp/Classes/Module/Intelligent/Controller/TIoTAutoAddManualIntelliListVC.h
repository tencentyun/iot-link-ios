//
//  TIoTAutoAddManualIntelliListVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TIoTAutoIntelligentModel;

typedef void(^AutoAddManualSceneBlock)(NSArray <TIoTAutoIntelligentModel*>*manualSceneArray);

/**
 自动智能-添加任务中-选择手动
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTAutoAddManualIntelliListVC : UIViewController
@property (nonatomic, strong) NSDictionary *paramDic; //获取场景列表的参数（筛选手动智能场景）
@property (nonatomic, copy) AutoAddManualSceneBlock addManualSceneBlock;
@end

NS_ASSUME_NONNULL_END
