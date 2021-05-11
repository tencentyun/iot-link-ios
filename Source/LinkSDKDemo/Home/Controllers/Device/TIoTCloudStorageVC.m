//
//  TIoTCloudStorageVC.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCloudStorageVC.h"
#import "TIoTCustomCalendar.h"
#import "NSString+Extension.h"
#import "TIoTCustomTimeSlider.h"

@interface TIoTCloudStorageVC ()<UIScrollViewDelegate>
//@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIButton *calendarBtn;
@property (nonatomic, strong) UIView *sliderBottomView;
@property (nonatomic, strong) NSString *dayDateString; //选择天日期
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, assign) CGFloat kTopPadding; //距离日历间距
@property (nonatomic, assign) CGFloat kLeftPadding; //左边距
@property (nonatomic, assign) CGFloat kItemWith; //每一天长度
@property (nonatomic, assign) CGFloat kScrollContentWidth; // 总长度
@property (nonatomic, assign) CGFloat kSliderHeight; //自定义slider高度
@end

@implementation TIoTCloudStorageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializaVariable];
    
    [self setupUIViews];
}

- (void)initializaVariable {
    self.dayDateString = @"";
    self.kTopPadding = 15; //距离日历间距
    self.kLeftPadding = 50; //左边距
    self.kItemWith = kScreenWidth/2; //每一天长度
    self.kScrollContentWidth = self.kItemWith * 24 + self.kLeftPadding*2; // 总长度
    self.kSliderHeight = 30; //自定义slider高度
}

- (void)setupUIViews {
    
    [self initializedVideo];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat kTopSpace = CGRectGetMaxY(self.imageView.frame) + 10;
    CGFloat kTimeLabelWidth = 230;
    
    self.calendarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.calendarBtn.frame = CGRectMake(10, kTopSpace,100, 40);
    [self.calendarBtn setTitle:@"日历" forState:UIControlStateNormal];
    self.calendarBtn.layer.borderColor = [UIColor blueColor].CGColor;
    self.calendarBtn.layer.borderWidth = 1;
    self.calendarBtn.layer.cornerRadius = 10;
    [self.calendarBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.calendarBtn addTarget:self action:@selector(chooseDate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.calendarBtn];
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - kTimeLabelWidth - 10, kTopSpace, kTimeLabelWidth, 40)];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.text = @"00:00:00";
    [self.view addSubview:self.timeLabel];
    
    //滑动控件底层view
    self.sliderBottomView = [[UIView alloc]initWithFrame:CGRectMake(self.kLeftPadding, CGRectGetMaxY(self.calendarBtn.frame)+self.kTopPadding, self.kScrollContentWidth - self.kLeftPadding*2, self.kSliderHeight)];
    self.sliderBottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.sliderBottomView];
    
    //自定义slider
    TIoTCustomTimeSlider *customTimeSlider = [[TIoTCustomTimeSlider alloc]initWithFrame:CGRectMake(0, 0, self.kScrollContentWidth - self.kLeftPadding*2, self.kSliderHeight)];
    TIoTTimeModel *timeModel = [[TIoTTimeModel alloc]init];
    timeModel.startTime = 0;
    timeModel.endTime = 0;
    customTimeSlider.timeSegmentArray = @[timeModel];
    [self.sliderBottomView addSubview:customTimeSlider];
    [customTimeSlider addObserver:self forKeyPath:@"currentValue" options:NSKeyValueObservingOptionNew context:nil];
    
    //刻度scrollview
    UIScrollView *dateScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.sliderBottomView.frame), kScreenWidth, 50)];
    [self.view addSubview:dateScrollView];
    dateScrollView.delegate = self;
    dateScrollView.contentSize = CGSizeMake(self.kScrollContentWidth, 50);
    
    for (int i = 0; i < 25; i++) {
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(i*self.kItemWith + self.kLeftPadding, 0, 1, 20)];
        lineView.backgroundColor = [UIColor blackColor];
        [dateScrollView addSubview:lineView];
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame), 0, 25, 20)];
        timeLabel.text = [NSString stringWithFormat:@"%d",i];
        [dateScrollView addSubview:timeLabel];
    }
}

#pragma mark - responsed method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        NSLog(@"----%f",[[change objectForKey:NSKeyValueChangeNewKey] floatValue]);
        CGFloat sliderValue= [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        NSInteger secondTime = roundf(sliderValue);
        NSString *timeStr = [self getStampDateStringWithSecond:secondTime];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)initializedVideo {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64+40, self.view.frame.size.width, self.view.frame.size.width * 9 / 16)];
    imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    self.imageView.userInteractionEnabled = YES;
}

- (void)chooseDate {
    TIoTCustomCalendar *view = [[TIoTCustomCalendar alloc] initCalendarFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 470)];
    [self.view addSubview:view];
    view.selectedDateBlock = ^(NSString *dateString) {
        NSLog(@"%@",dateString);
        self.dayDateString = dateString;
    };
}

- (NSString *)getStampDateStringWithSecond:(NSInteger )secondTime {
    NSString *secondString = [NSString getDayFormatTimeFromSecond:[NSString stringWithFormat:@"%ld",secondTime]];
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@",self.dayDateString,secondString];
    NSString *stampDate = [NSString getTimeStampWithString:dateStr withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""]?:@"";
    NSLog(@"%@",stampDate);
    self.timeLabel.text = secondString;
    return stampDate;
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.sliderBottomView.frame = CGRectMake(-scrollView.contentOffset.x + self.kLeftPadding, CGRectGetMaxY(self.calendarBtn.frame)+self.kTopPadding, self.kScrollContentWidth - self.kLeftPadding*2, self.kSliderHeight);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
