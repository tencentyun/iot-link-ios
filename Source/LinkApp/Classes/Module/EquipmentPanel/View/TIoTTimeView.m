//
//  WCTimeView.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/25.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTTimeView.h"

@interface TIoTTimeView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, copy) NSString *dateStr;

@end

@implementation TIoTTimeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = kRGBAColor(0, 0, 0, 0.7);
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate = self;
    [self addGestureRecognizer:singleFingerOne];
    
    
    self.whiteView = [[UIView alloc] init];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.whiteView];
    [self.whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(282);
    }];
    
    [self layoutIfNeeded];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: self.whiteView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20,20)];
    //创建 layer
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.whiteView.bounds;
    //赋值
    maskLayer.path = maskPath.CGPath;
    self.whiteView.layer.mask = maskLayer;
    
//    self.titleLab = [[UILabel alloc] init];
//    self.titleLab.textColor = kRGBColor(51, 51, 51);
//    self.titleLab.font = [UIFont wcPfSemiboldFontOfSize:18];
//    [self.whiteView addSubview:self.titleLab];
//    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.equalTo(self.whiteView).offset(20);
//    }];
    
    UIButton *cancelB = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelB setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
    [cancelB setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    [cancelB addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [cancelB.titleLabel setFont:[UIFont wcPfRegularFontOfSize:14]];
    [self.whiteView addSubview:cancelB];
    [cancelB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.whiteView).offset(20);
        make.top.equalTo(self.whiteView).offset(15);
    }];
    
    UIButton *doneB = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneB setTitle:NSLocalizedString(@"confirm", @"确定") forState:UIControlStateNormal];
    [doneB setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
    [doneB.titleLabel setFont:[UIFont wcPfRegularFontOfSize:14]];
    [doneB addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [self.whiteView addSubview:doneB];
    [doneB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.whiteView).offset(-20);
        make.top.equalTo(self.whiteView).offset(15);
    }];
    
    
    [self.whiteView addSubview:self.datePicker];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.whiteView);
        make.bottom.equalTo(self.whiteView);
        make.top.equalTo(self.whiteView.mas_top).offset(54);
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.whiteView]) {
        return NO;
    }
    return YES;
}

- (void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)hide{
    [self removeFromSuperview];
}

- (void)done
{
    [self hide];
    if (self.updateData) {
        //NSDictionary *dic = self.dataArr[indexPath.row];
        self.updateData(@{self.dic[@"id"]:self.dateStr});
    }
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    self.titleLab.text = dic[@"name"];
    [self.datePicker setDate:[NSDate dateWithTimeIntervalSince1970:[[NSString stringWithFormat:@"%@",dic[@"status"][@"Value"]] doubleValue]] animated:YES];
    self.dateStr = dic[@"status"][@"Value"];
}

- (void)dateChange:(UIDatePicker *)datePicker {
    NSTimeInterval timeInterval = [datePicker.date timeIntervalSince1970];
    NSString *result = [NSString stringWithFormat:@"%.0f",timeInterval];
    self.dateStr = result;
}

#pragma mark lazy
- (UIDatePicker *)datePicker{
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.backgroundColor = kBgColor;
        
        //设置日期模式(Displays month, day, and year depending on the locale setting)
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
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
