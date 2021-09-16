//
//  TIoTDemoCalendarCustomView.h
//  LinkSDKDemo
//
//

#import <UIKit/UIKit.h>
#import "TIoTCustomCalendar.h"

NS_ASSUME_NONNULL_BEGIN
@class TIoTDemoCalendarCustomView;
typedef void(^TIoTDemoCalendarChoiceDateBlock)(NSString *dayDateString);

typedef void(^TIoTDemoPreviousMonthBlcok)(TIoTDemoCalendarCustomView *view,NSString *month);

typedef NSArray *_Nonnull(^TIoTDemoNextMonthBlcok)(void);

@interface TIoTDemoCalendarCustomView : UIView

@property (nonatomic, copy)TIoTDemoCalendarChoiceDateBlock choickDayDateBlock;
/// 日历数组 item:@"2021-01-01"
@property (nonatomic, strong) NSArray <NSString *>*calendarDateArray;

@property (nonatomic, strong) TIoTCustomCalendar *calendarView; //日历控件view

/// 上月
@property (nonatomic, copy)TIoTDemoPreviousMonthBlcok clickPreviousMonthBlock;
/// 下月
@property (nonatomic, copy)TIoTDemoNextMonthBlcok clickNextMonthBlock;

@end

NS_ASSUME_NONNULL_END
