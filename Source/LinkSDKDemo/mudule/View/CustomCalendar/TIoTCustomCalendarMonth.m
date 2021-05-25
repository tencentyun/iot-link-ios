//
//  TIoTCustomCalendarMonth.m
//  LinkApp
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCustomCalendarMonth.h"
#import "NSDate+TIoTCustomCalendar.h"

@implementation TIoTCustomCalendarMonth

- (instancetype)initWithDate:(NSDate *)date {
    self = [super init];
    if (self) {
        self.monthDate = date;
        self.currentMonthTotalDays = [self.monthDate totalDaysInMonth];
        self.firstWeekday = [self.monthDate firstWeekDayInMonth];
        self.year = [self.monthDate dateYear];
        self.month = [self.monthDate dateMonth];
    }
    return self;
}

@end
