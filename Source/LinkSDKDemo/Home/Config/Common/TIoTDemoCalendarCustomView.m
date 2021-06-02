//
//  TIoTDemoCalendarCustomView.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoCalendarCustomView.h"
#import "UIView+TIoTViewExtension.h"
#import "TIoTCustomCalendar.h"

@interface TIoTDemoCalendarCustomView ()
@property (nonatomic, strong, readwrite) NSString *dayDateString;
@property (nonatomic, strong) UIView *maskView; //背景遮罩
@property (nonatomic, strong) UIView *contentView; //背景view
@property (nonatomic, strong) TIoTCustomCalendar *calendarView; //日历控件view
@property (nonatomic, assign) CGFloat kActionBottonHeight;
@end

@implementation TIoTDemoCalendarCustomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCustomSubViews];
    }
    return self;
}

- (void)setupCustomSubViews {
    
    CGFloat kDayLineHight = 61;
    CGFloat kMonthScrollViewHeight = 6 * kDayLineHight;
    
    // 星期栏顶部高度
    CGFloat kWeekHeaderViewHeight = 33;
    
    // 日历顶部高度
    CGFloat kHeaderViewHeight = 62;
    
    CGFloat kIntervalHeight = 8;
    
    CGFloat kButtonViewHeight = 60;
    
    self.kActionBottonHeight = kMonthScrollViewHeight + kWeekHeaderViewHeight + kHeaderViewHeight + kButtonViewHeight;
    if (@available(iOS 11.0, *)) {
        self.kActionBottonHeight = self.kActionBottonHeight + [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
    /// 背景黑色遮罩
    self.maskView = [[UIView alloc]init];
    self.maskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [self addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor colorWithHexString:kVideoDemoBackgoundColor];
    [self.maskView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(self.kActionBottonHeight);
    }];
    
    [self changeViewRectConnerWithView:self.contentView withRect:CGRectMake(0, 0, kScreenWidth, self.kActionBottonHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    
    /// 日历view
    self.calendarView = [[TIoTCustomCalendar alloc] initCalendarFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kMonthScrollViewHeight + kWeekHeaderViewHeight + kHeaderViewHeight)];
    [self.contentView addSubview:self.calendarView];
    __weak typeof(self) weakSelf = self;
    self.calendarView.selectedDateBlock = ^(NSString *dateString) {
        NSLog(@"日历选择日期---%@",dateString);
        weakSelf.dayDateString = dateString;
        
    };
    
    //取消、确认按钮底层view
    UIView *buttonView = [[UIView alloc]init];
    buttonView.backgroundColor = [UIColor whiteColor];
    [self.maskView addSubview:buttonView];
    [buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.maskView);
        make.top.equalTo(self.calendarView.mas_bottom).offset(kIntervalHeight);
        make.height.mas_equalTo(kButtonViewHeight);
    }];
    
    CGFloat kButtonWidthPadding = 30;
    CGFloat kButtonHeight = 45;
    CGFloat kButtonWidth = ([UIScreen mainScreen].bounds.size.width - 3*kButtonWidthPadding)/2;
    
    UIButton *cancelBuuton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBuuton setButtonFormateWithTitlt:@"取消" titleColorHexString:kVideoDemoMainThemeColor font:[UIFont wcPfRegularFontOfSize:17]];
    cancelBuuton.layer.borderColor = [UIColor colorWithHexString:kVideoDemoBorderColor].CGColor;
    cancelBuuton.layer.borderWidth = 1;
    [cancelBuuton addTarget:self action:@selector(cancelChooseDate) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:cancelBuuton];
    [cancelBuuton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(buttonView);
        make.height.mas_equalTo(kButtonHeight);
        make.width.mas_equalTo(kButtonWidth);
        make.left.equalTo(buttonView.mas_left).offset(kButtonWidthPadding);
    }];
    
    UIButton *comfirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [comfirmButton setButtonFormateWithTitlt:@"确定" titleColorHexString:@"#ffffff" font:[UIFont wcPfRegularFontOfSize:17]];
    [comfirmButton setBackgroundColor:[UIColor colorWithHexString:kVideoDemoMainThemeColor]];
    [comfirmButton addTarget:self action:@selector(comfirmChooseDate) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:comfirmButton];
    [comfirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(buttonView);
        make.height.mas_equalTo(kButtonHeight);
        make.width.mas_equalTo(kButtonWidth);
        make.right.equalTo(buttonView.mas_right).offset(-kButtonWidthPadding);
    }];
    
    UIView *placeHoldDownView = [[UIView alloc]init];
    placeHoldDownView.backgroundColor = [UIColor whiteColor];
    [self.maskView addSubview:placeHoldDownView];
    [placeHoldDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(buttonView.mas_bottom);
        make.left.right.bottom.equalTo(self.maskView);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.maskView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.maskView);
        make.bottom.equalTo(self.contentView.mas_top);
    }];
}

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
}

- (void)cancelChooseDate {
    [self dismissView];
}

- (void)comfirmChooseDate {
    [self dismissView];
}

#pragma mark - setting or getting

- (void)setCalendarDateArray:(NSArray<NSString *> *)calendarDateArray {
    _calendarDateArray = calendarDateArray;
    self.calendarView.dateArray = calendarDateArray?:@[];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
