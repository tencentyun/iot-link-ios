//
//  TIoTCustomCalendarScrollView.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DidSelectDayHandler)(NSInteger, NSInteger, NSInteger);

@interface TIoTCustomCalendarScrollView : UIScrollView
@property (nonatomic, strong) NSArray *inputDateArray; //设置 ["yyyy-MM-dd"]
@property (nonatomic, strong) UIColor *calendarThemeColor;
@property (nonatomic, copy) DidSelectDayHandler didSelectDayHandler; // 日期点击回调

- (instancetype)initWithFrame:(CGRect)frame;

- (void)refreshCurrentMonth; // 刷新日历回到当前日期月份

- (void)leftSlide;

- (void)rightSlide;

- (void)refureshUI;
@end

NS_ASSUME_NONNULL_END
