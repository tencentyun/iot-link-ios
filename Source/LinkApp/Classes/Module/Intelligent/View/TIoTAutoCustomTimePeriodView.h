//
//  TIoTAutoCustomTimePeriodView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/15.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 用户选择自定义时间段
 */
NS_ASSUME_NONNULL_BEGIN

typedef void(^AutoCancelChoiceTimePeriodBlock)(void);

typedef void(^AutoSaveChoiceTimePeriodBlock)(NSString *timeString);

@interface TIoTAutoCustomTimePeriodView : UIView
@property (nonatomic, copy) NSString *previousSelectedTime;
@property (nonatomic,copy) AutoCancelChoiceTimePeriodBlock cancelChoiceTimePeriodBlock;
@property (nonatomic,copy)AutoSaveChoiceTimePeriodBlock saveChoiceTimePeriodBlock;
@end

NS_ASSUME_NONNULL_END
