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

typedef void(^TIoTDemoMonthBlcok)(TIoTDemoCalendarCustomView *view,NSString *dateString);

@interface TIoTDemoCalendarCustomView : UIView

@property (nonatomic, copy)TIoTDemoCalendarChoiceDateBlock choickDayDateBlock;
/// 日历数组 item:@"2021-01-01"
@property (nonatomic, strong) NSArray <NSString *>*calendarDateArray;

@property (nonatomic, strong) TIoTCustomCalendar *calendarView; //日历控件view

/// 选择月
@property (nonatomic, copy)TIoTDemoMonthBlcok monthBlock;

@end

NS_ASSUME_NONNULL_END
