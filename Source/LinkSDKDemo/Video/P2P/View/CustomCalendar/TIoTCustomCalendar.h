//
//  TIoTCustomCalendar.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>
#import "TIoTCustomCalendarView.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTSelectedDateBlock)(NSString *dateString);

typedef NSArray *_Nonnull(^TIoTDemoChoiceMonthBlock)(NSString *dateString);

@interface TIoTCustomCalendar : UIView
- (instancetype)initCalendarFrame:(CGRect)frame;

@property (nonatomic, copy) TIoTSelectedDateBlock selectedDateBlock;

/**
  日期数组 item:@"2021-01-01"
 */
@property (nonatomic, strong) NSArray <NSString *>*dateArray;

@property (nonatomic, strong) TIoTCustomCalendarView *customCalendar;

/**
 选择月
 */
@property (nonatomic, copy) TIoTDemoChoiceMonthBlock choiceMonthBlock;

@end

NS_ASSUME_NONNULL_END
