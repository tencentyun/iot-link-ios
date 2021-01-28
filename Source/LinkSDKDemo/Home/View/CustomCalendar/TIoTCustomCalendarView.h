//
//  TIoTCustomCalendarView.h
//  LinkApp
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TIoTSelectedDayBlcok)(NSInteger, NSInteger, NSInteger);

typedef void(^TIoTRemoveViewBlock)(void);

@interface TIoTCustomCalendarView : UIView

/// 构造方法
/// @param frame 日历frame
- (instancetype)initWithFrame:(CGRect)frame;

/// 日历高度
@property (nonatomic, assign, readonly) CGFloat calendarHeight;

/// 基础色调
@property (nonatomic, strong) UIColor *calendarColor;

/// 点击日期block，返回选中日期: year-month-day
@property (nonatomic, copy) TIoTSelectedDayBlcok selectedDayBlcok;

/// 移除block
@property (nonatomic, copy) TIoTRemoveViewBlock removeViewBlock;

@end

NS_ASSUME_NONNULL_END
