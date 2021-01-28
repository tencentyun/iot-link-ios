//
//  TIoTCustomCalendar.m
//  LinkApp
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCustomCalendar.h"
#import "TIoTCustomCalendarView.h"

@interface TIoTCustomCalendar()

@property (nonatomic, strong) TIoTCustomCalendarView *customCalendar;

@end


@implementation TIoTCustomCalendar

- (instancetype)initCalendarFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupCalendarViewWithFrame:frame];
    }
    return self;
}

- (void)setupCalendarViewWithFrame:(CGRect)frame {
    
    TIoTCustomCalendarView *customCalendar = [[TIoTCustomCalendarView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    customCalendar.calendarColor = [UIColor brownColor];
    
    [self addSubview:customCalendar];
    
    customCalendar.selectedDayBlcok = ^(NSInteger year, NSInteger month, NSInteger day) {
        
        if (self.selectedDateBlock) {
            self.selectedDateBlock([NSString stringWithFormat:@"%ld:%ld:%ld", (long)year, (long)month, (long)day]);
            [self removeView];
        }
        
    };
    
    customCalendar.removeViewBlock = ^{
        [self removeView];
    };
}

-(void)removeView {
    
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
