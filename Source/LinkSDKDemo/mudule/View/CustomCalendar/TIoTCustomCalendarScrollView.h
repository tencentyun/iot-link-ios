//
//  TIoTCustomCalendarScrollView.h
//  LinkApp
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DidSelectDayHandler)(NSInteger, NSInteger, NSInteger);

@interface TIoTCustomCalendarScrollView : UIScrollView

@property (nonatomic, strong) UIColor *calendarThemeColor;
@property (nonatomic, copy) DidSelectDayHandler didSelectDayHandler; // 日期点击回调

- (instancetype)initWithFrame:(CGRect)frame withDateArray:(NSArray *)dateArray; //设置 ["yyyy-MM-dd"]

- (void)refreshCurrentMonth; // 刷新日历回到当前日期月份

- (void)leftSlide;

- (void)rightSlide;

@end

NS_ASSUME_NONNULL_END
