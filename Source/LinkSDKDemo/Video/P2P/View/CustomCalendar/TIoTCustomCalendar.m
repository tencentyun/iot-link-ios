//
//  TIoTCustomCalendar.m
//  LinkApp
//
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
    
    [self addSubview:self.customCalendar];
    
    __weak typeof(self) weakSelf = self;
    self.customCalendar.selectedDayBlcok = ^(NSInteger year, NSInteger month, NSInteger day) {
        
        if (weakSelf.selectedDateBlock) {
            weakSelf.selectedDateBlock([NSString stringWithFormat:@"%02ld-%02ld-%02ld", (long)year, (long)month, (long)day]);
//            [self removeView];
        }
        
    };
    
    self.customCalendar.removeViewBlock = ^{
        [weakSelf removeView];
    };
    
    //上月
    self.customCalendar.clickPreviousMonthBlock = ^(NSString * _Nonnull month){
        if (weakSelf.previousMonthBlock) {
            NSArray *dataArray = weakSelf.previousMonthBlock(month);
//             weakSelf.dateArray = dataArray;
//            [weakSelf layoutSubviews];
        }
    };

    //下月
    self.customCalendar.clickNextMonthBlock = ^(NSString * _Nonnull dateString){
        if (weakSelf.nextMonthBlock) {
            weakSelf.nextMonthBlock(dateString);
            [weakSelf layoutSubviews];
        }
    };
}

-(void)removeView {
    
    [self removeFromSuperview];
}

- (void)setDateArray:(NSArray *)dateArray {
    _dateArray = dateArray;
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.customCalendar.dateArray = self.dateArray?:@[];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
