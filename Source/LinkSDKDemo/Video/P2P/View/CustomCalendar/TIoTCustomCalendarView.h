//
//  TIoTCustomCalendarView.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TIoTSelectedDayBlcok)(NSInteger, NSInteger, NSInteger);

typedef void(^TIoTRemoveViewBlock)(void);

typedef void(^TIoTClickPreviousMonthBlock)(NSString *month); //点击上个月block

typedef void(^TIoTClickNextMonthBlock)(NSString *month); //点击下个月block

@interface TIoTCustomCalendarView : UIView

/// 构造方法
/// @param frame 日历frame
- (instancetype)initWithFrame:(CGRect)frame;

/// 日历高度
@property (nonatomic, assign, readonly) CGFloat calendarHeight;

/// 基础色调
@property (nonatomic, strong) UIColor *calendarColor;

@property (nonatomic, strong) NSArray *dateArray;

/// 点击日期block，返回选中日期: year-month-day
@property (nonatomic, copy) TIoTSelectedDayBlcok selectedDayBlcok;

/// 移除block
@property (nonatomic, copy) TIoTRemoveViewBlock removeViewBlock;

/// 上个月block
@property (nonatomic, copy) TIoTClickPreviousMonthBlock clickPreviousMonthBlock;

/// 下个月block
@property (nonatomic, copy) TIoTClickNextMonthBlock clickNextMonthBlock;

@end

NS_ASSUME_NONNULL_END
