//
//  TIoTCustomCalendarMonth.h
//  LinkApp
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCustomCalendarMonth : NSObject

- (instancetype)initWithDate:(NSDate *)date;

@property (nonatomic, strong) NSDate *monthDate; // 传入的 NSDate，代表当前月的一天，用它来获得其他数据
@property (nonatomic, assign) NSInteger currentMonthTotalDays; // 当前月总天数
@property (nonatomic, assign) NSInteger firstWeekday; // 标示第一天是星期几（0代表周日，1代表周一，以此类推）
@property (nonatomic, assign) NSInteger year; // 所属年
@property (nonatomic, assign) NSInteger month; // 当前月
@property (nonatomic, assign) NSInteger day; //当前天
@property (nonatomic, assign) NSInteger lundarDay; // 农历当期天
@end

NS_ASSUME_NONNULL_END
