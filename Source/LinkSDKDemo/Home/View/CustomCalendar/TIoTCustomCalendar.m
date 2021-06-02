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
    
    self.customCalendar = [[TIoTCustomCalendarView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    self.customCalendar.calendarColor = [UIColor whiteColor];
    
    self.customCalendar.dateArray = @[@"2021-5-20",@"2021-7-5"];
//    self.customCalendar.dateArray = @[];
    [self addSubview:self.customCalendar];
    
    __weak typeof(self) weakSelf = self;
    self.customCalendar.selectedDayBlcok = ^(NSInteger year, NSInteger month, NSInteger day) {
        
        if (weakSelf.selectedDateBlock) {
            weakSelf.selectedDateBlock([NSString stringWithFormat:@"%ld-%ld-%ld", (long)year, (long)month, (long)day]);
//            [self removeView];
        }
        
    };
    
    self.customCalendar.removeViewBlock = ^{
        [weakSelf removeView];
    };
}

-(void)removeView {
    
    [self removeFromSuperview];
}

- (void)setDateArray:(NSArray *)dateArray {
    _dateArray = dateArray;
//    self.customCalendar.dateArray = dateArray?:@[];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
