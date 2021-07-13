//
//  TIoTDemoCalendarCustomView.h
//  LinkSDKDemo
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TIoTDemoCalendarChoiceDateBlock)(NSString *dayDateString);

@interface TIoTDemoCalendarCustomView : UIView

@property (nonatomic, copy)TIoTDemoCalendarChoiceDateBlock choickDayDateBlock;
/// 日历数组 item:@"2021-1-1"
@property (nonatomic, strong) NSArray <NSString *>*calendarDateArray;
@end

NS_ASSUME_NONNULL_END
