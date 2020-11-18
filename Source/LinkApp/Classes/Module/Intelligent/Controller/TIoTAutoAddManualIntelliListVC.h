//
//  TIoTAutoAddManualIntelliListVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTAutoIntelligentModel.h"

typedef void(^AutoAddManualSceneBlock)(NSArray <TIoTAutoIntelligentModel*>* _Nullable manualSceneArray);
typedef void(^AutoUpdateManualSceneBlock)(TIoTAutoIntelligentModel * _Nullable changedModel,NSInteger index); //在自动智能列表中的index
/**
 自动智能-添加任务中-选择手动
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTAutoAddManualIntelliListVC : UIViewController
@property (nonatomic, strong) NSDictionary *paramDic; //获取场景列表的参数（筛选手动智能场景）
@property (nonatomic, copy) AutoAddManualSceneBlock addManualSceneBlock; //增加时候实现

@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, copy) AutoUpdateManualSceneBlock updateManualSceneBlock; //编辑时候实现
@property (nonatomic, strong) TIoTAutoIntelligentModel *editModel;//在智能列表所选的
@property (nonatomic, assign) NSInteger editIndex;  //在智能列表中的index;
@end

NS_ASSUME_NONNULL_END
