//
//  NSDate+TIoTCustomCalendar.m
//  LinkSDKDemo
//
//

#import "NSDate+TIoTCustomCalendar.h"

@implementation NSDate (TIoTCustomCalendar)

- (NSInteger)dateDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:self];
    return components.day;
}

- (NSInteger)lundarDateDay {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:self];
    return components.day;
}

- (NSInteger)dateMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth fromDate:self];
    return components.month;
}

- (NSInteger)dateYear {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:self];
    return components.year;
}

- (NSDate *)previousMonthDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
//    components.day = 15; // 定位到当月中间日子
    
    if (components.month == 1) {
        components.month = 12;
        components.year -= 1;
    } else {
        components.month -= 1;
    }
    
    NSDate *previousDate = [calendar dateFromComponents:components];
    
    return previousDate;
}

- (NSDate *)nextMonthDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
//    components.day = 15; // 定位到当月中间日子
    
    if (components.month == 12) {
        components.month = 1;
        components.year += 1;
    } else {
        components.month += 1;
    }
    
    NSDate *nextDate = [calendar dateFromComponents:components];
    
    return nextDate;
}

- (NSInteger)totalDaysInMonth {
    NSInteger totalDays = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
    return totalDays;
}

- (NSInteger)firstWeekDayInMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    components.day = 1; // 定位到当月第一天
    NSDate *firstDay = [calendar dateFromComponents:components];
    
    // 默认一周第一天序号为 1 ，而日历中约定为 0 ，故需要减一
    NSInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDay] - 1;
    
    return firstWeekday;
}

- (NSString *)getWeekDayWithDate {
    NSCalendar *calendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitWeekday) fromDate:self];
    NSNumber * weekNumber = @([components weekday]);
    NSInteger weekInt = [weekNumber integerValue];
    NSString *weekDay = @"";
    switch (weekInt) {
        case 1: {
            weekDay = @"星期日";
            break;
        }
        case 2: {
            weekDay = @"星期一";
            break;
        }
        case 3: {
            weekDay = @"星期二";
            break;
        }
        case 4: {
            weekDay = @"星期三";
            break;
        }
        case 5: {
            weekDay = @"星期四";
            break;
        }
        case 6: {
            weekDay = @"星期五";
            break;
        }
        case 7: {
            weekDay = @"星期六";
            break;
        }
        default:
            break;
    }
    
    return weekDay;
}
@end
