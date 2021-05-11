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

@interface TIoTCloudStorageVC ()
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) NSString *dayDateString; //选择天日期
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation TIoTCloudStorageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dayDateString = @"";
    [self setupUIViews];
}

- (void)setupUIViews {
    
    [self initializedVideo];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat kTopSpace = CGRectGetMaxY(self.imageView.frame) + 10;
    CGFloat kTimeLabelWidth = 230;
    
    UIButton *calendarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    calendarBtn.frame = CGRectMake(20, kTopSpace,100, 40);
    [calendarBtn setTitle:@"日历" forState:UIControlStateNormal];
    calendarBtn.layer.borderColor = [UIColor blueColor].CGColor;
    calendarBtn.layer.borderWidth = 1;
    calendarBtn.layer.cornerRadius = 10;
    [calendarBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [calendarBtn addTarget:self action:@selector(chooseDate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:calendarBtn];
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - kTimeLabelWidth - 10, kTopSpace, kTimeLabelWidth, 40)];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.text = @"00:00:00";
    [self.view addSubview:self.timeLabel];
    
    
    CGFloat kTopPadding = 30; //距离日历间距
    CGFloat kLeftPadding = 50; //左边距
    CGFloat kItemWith = kScreenWidth/2; //每一天长度
    CGFloat kScrollContentWidth = kItemWith * 24 + kLeftPadding*2; // 总长度
    
    UIScrollView *dateScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(calendarBtn.frame)+kTopPadding, kScreenWidth, 50)];
    [self.view addSubview:dateScrollView];
    dateScrollView.contentSize = CGSizeMake(kScrollContentWidth, 50);
    
    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(kLeftPadding, 0, kScrollContentWidth - kLeftPadding*2, 30)];
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 86400; //24*60*60
    [self.slider addTarget:self action:@selector(sliderDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sliderTapped:)];
    [self.slider addGestureRecognizer:tap];
    self.slider.continuous = NO;
    [dateScrollView addSubview:self.slider];
    
    for (int i = 0; i < 25; i++) {
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(i*kItemWith + kLeftPadding, CGRectGetMaxY(self.slider.frame), 1, 20)];
        lineView.backgroundColor = [UIColor blackColor];
        [dateScrollView addSubview:lineView];
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame), CGRectGetMaxY(self.slider.frame), 25, 20)];
        timeLabel.text = [NSString stringWithFormat:@"%d",i];
        [dateScrollView addSubview:timeLabel];
    }
}

#pragma mark - responsed method

- (void)initializedVideo {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64+25, self.view.frame.size.width, self.view.frame.size.width * 9 / 16)];
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

- (void)sliderDidChangeValue:(UISlider *)sliderControl {
    
    NSInteger secondTime = roundf(sliderControl.value);
    NSString *timeStr = [self getStampDateStringWithSecond:secondTime];
}

- (void)sliderTapped:(UITapGestureRecognizer *)gesture {
    
    CGPoint tapTouchPoint = [gesture locationInView:self.slider];
    CGFloat value = (self.slider.maximumValue - self.slider.minimumValue) * (tapTouchPoint.x / self.slider.frame.size.width);
    [self.slider setValue:value animated:YES];
    
    NSInteger secondTime = roundf(value);
    NSString *timeStr = [self getStampDateStringWithSecond:secondTime];
}

- (NSString *)getStampDateStringWithSecond:(NSInteger )secondTime {
    NSString *secondString = [NSString getDayFormatTimeFromSecond:[NSString stringWithFormat:@"%ld",secondTime]];
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@",self.dayDateString,secondString];
    NSString *stampDate = [NSString getTimeStampWithString:dateStr withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""]?:@"";
    NSLog(@"%@",stampDate);
    self.timeLabel.text = secondString;
    return stampDate;
}

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, 10);
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
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
