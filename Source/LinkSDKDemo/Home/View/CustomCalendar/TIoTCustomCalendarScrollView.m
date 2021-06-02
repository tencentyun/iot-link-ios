//
//  TIoTCustomCalendarScrollView.m
//  LinkApp
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCustomCalendarScrollView.h"
#import "TIoTCustomCalendarCell.h"
#import "TIoTCustomCalendarMonth.h"
#import "NSDate+TIoTCustomCalendar.h"
#import "TIoTDemoDateTool.h"

@interface TIoTCustomCalendarScrollView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *leftCollectionView;
@property (nonatomic, strong) UICollectionView *middleCollectionView;
@property (nonatomic, strong) UICollectionView *rightCollectionView;
@property (nonatomic, strong) NSDate *currentMonthDate;
@property (nonatomic, strong) NSMutableArray *monthArray;
@property (nonatomic, strong) NSArray *dateArray;

@property (nonatomic, assign) NSInteger choiceYear;
@property (nonatomic, assign) NSInteger choiceMonth;
@property (nonatomic, assign) NSInteger choiceDay;
@property (nonatomic, strong) NSIndexPath *selectedIndex;

@end

@implementation TIoTCustomCalendarScrollView

static NSString *const kTIoTCalandarDayCellIdentifier = @"kTIoTCalandarDayCellIdentifier";

#pragma mark - Initialiaztion

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.bounces = NO;
        self.delegate = self;
        
        self.contentSize = CGSizeMake(3 * self.bounds.size.width, self.bounds.size.height);
        [self setContentOffset:CGPointMake(self.bounds.size.width, 0.0) animated:NO];
        
        self.currentMonthDate = [NSDate date];
        [self setupCollectionViews];
    }
    return self;
}

- (void)setInputDateArray:(NSArray *)inputDateArray {
    _inputDateArray = inputDateArray;
    self.dateArray = [NSArray arrayWithArray:inputDateArray?:@[]];
}

- (NSMutableArray *)monthArray {
    
    if (_monthArray == nil) {
        
        _monthArray = [NSMutableArray arrayWithCapacity:4];
        
        NSDate *previousMonthDate = [self.currentMonthDate previousMonthDate];
        NSDate *nextMonthDate = [self.currentMonthDate nextMonthDate];
        
        [_monthArray addObject:[[TIoTCustomCalendarMonth alloc] initWithDate:previousMonthDate]];
        [_monthArray addObject:[[TIoTCustomCalendarMonth alloc] initWithDate:self.currentMonthDate]];
        [_monthArray addObject:[[TIoTCustomCalendarMonth alloc] initWithDate:nextMonthDate]];
        [_monthArray addObject:[self previousMonthDaysForPreviousDate:previousMonthDate]]; // 存储左边的月份的前一个月份的天数，用来填充左边月份的首部
        
        // 发通知，更改当前月份标题
        [self notifyToChangeCalendarHeader];
    }
    
    return _monthArray;
}

- (void)setCalendarThemeColor:(UIColor *)calendarThemeColor {
    _calendarThemeColor = calendarThemeColor;
    [self.leftCollectionView reloadData];
    [self.middleCollectionView reloadData];
    [self.rightCollectionView reloadData];
}

- (NSNumber *)previousMonthDaysForPreviousDate:(NSDate *)date {
    return [[NSNumber alloc] initWithInteger:[[date previousMonthDate] totalDaysInMonth]];
}

- (void)setupCollectionViews {
        
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake((self.bounds.size.width-10) / 7.0, 60);
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    CGFloat scrollViewWidth = self.bounds.size.width;
    CGFloat scrollViewHeight = self.bounds.size.height;
    
    self.leftCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, scrollViewWidth, scrollViewHeight) collectionViewLayout:flowLayout];
    [self setupCollentionViewConfig:self.leftCollectionView];
    [self addSubview:self.leftCollectionView];
    
    self.middleCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(scrollViewWidth, 0.0, scrollViewWidth, scrollViewHeight) collectionViewLayout:flowLayout];
    [self setupCollentionViewConfig:self.middleCollectionView];
    [self addSubview:self.middleCollectionView];
    
    self.rightCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(2 * scrollViewWidth, 0.0, scrollViewWidth, scrollViewHeight) collectionViewLayout:flowLayout];
    [self setupCollentionViewConfig:self.rightCollectionView];
    [self addSubview:self.rightCollectionView];

}

- (void)setupCollentionViewConfig:(UICollectionView *)collectionView {
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerClass:[TIoTCustomCalendarCell class] forCellWithReuseIdentifier:kTIoTCalandarDayCellIdentifier];
}

#pragma mark -

- (void)notifyToChangeCalendarHeader {
    
    TIoTCustomCalendarMonth *currentMonthInfo = self.monthArray[1];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [userInfo setObject:[[NSNumber alloc] initWithInteger:currentMonthInfo.year] forKey:@"year"];
    [userInfo setObject:[[NSNumber alloc] initWithInteger:currentMonthInfo.month] forKey:@"month"];
    
    NSNotification *notify = [[NSNotification alloc] initWithName:@"TIoTCustomCalendarChangeDateNotification" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
}

- (void)refreshCurrentMonth {
    
    // 如果现在就在当前月份，则不执行操作
    TIoTCustomCalendarMonth *currentMonthInfo = self.monthArray[1];
    if ((currentMonthInfo.month == [[NSDate date] dateMonth]) && (currentMonthInfo.year == [[NSDate date] dateYear])) {
        return;
    }
    
    self.currentMonthDate = [NSDate date];
    
    NSDate *previousMonthDate = [self.currentMonthDate previousMonthDate];
    NSDate *nextMonthDate = [self.currentMonthDate nextMonthDate];
    
    [self.monthArray removeAllObjects];
    [self.monthArray addObject:[[TIoTCustomCalendarMonth alloc] initWithDate:previousMonthDate]];
    [self.monthArray addObject:[[TIoTCustomCalendarMonth alloc] initWithDate:self.currentMonthDate]];
    [self.monthArray addObject:[[TIoTCustomCalendarMonth alloc] initWithDate:nextMonthDate]];
    [self.monthArray addObject:[self previousMonthDaysForPreviousDate:previousMonthDate]];
    
    // 刷新数据
    [self.middleCollectionView reloadData];
    [self.leftCollectionView reloadData];
    [self.rightCollectionView reloadData];
    
}

#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 42; //7*6
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TIoTCustomCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTIoTCalandarDayCellIdentifier forIndexPath:indexPath];
    
    if (collectionView == self.leftCollectionView) {
        
        TIoTCustomCalendarMonth *monthInfo = self.monthArray[0];
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.currentMonthTotalDays;
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday + 1];
            cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
            cell.lunarLabel.text = [TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:monthInfo.month year:monthInfo.year];
            
            for (NSString *dateString in self.dateArray) {
                NSArray *dateTemp = [dateString componentsSeparatedByString:@"-"];
                NSString *yearString = dateTemp.firstObject;
                NSString *monthString = dateTemp[1];
                NSString *dayString = dateTemp.lastObject;
                
                // 标识
                if ((monthInfo.month == monthString.integerValue) && (monthInfo.year == yearString.integerValue)) {
                    if (indexPath.row == dayString.integerValue + firstWeekday - 1) {
                        cell.todayBackCircle.backgroundColor = self.calendarThemeColor;
                        cell.todayLabel.textColor = [UIColor blackColor];
                        cell.lunarLabel.textColor = [UIColor colorWithHexString:kVideoDemoWeekLabelColor];
                    } else {
                        cell.todayBackCircle.backgroundColor = [UIColor clearColor];
                    }
                } else {
                    cell.todayBackCircle.backgroundColor = [UIColor clearColor];
                }
            }
            
        }
        // 补前后月的日期，复位
        else if (indexPath.row < firstWeekday) {
            int totalDaysOflastMonth = [self.monthArray[3] intValue];
            cell.todayLabel.text = @"";//[NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
            cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
            cell.todayBackCircle.backgroundColor = [UIColor clearColor];
            if (monthInfo.month == 1) {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:12 year:(monthInfo.year - 1)];
            }else {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:(monthInfo.month - 1) year:monthInfo.year];
            }
        } else if (indexPath.row >= firstWeekday + totalDays) {
            cell.todayLabel.text = @"";//[NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
            cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
            cell.todayBackCircle.backgroundColor = [UIColor clearColor];
            if (monthInfo.month == 12) {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:1 year:(monthInfo.year + 1)];
            }else {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:(monthInfo.month + 1) year:monthInfo.year];
            }
        }
        
        cell.userInteractionEnabled = NO;
        
    }
    else if (collectionView == self.middleCollectionView) {
        
        TIoTCustomCalendarMonth *monthInfo = self.monthArray[1];
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.currentMonthTotalDays;
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday + 1];
            cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
            cell.lunarLabel.text = [TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:monthInfo.month year:monthInfo.year];
            cell.lunarLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
            cell.userInteractionEnabled = YES;
            
            for (NSString *dateString in self.dateArray) {
                NSArray *dateTemp = [dateString componentsSeparatedByString:@"-"];
                NSString *yearString = dateTemp.firstObject;
                NSString *monthString = dateTemp[1];
                NSString *dayString = dateTemp.lastObject;
                
                // 标识
                if ((monthInfo.month == monthString.integerValue) && (monthInfo.year == yearString.integerValue)) {
                    if (indexPath.row == dayString.integerValue + firstWeekday - 1) {
                        cell.todayBackCircle.backgroundColor = self.calendarThemeColor;
                        cell.todayLabel.textColor = [UIColor blackColor];
                        cell.lunarLabel.textColor = [UIColor colorWithHexString:kVideoDemoWeekLabelColor];
                    } else {
                        cell.todayBackCircle.backgroundColor = [UIColor clearColor];
                    }
                } else {
                    cell.todayBackCircle.backgroundColor = [UIColor clearColor];
                    if ([cell.todayLabel.textColor isEqual:[UIColor whiteColor]]) {
                        cell.todayBackCircle.backgroundColor = self.calendarThemeColor;
                    }
                }
            }
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay) fromDate:[NSDate date]];
            
            //修改当天为“今天”
            if (components.day == cell.todayLabel.text.integerValue && components.year == monthInfo.year && components.month == monthInfo.month) {
                cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoGreenColor];
                cell.todayLabel.text = @"今天";
                NSString *lundarDayString = [TIoTDemoDateTool getLunarCalendarWithDay:monthInfo.day month:monthInfo.month year:monthInfo.year];
                if ([lundarDayString isEqualToString:cell.lunarLabel.text]) {
                    cell.lunarLabel.textColor = [UIColor colorWithHexString:kVideoDemoGreenColor];
                }
            }
            
            if (self.choiceYear == monthInfo.year && self.choiceMonth == monthInfo.month && self.choiceDay == cell.todayLabel.text.intValue) {
                [cell setSelected:YES];
            }
            
        }
        // 补前后月的日期，复位
        else if (indexPath.row < firstWeekday) {
            TIoTCustomCalendarMonth *lastMonthInfo = self.monthArray[0];
            NSInteger totalDaysOflastMonth = lastMonthInfo.currentMonthTotalDays;
            cell.todayLabel.text = @"";//[NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
            cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
            cell.todayBackCircle.backgroundColor = [UIColor clearColor];
            
            if (monthInfo.month == 1) {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:12 year:(monthInfo.year - 1)];
            }else {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:(monthInfo.month - 1) year:monthInfo.year];
            }
            cell.userInteractionEnabled = NO;
        } else if (indexPath.row >= firstWeekday + totalDays) {
            cell.todayLabel.text = @"";//[NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
            cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
            cell.todayBackCircle.backgroundColor = [UIColor clearColor];
            if (monthInfo.month == 12) {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:1 year:(monthInfo.year + 1)];
            }else {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:(monthInfo.month + 1) year:monthInfo.year];
            }
            cell.userInteractionEnabled = NO;
        }
        
    }
    else if (collectionView == self.rightCollectionView) {
        
        TIoTCustomCalendarMonth *monthInfo = self.monthArray[2];
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.currentMonthTotalDays;
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday + 1];
            cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
            cell.lunarLabel.text = [TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:monthInfo.month year:monthInfo.year];
            
            for (NSString *dateString in self.dateArray) {
                NSArray *dateTemp = [dateString componentsSeparatedByString:@"-"];
                NSString *yearString = dateTemp.firstObject;
                NSString *monthString = dateTemp[1];
                NSString *dayString = dateTemp.lastObject;
                
                // 标识
                if ((monthInfo.month == monthString.integerValue) && (monthInfo.year == yearString.integerValue)) {
                    if (indexPath.row == dayString.integerValue + firstWeekday - 1) {
                        cell.todayBackCircle.backgroundColor = self.calendarThemeColor;
                        cell.todayLabel.textColor = [UIColor blackColor];
                        cell.lunarLabel.textColor = [UIColor colorWithHexString:kVideoDemoWeekLabelColor];
                    } else {
                        cell.todayBackCircle.backgroundColor = [UIColor clearColor];
                    }
                } else {
                    cell.todayBackCircle.backgroundColor = [UIColor clearColor];
                }
            }

        }
        // 补前后月的日期，复位
        else if (indexPath.row < firstWeekday) {
            
            TIoTCustomCalendarMonth *lastMonthInfo = self.monthArray[1];
            NSInteger totalDaysOflastMonth = lastMonthInfo.currentMonthTotalDays;
            cell.todayLabel.text = @"";//[NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
            cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
            cell.todayBackCircle.backgroundColor = [UIColor clearColor];
            if (monthInfo.month == 1) {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:12 year:(monthInfo.year - 1)];
            }else {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:(monthInfo.month - 1) year:monthInfo.year];
            }
        } else if (indexPath.row >= firstWeekday + totalDays) {
            cell.todayLabel.text = @"";//[NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
            cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
            cell.todayBackCircle.backgroundColor = [UIColor clearColor];
            if (monthInfo.month == 12) {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:1 year:(monthInfo.year + 1)];
            }else {
                cell.lunarLabel.text = @"";//[TIoTDemoDateTool getLunarCalendarWithDay:cell.todayLabel.text.integerValue month:(monthInfo.month + 1) year:monthInfo.year];
            }
        }
        
        cell.userInteractionEnabled = NO;
        
    }
    
    return cell;
    
}


#pragma mark - UICollectionViewDeleagate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //回复上一次所选日期显示颜色
    if (self.selectedIndex) {
        TIoTCustomCalendarMonth *monthInfo = self.monthArray[1];
        TIoTCustomCalendarCell *cell = (TIoTCustomCalendarCell *)[collectionView cellForItemAtIndexPath:self.selectedIndex];
        [cell setSelected:NO];
        
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.currentMonthTotalDays;
        
        cell.lunarLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
        cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
        // 当前月
        if (self.selectedIndex.row >= firstWeekday && self.selectedIndex.row < firstWeekday + totalDays) {
            
            // 标识
            for (NSString *dateString in self.dateArray) {
                NSArray *dateTemp = [dateString componentsSeparatedByString:@"-"];
                NSString *yearString = dateTemp.firstObject;
                NSString *monthString = dateTemp[1];
                NSString *dayString = dateTemp.lastObject;
                if ((monthInfo.month == monthString.integerValue) && (monthInfo.year == yearString.integerValue)) {
                    
                    if (self.selectedIndex.row == dayString.integerValue + firstWeekday - 1) {
                        cell.todayBackCircle.backgroundColor = self.calendarThemeColor;
                        cell.todayLabel.textColor = [UIColor blackColor];
                        cell.lunarLabel.textColor = [UIColor colorWithHexString:kVideoDemoWeekLabelColor];
                    } else {
                        cell.todayBackCircle.backgroundColor = [UIColor clearColor];
                    }
                    
                }
            }
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay) fromDate:[NSDate date]];
            
            NSDateComponents *currentComponents = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay) fromDate:self.currentMonthDate];
            NSDate *currentDate = [calendar dateFromComponents:currentComponents];
            
            //修改“今天”
            NSInteger day = [cell.todayLabel.text integerValue]?:[currentDate dateDay];
            if (components.day == day && components.year == monthInfo.year && components.month == monthInfo.month) {
                cell.todayLabel.textColor = [UIColor colorWithHexString:kVideoDemoGreenColor];
                NSString *lundarDayString = [TIoTDemoDateTool getLunarCalendarWithDay:monthInfo.day month:monthInfo.month year:monthInfo.year];
                if ([lundarDayString isEqualToString:cell.lunarLabel.text]) {
                    cell.lunarLabel.textColor = [UIColor colorWithHexString:kVideoDemoGreenColor];
                }
            }
        }
        
    }
    
    self.selectedIndex = indexPath;
    
    //响应blcok
    if (self.didSelectDayHandler != nil) {
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay) fromDate:self.currentMonthDate];
        NSDate *currentDate = [calendar dateFromComponents:components];
        
        TIoTCustomCalendarCell *cell = (TIoTCustomCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        NSInteger year = [currentDate dateYear];
        NSInteger month = [currentDate dateMonth];
        NSInteger day = [cell.todayLabel.text integerValue]?:[currentDate dateDay];
        
        self.choiceYear = year;
        self.choiceMonth = month;
        self.choiceDay = day;
        self.didSelectDayHandler(year, month, day); // 执行回调
    }
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView != self) {
        return;
    }
    
    // 向右滑动
    if (scrollView.contentOffset.x < self.bounds.size.width) {
        [self leftSlide];
    }
    // 向左滑动
    else if (scrollView.contentOffset.x > self.bounds.size.width) {
        [self rightSlide];
        
    }
    [self refreshUIWtih:scrollView];
    
}

- (void)leftSlide {
    self.currentMonthDate = [self.currentMonthDate previousMonthDate];
    NSDate *previousDate = [self.currentMonthDate previousMonthDate];
    
    // 数组中最左边的月份现在作为中间的月份，中间的作为右边的月份，新的左边的需要重新获取
    TIoTCustomCalendarMonth *currentMothInfo = self.monthArray[0];
    TIoTCustomCalendarMonth *nextMonthInfo = self.monthArray[1];
    
    
    TIoTCustomCalendarMonth *olderNextMonthInfo = self.monthArray[2];
    
    // 复用 TIoTCustomCalendarMonth 对象
    olderNextMonthInfo.currentMonthTotalDays = [previousDate totalDaysInMonth];
    olderNextMonthInfo.firstWeekday = [previousDate firstWeekDayInMonth];
    olderNextMonthInfo.year = [previousDate dateYear];
    olderNextMonthInfo.month = [previousDate dateMonth];
    TIoTCustomCalendarMonth *previousMonthInfo = olderNextMonthInfo;
    
    NSNumber *prePreviousMonthDays = [self previousMonthDaysForPreviousDate:[self.currentMonthDate previousMonthDate]];
    
    [self.monthArray removeAllObjects];
    [self.monthArray addObject:previousMonthInfo];
    [self.monthArray addObject:currentMothInfo];
    [self.monthArray addObject:nextMonthInfo];
    [self.monthArray addObject:prePreviousMonthDays];
    
    [self refreshUIWtih:self];
}

- (void)rightSlide {
    
    self.currentMonthDate = [self.currentMonthDate nextMonthDate];
    NSDate *nextDate = [self.currentMonthDate nextMonthDate];
    
    // 数组中最右边的月份现在作为中间的月份，中间的作为左边的月份，新的右边的需要重新获取
    TIoTCustomCalendarMonth *previousMonthInfo = self.monthArray[1];
    TIoTCustomCalendarMonth *currentMothInfo = self.monthArray[2];
    
    
    TIoTCustomCalendarMonth *olderPreviousMonthInfo = self.monthArray[0];
    
    NSNumber *prePreviousMonthDays = [[NSNumber alloc] initWithInteger:olderPreviousMonthInfo.currentMonthTotalDays]; // 先保存 olderPreviousMonthInfo 的月天数
    
    // 复用 TIoTCustomCalendarMonth 对象
    olderPreviousMonthInfo.currentMonthTotalDays = [nextDate totalDaysInMonth];
    olderPreviousMonthInfo.firstWeekday = [nextDate firstWeekDayInMonth];
    olderPreviousMonthInfo.year = [nextDate dateYear];
    olderPreviousMonthInfo.month = [nextDate dateMonth];
    TIoTCustomCalendarMonth *nextMonthInfo = olderPreviousMonthInfo;

    
    [self.monthArray removeAllObjects];
    [self.monthArray addObject:previousMonthInfo];
    [self.monthArray addObject:currentMothInfo];
    [self.monthArray addObject:nextMonthInfo];
    [self.monthArray addObject:prePreviousMonthDays];
    
    [self refreshUIWtih:self];
}

- (void)refreshUIWtih:(UIScrollView *)scrollView {
    [self.middleCollectionView reloadData]; // 中间的 collectionView 先刷新数据
    [scrollView setContentOffset:CGPointMake(self.bounds.size.width, 0.0) animated:NO]; // 然后变换位置
    [self.leftCollectionView reloadData]; // 最后两边的 collectionView 也刷新数据
    [self.rightCollectionView reloadData];
    
    // 发通知，更改当前月份标题
    [self notifyToChangeCalendarHeader];
}

@end


