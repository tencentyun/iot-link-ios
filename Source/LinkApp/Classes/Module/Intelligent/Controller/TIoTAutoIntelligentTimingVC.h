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

@interface TIoTAutoIntelligentTimingVC : UIViewController
@property (nonatomic, copy) AutoIntelAddTimerBlock autoIntelAddTimerBlock;
@end

NS_ASSUME_NONNULL_END
