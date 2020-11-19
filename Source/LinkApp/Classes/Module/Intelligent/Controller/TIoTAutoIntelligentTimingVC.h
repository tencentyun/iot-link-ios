//
//  TIoTAutoIntelligentTimingVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTAutoIntelligentModel.h" //model

/**
 自动智能中定时控制器
 */
NS_ASSUME_NONNULL_BEGIN
typedef void(^AutoIntelAddTimerBlock)(TIoTAutoIntelligentModel *timerModel);
typedef void(^AutoUpdateTimerBlock)(TIoTAutoIntelligentModel *modifiedTimerModel);

@interface TIoTAutoIntelligentTimingVC : UIViewController
@property (nonatomic, copy) AutoIntelAddTimerBlock autoIntelAddTimerBlock;

@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) TIoTAutoIntelligentModel *editModel; //进入编辑时候，传入的定时模型
@property (nonatomic, copy) AutoUpdateTimerBlock updateTimerBlock; //修改完返回block
@end

NS_ASSUME_NONNULL_END
