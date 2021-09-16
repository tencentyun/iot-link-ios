//
//  TIoTCustomCalendar.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TIoTSelectedDateBlock)(NSString *dateString);

typedef NSArray *_Nonnull(^TIoTPreviousMonthBlock)(NSString *month);

typedef void(^TIoTNextMonthBlock)(NSString *dateString);

@interface TIoTCustomCalendar : UIView
- (instancetype)initCalendarFrame:(CGRect)frame;

@property (nonatomic, copy) TIoTSelectedDateBlock selectedDateBlock;

/**
  日期数组 item:@"2021-01-01"
 */
@property (nonatomic, strong) NSArray <NSString *>*dateArray;

/**
 选择上月
 */
@property (nonatomic, copy) TIoTPreviousMonthBlock previousMonthBlock;

/*
 选择下月
 */
@property (nonatomic, copy) TIoTNextMonthBlock nextMonthBlock;

@end

NS_ASSUME_NONNULL_END
