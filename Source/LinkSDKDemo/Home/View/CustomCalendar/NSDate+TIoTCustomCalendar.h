//
//  NSDate+TIoTCustomCalendar.h
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (TIoTCustomCalendar)

/// 获得当前 NSDate 对应day
- (NSInteger)dateDay;


/// 获得当前 NSDate 对应的月
- (NSInteger)dateMonth;


/// 获得当前 NSDate 对应的年
- (NSInteger)dateYear;


/// 获得当前 NSDate 的上月某一天的 NSDate,默认15号
- (NSDate *)previousMonthDate;


/// 获得当前 NSDate 的下月某一天的 NSDate，默认15号
- (NSDate *)nextMonthDate;


/// 获得当前 NSDate 对应的月份总天数
- (NSInteger)totalDaysInMonth;


/// 获得当前 NSDate 对应月份当月第一天的所在星期
- (NSInteger)firstWeekDayInMonth;

@end

NS_ASSUME_NONNULL_END
