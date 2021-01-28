//
//  TIoTCustomCalendarView.m
//  LinkApp
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCustomCalendarView.h"
#import "TIoTCustomCalendarScrollView.h"
#import "NSDate+TIoTCustomCalendar.h"

@interface TIoTCustomCalendarView()

@property (nonatomic, strong) UILabel *calendarHeaderLabel;
@property (nonatomic, strong) UIView *weekView;
@property (nonatomic, strong) TIoTCustomCalendarScrollView *scrollView;

@end


@implementation TIoTCustomCalendarView


#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setCalendarViewFrame:frame];
    }
    return self;
}

- (void)setCalendarViewFrame:(CGRect)frame {
    // 根据宽度计算日历view内容部分高度
    CGFloat kDayLineHight = 0.85 * (frame.size.width / 7.0);
    CGFloat kMonthScrollViewHeight = 6 * kDayLineHight;
    
    // 星期栏顶部高度
    CGFloat kWeekHeaderViewHeight = 0.6 * kDayLineHight;
    
    // 日历顶部高度
    CGFloat kHeaderViewHeight = 0.8 * kDayLineHight;
    
    CGFloat kButtonHeight = 40;
    
    CGFloat kButtonWidth = 120;
    
    self.calendarColor = [UIColor brownColor];
    
    self.calendarHeaderLabel = [self setupCalendarHeaderLabelWithFrame:CGRectMake(0.0, 0.0, frame.size.width, kHeaderViewHeight)];
    
    self.weekView = [self setupWeekHeadViewWithFrame:CGRectMake(0.0, kHeaderViewHeight, frame.size.width, kWeekHeaderViewHeight)];
    self.scrollView = [self setupCalendarScrollViewWithFrame:CGRectMake(0.0, kHeaderViewHeight + kWeekHeaderViewHeight, frame.size.width, kMonthScrollViewHeight)];
    
    self.scrollView.layer.borderWidth = 1.0;
    self.scrollView.layer.borderColor = self.calendarColor.CGColor;
    
    [self addSubview:self.calendarHeaderLabel];
    [self addSubview:self.weekView];
    [self addSubview:self.scrollView];
    
    
    UIButton *leftScrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftScrollBtn.frame = CGRectMake(kScreenWidth/2 - 50 - kButtonWidth, CGRectGetMaxY(self.scrollView.frame) + 20, kButtonWidth, kButtonHeight);
    [leftScrollBtn setTitle:@"上个月" forState:UIControlStateNormal];
    [leftScrollBtn setTitleColor:self.calendarColor forState:UIControlStateNormal];
    leftScrollBtn.layer.cornerRadius = 10;
    leftScrollBtn.layer.borderWidth = 1;
    leftScrollBtn.layer.borderColor = self.calendarColor.CGColor;
    [leftScrollBtn addTarget:self action:@selector(clickLastMonthBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftScrollBtn];
    
    UIButton *rightScrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightScrollBtn.frame = CGRectMake(kScreenWidth/2 + 50, CGRectGetMaxY(self.scrollView.frame) + 20, kButtonWidth, kButtonHeight);
    [rightScrollBtn setTitle:@"下个月" forState:UIControlStateNormal];
    [rightScrollBtn setTitleColor:self.calendarColor forState:UIControlStateNormal];
    rightScrollBtn.layer.cornerRadius = 10;
    rightScrollBtn.layer.borderWidth = 1;
    rightScrollBtn.layer.borderColor = self.calendarColor.CGColor;
    [rightScrollBtn addTarget:self action:@selector(clickNextMonthBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightScrollBtn];
    
    // 注册监听
    [self addNotificationObserver];
}

- (void)clickLastMonthBtn {
    [self.scrollView leftSlide];
}

- (void)clickNextMonthBtn {
    [self.scrollView rightSlide];
}

-(void)cancelClick:(UIButton *)sender{
    
    if (self.removeViewBlock) {
        self.removeViewBlock();
    }
}

- (void)dealloc {
    // 移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UILabel *)setupCalendarHeaderLabelWithFrame:(CGRect)frame {
    
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.backgroundColor = self.calendarColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16.0];
    label.textColor = [UIColor whiteColor];
    return label;
}

- (UIView *)setupWeekHeadViewWithFrame:(CGRect)frame {
    
    CGFloat height = frame.size.height;
    CGFloat width = frame.size.width / 7.0;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = self.calendarColor;
    
    NSArray *weekArray = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    for (int i = 0; i < 7; ++i) {
        
        UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * width, 0.0, width, height)];
        weekLabel.backgroundColor = [UIColor clearColor];
        weekLabel.text = weekArray[i];
        weekLabel.textColor = [UIColor whiteColor];
        weekLabel.font = [UIFont systemFontOfSize:13.5];
        weekLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:weekLabel];
        
    }
    
    return view;
    
}

- (TIoTCustomCalendarScrollView *)setupCalendarScrollViewWithFrame:(CGRect)frame {
    TIoTCustomCalendarScrollView *scrollView = [[TIoTCustomCalendarScrollView alloc] initWithFrame:frame withDateArray:@[@"2021-1-20",@"2021-2-2"]];
    scrollView.calendarThemeColor = self.calendarColor;
    return scrollView;
}

- (void)setCalendarColor:(UIColor *)calendarColor {
    _calendarColor = calendarColor;
    self.calendarHeaderLabel.backgroundColor = calendarColor;
    self.weekView.backgroundColor = calendarColor;
    self.scrollView.calendarThemeColor = calendarColor;
}

- (void)setSelectedDayBlcok:(TIoTSelectedDayBlcok)selectedDayBlcok {
    _selectedDayBlcok = selectedDayBlcok;
    if (self.scrollView) {
        self.scrollView.didSelectDayHandler = _selectedDayBlcok;
    }
}

- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCalendarHeaderAction:) name:@"TIoTCustomCalendarChangeDateNotification" object:nil];
}


#pragma mark - method

- (void)refreshCurrentMonth:(UIButton *)sender {
    
    NSInteger year = [[NSDate date] dateYear];
    NSInteger month = [[NSDate date] dateMonth];
    
    NSString *title = [NSString stringWithFormat:@"%ld年%ld月", year, month];
    
    self.calendarHeaderLabel.text = title;
    [self.scrollView refreshCurrentMonth];
    
}

- (void)changeCalendarHeaderAction:(NSNotification *)sender {
    
    NSDictionary *dic = sender.userInfo;
    
    NSNumber *year = dic[@"year"];
    NSNumber *month = dic[@"month"];
    
    NSString *title = [NSString stringWithFormat:@"%@年%@月", year, month];

    self.calendarHeaderLabel.text = title;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
