//
//  TIoTCustomCalendarView.m
//  LinkApp
//
//

#import "TIoTCustomCalendarView.h"
#import "TIoTCustomCalendarScrollView.h"
#import "NSDate+TIoTCustomCalendar.h"
#import "UILabel+TIoTLableFormatter.h"

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
    CGFloat kDayLineHight = 61;//0.85 * (frame.size.width / 7.0);
    CGFloat kMonthScrollViewHeight = 6 * kDayLineHight;
    
    // 星期栏顶部高度
    CGFloat kWeekHeaderViewHeight = 33;
    
    // 日历顶部高度
    CGFloat kHeaderViewHeight = 62;
    
    CGFloat kWidthPaddin = 10;
    CGFloat kBtnWidth = 65;
    CGFloat kBtnHeight = 24;
    
    self.calendarColor = [UIColor whiteColor];
    
    self.calendarHeaderLabel = [self setupCalendarHeaderLabelWithFrame:CGRectMake(0.0, 0.0, frame.size.width, kHeaderViewHeight)];
    
    self.weekView = [self setupWeekHeadViewWithFrame:CGRectMake(0.0, kHeaderViewHeight, frame.size.width, kWeekHeaderViewHeight)];
    self.scrollView = [self setupCalendarScrollViewWithFrame:CGRectMake(0.0, kHeaderViewHeight + kWeekHeaderViewHeight, frame.size.width, kMonthScrollViewHeight)];
    
    self.scrollView.layer.borderWidth = 1.0;
    self.scrollView.layer.borderColor = self.calendarColor.CGColor;
    
    [self addSubview:self.calendarHeaderLabel];
    [self addSubview:self.weekView];
    [self addSubview:self.scrollView];
    
    
    UIButton *leftScrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftScrollBtn.frame = CGRectMake(kWidthPaddin, CGRectGetHeight(self.calendarHeaderLabel.frame)/2-kBtnHeight/2, kBtnWidth, kBtnHeight);
    [leftScrollBtn setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
    [leftScrollBtn setButtonFormateWithTitlt:@"上个月" titleColorHexString:kVideoDemoMainThemeColor font:[UIFont wcPfRegularFontOfSize:14]];
    [leftScrollBtn addTarget:self action:@selector(clickLastMonthBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftScrollBtn];
    
    UIButton *rightScrollBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightScrollBtn.frame = CGRectMake(CGRectGetWidth(self.calendarHeaderLabel.frame)-kBtnWidth-kWidthPaddin, CGRectGetHeight(self.calendarHeaderLabel.frame)/2-kBtnHeight/2, kBtnWidth, kBtnHeight);
    [rightScrollBtn setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
    [rightScrollBtn setButtonFormateWithTitlt:@"下个月" titleColorHexString:kVideoDemoMainThemeColor font:[UIFont wcPfRegularFontOfSize:14]];
    [rightScrollBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -rightScrollBtn.imageView.image.size.width, 0, rightScrollBtn.imageView.image.size.width)];
    [rightScrollBtn setImageEdgeInsets:UIEdgeInsetsMake(0, rightScrollBtn.titleLabel.bounds.size.width, 0, -rightScrollBtn.titleLabel.bounds.size.width)];
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
    label.font = [UIFont wcPfRegularFontOfSize:16];
    label.textColor = [UIColor blackColor];
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
        weekLabel.backgroundColor = [UIColor colorWithHexString:kVideoDemoBackgoundColor];
        weekLabel.text = weekArray[i];
        [weekLabel setLabelFormateTitle: weekArray[i] font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:kVideoDemoWeekLabelColor textAlignment:NSTextAlignmentCenter];
        if (i == 0 || i == 6) {
            weekLabel.textColor = [UIColor colorWithHexString:kVideoDemoGreenColor];
        }
        [view addSubview:weekLabel];
        
    }
    
    return view;
    
}

- (TIoTCustomCalendarScrollView *)setupCalendarScrollViewWithFrame:(CGRect)frame {
    TIoTCustomCalendarScrollView *scrollView = [[TIoTCustomCalendarScrollView alloc] initWithFrame:frame];
    scrollView.calendarThemeColor = self.calendarColor;
    return scrollView;
}

- (void)setDateArray:(NSArray *)dateArray {
    _dateArray = dateArray;
    self.scrollView.inputDateArray = dateArray;
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
