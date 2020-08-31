//
//  WCAddTimeView.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTAddTimeView.h"
#import "TIoTChoseDayView.h"
#import "TIoTAddActionView.h"

@interface TIoTAddTimeView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) UIButton *actionBtn;
@property (nonatomic, strong) UIButton *repeatBtn;
@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation TIoTAddTimeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = kRGBAColor(0, 0, 0, 0.4);
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeView)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate = self;
    [self addGestureRecognizer:singleFingerOne];
    
    self.whiteView = [[UIView alloc] init];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.whiteView];
    [self.whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(400 + kXDPiPhoneBottomSafeAreaHeight);
    }];
    
    self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveClick:) forControlEvents:UIControlEventTouchUpInside];
    self.saveBtn.backgroundColor = [UIColor blueColor];
    [self.whiteView addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.whiteView);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self.whiteView).offset(-kXDPiPhoneBottomSafeAreaHeight);
    }];
    
    self.actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.actionBtn setTitle:@"设备动作" forState:UIControlStateNormal];
    [self.actionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.actionBtn addTarget:self action:@selector(actionClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.whiteView addSubview:self.actionBtn];
    [self.actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.whiteView);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self.saveBtn.mas_top);
    }];
    
    self.repeatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.repeatBtn setTitle:@"重复" forState:UIControlStateNormal];
    [self.repeatBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.repeatBtn addTarget:self action:@selector(repeatClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.whiteView addSubview:self.repeatBtn];
    [self.repeatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.whiteView);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self.actionBtn.mas_top);
    }];
    
    [self.whiteView addSubview:self.datePicker];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.whiteView);
        make.bottom.equalTo(self.repeatBtn.mas_top);
        make.height.mas_equalTo(200);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"添加定时";
    [self.whiteView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.datePicker.mas_top);
        make.centerX.equalTo(self.whiteView);
        make.height.mas_equalTo(50);
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.whiteView]) {
        return NO;
    }
    return YES;
}

- (void)showView{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

- (void)removeView{
    [self removeFromSuperview];
}

#pragma mark eventResponse
- (void)saveClick:(id)sender{
    if ([self.delegate respondsToSelector:@selector(saveData)]) {
        [self.delegate saveData];
    }
    [self removeView];
}

- (void)actionClick:(id)sender{
    
    TIoTAddActionView *dayView = [[TIoTAddActionView alloc] init];
    [self.whiteView addSubview:dayView];
    [dayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.whiteView);
        make.width.mas_equalTo(kScreenWidth);
        make.left.equalTo(self.whiteView.mas_right);
    }];
    
    [self.whiteView layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        [dayView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.whiteView);
            make.width.mas_equalTo(kScreenWidth);
            make.left.equalTo(self.whiteView);
        }];
        [self.whiteView layoutIfNeeded];
    }];
}

- (void)repeatClick:(id)sender{
    TIoTChoseDayView *dayView = [[TIoTChoseDayView alloc] init];
    [self.whiteView addSubview:dayView];
    [dayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.whiteView);
        make.width.mas_equalTo(kScreenWidth);
        make.left.equalTo(self.whiteView.mas_right);
    }];
    
    [self.whiteView layoutIfNeeded];
    
    [UIView animateWithDuration:0.25 animations:^{
        [dayView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.whiteView);
            make.width.mas_equalTo(kScreenWidth);
            make.left.equalTo(self.whiteView);
        }];
        
        [self.whiteView layoutIfNeeded];
    }];
}

- (void)dateChange:(UIDatePicker *)datePicker {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //设置时间格式
    formatter.dateFormat = @"yyyy年MM月dd日";
    //NSString *dateStr = [formatter  stringFromDate:datePicker.date];

}

#pragma mark lazy
- (UIDatePicker *)datePicker{
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.backgroundColor = [UIColor whiteColor];
        
        //设置日期模式(Displays month, day, and year depending on the locale setting)
        _datePicker.datePickerMode = UIDatePickerModeTime;
        // 设置当前显示时间
        
        [_datePicker setDate:[NSDate date] animated:YES];
        // 设置显示最大时间（此处为当前时间）
        //[_pickerView setMaximumDate:[NSDate date]];
        
        //设置时间格式
        
        //监听DataPicker的滚动
        [_datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

@end
