//
//  TIoTAutoCustomTimePeriodView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/15.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoCustomTimePeriodView.h"
#import "UIView+XDPExtension.h"
#import "TIoTIntelligentBottomActionView.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTAutoCustomTimePeriodView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIView *backMaskView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, strong) NSArray *pickDataArray;
@property (nonatomic, strong) UIView *bottomBackView;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;

@property (nonatomic, strong) NSString *choiceTimePeriod; //用户选择的时间段
@end

@implementation TIoTAutoCustomTimePeriodView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUISubview];
    }
    return self;
}

- (void)setupUISubview {
    
    CGFloat kTopViewHeight = 50;
    CGFloat kPickViewHeight = 272; //pickview 高度
    CGFloat kBottomViewHeight = 56;//底部view高度
    CGFloat KIntervalHeight = 8;
    CGFloat KItemHeight = 50;
    
    CGFloat kHeight = kTopViewHeight + kPickViewHeight + KItemHeight + KIntervalHeight+ kBottomViewHeight;
    if (@available (iOS 11.0, *)) {
        kHeight = kHeight + [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        kBottomViewHeight = kBottomViewHeight + [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
    self.backMaskView = [[UIView alloc]init];
    self.backMaskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [self addSubview:self.backMaskView];
    [self.backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self changeViewRectConnerWithView:self.contentView withRect:CGRectMake(0, 0, kScreenWidth, kHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    [self.backMaskView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.backMaskView);
        make.height.mas_equalTo(kHeight);
    }];
    
    //MARK:顶部视图
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(kTopViewHeight);
    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"backNac"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBackForward) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView.mas_left).offset(10);
        make.centerY.equalTo(self.topView.mas_centerY);
        make.height.width.mas_equalTo(20);
    }];
    
    UILabel *topTitle = [[UILabel alloc]init];
    [topTitle setLabelFormateTitle: NSLocalizedString(@"auto_repeatTiming_custom", @"自定义") font:[UIFont wcPfMediumFontOfSize:16] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    [self.topView addSubview:topTitle];
    [topTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.centerX.equalTo(self.topView);
    }];
    
    UIView *slideLine = [[UIView alloc]init];
    slideLine.backgroundColor = [UIColor colorWithHexString:@"#F3F3F5"];
    [self.contentView addSubview:slideLine];
    [slideLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    //MARK:中部pickview视图
    [self.contentView addSubview:self.pickView];
    [self.pickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(slideLine.mas_bottom);
        make.height.mas_equalTo(kPickViewHeight);
    }];
    
    //MARK:底部视图
    self.bottomBackView = [[UIView alloc]init];
    self.bottomBackView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.bottomBackView];
    [self.bottomBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.pickView.mas_bottom).offset(KIntervalHeight);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
    [self.bottomBackView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.bottomBackView);
        make.height.mas_equalTo(KItemHeight);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.backMaskView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.backMaskView);
        make.bottom.equalTo(self.contentView.mas_top);
    }];
}

- (void)setPreviousSelectedTime:(NSString *)previousSelectedTime {
    _previousSelectedTime = previousSelectedTime;

    //对于传入的时间字符串需要拆解，按内容显示
    if (![NSString isNullOrNilWithObject:self.previousSelectedTime]) {
        if ([self.previousSelectedTime containsString:@"-"]) {
            NSArray *previousArray = [self.previousSelectedTime componentsSeparatedByString:@"-"];
            if ([previousArray.firstObject containsString:@":"]) {
                NSArray *fromArray = [previousArray.firstObject componentsSeparatedByString:@":"];
                NSString *fromHour = fromArray.firstObject;
                NSString *fromMinut = fromArray.lastObject;

                NSInteger fromHourIndex = fromHour.intValue;
                NSInteger fromMinutIndex = fromMinut.intValue;

                [self.pickView selectRow:fromHourIndex inComponent:0 animated:NO];
                [self.pickView selectRow:fromMinutIndex inComponent:1 animated:NO];
            }

            if ([previousArray.lastObject containsString:@":"]) {
                NSArray *toArray = [previousArray.lastObject componentsSeparatedByString:@":"];
                NSString *toHour = toArray.firstObject;
                NSString *toMinut = toArray.lastObject;

                NSInteger toHourIndex = toHour.intValue;
                NSInteger toMinutIndex = toMinut.intValue;

                [self.pickView selectRow:toHourIndex inComponent:3 animated:NO];
                [self.pickView selectRow:toMinutIndex inComponent:4 animated:NO];
            }
        }
    }else {
        [self.pickView selectRow:0 inComponent:0 animated:NO];
        [self.pickView selectRow:0 inComponent:1 animated:NO];

        NSMutableArray *toHourArray = self.pickDataArray[3];
        NSMutableArray *toMInutArray = self.pickDataArray[4];
        [self.pickView selectRow:toHourArray.count - 1 inComponent:3 animated:NO];
        [self.pickView selectRow:toMInutArray.count - 1 inComponent:4 animated:NO];
    }

    self.choiceTimePeriod = [NSString stringWithFormat:@"00:00-23:59"];
}

#pragma mark - event

/**
 返回重复选择定时自定义view
 */
- (void)goBackForward {
    [self cancelChoice];
    [self removeFromSuperview];
}

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
}

- (void)cancelChoice {
    if (self.cancelChoiceTimePeriodBlock) {
        self.cancelChoiceTimePeriodBlock();
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.pickDataArray.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    NSMutableArray *itemArray = self.pickDataArray[component];
    return  itemArray.count;
}

#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickDataArray[component][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    NSMutableArray *itemArray = self.pickDataArray[component];
    
    NSMutableArray *toHourArray = self.pickDataArray[3];
    NSMutableArray *toMInutArray = self.pickDataArray[4];
    
    NSInteger fromHour = 0;
    NSInteger fromMinut = 0;
    NSString *line = @"-";
    NSInteger toHour = toHourArray.count - 1;
    NSInteger toMinut = toMInutArray.count - 1;
    if (component == 0) {
        fromHour = row;
    }else if (component == 1){
        fromMinut = row;
    }else if (component == 2) {
        
    }else if (component == 3) {
        toHour = row;
    }else {
        toMinut = row;
    }
    
    NSString *fromHourString = [NSString stringWithFormat:@"%ld",fromHour];
    NSString *fromMinutString = [NSString stringWithFormat:@"%ld",fromMinut];
    NSString *toHourString = [NSString stringWithFormat:@"%ld",toHour];
    NSString *toMinutString = [NSString stringWithFormat:@"%ld",toMinut];
    if (fromHour<10) {
        fromHourString = [NSString stringWithFormat:@"0%ld",fromHour];
    }
    if (fromMinut<10) {
        fromMinutString = [NSString stringWithFormat:@"0%ld",fromMinut];
    }
    if (toHour<10) {
        toHourString = [NSString stringWithFormat:@"0%ld",toHour];
    }
    if (toMinut<10) {
        toMinutString = [NSString stringWithFormat:@"0%ld",toMinut];
    }
    
    self.choiceTimePeriod = [NSString stringWithFormat:@"%@:%@%@%@:%@",fromHourString,fromMinutString,line,toHourString,toMinutString];
}


#pragma mark - lazy loading

- (UIPickerView *)pickView {
    if (!_pickView) {
        _pickView = [[UIPickerView alloc]init];
        _pickView.delegate = self;
        _pickView.dataSource = self;
//        _pickView.showsSelectionIndicator = YES;
        _pickView.backgroundColor = [UIColor whiteColor];
    }
    return _pickView;
}

- (NSArray *)pickDataArray {
    if (!_pickDataArray) {
        
        NSMutableArray *fromHourArray = [[NSMutableArray alloc]init];
        for (int i = 0; i< 24; i++) {
            [fromHourArray addObject:[NSString stringWithFormat:@"%d%@",i,NSLocalizedString(@"auto_hour", @"时")]];
        }
        NSMutableArray *fromMinuteArray = [[NSMutableArray alloc]init];
        for (int j = 0; j< 60; j++) {
            [fromMinuteArray addObject:[NSString stringWithFormat:@"%d%@",j,NSLocalizedString(@"auto_minute", @"分")]];
        }
        
        NSMutableArray *connectingLine = [NSMutableArray arrayWithObject:@"-"];
        
        NSMutableArray *toHourArray = [[NSMutableArray alloc]init];
        for (int i = 0; i< 24; i++) {
            [toHourArray addObject:[NSString stringWithFormat:@"%d%@",i,NSLocalizedString(@"auto_hour", @"时")]];
        }
        NSMutableArray *toMinuteArray = [[NSMutableArray alloc]init];
        for (int j = 0; j< 60; j++) {
            [toMinuteArray addObject:[NSString stringWithFormat:@"%d%@",j,NSLocalizedString(@"auto_minute", @"分")]];
        }
        
        _pickDataArray = @[fromHourArray,fromMinuteArray,connectingLine,toHourArray,toMinuteArray];
        
    }
    return _pickDataArray;
}

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        __weak typeof(self)weakSelf = self;
        
        [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"save", @"保存")]];
        
        _bottomView.firstBlock = ^{
            
            [weakSelf cancelChoice];
            [weakSelf dismissView];
        };
        
        _bottomView.secondBlock = ^{
//MARK:保存选择选值回调
            
            if (weakSelf.saveChoiceTimePeriodBlock) {
                weakSelf.saveChoiceTimePeriodBlock(weakSelf.choiceTimePeriod);
            }

            [weakSelf dismissView];
        };
        
    }
    return _bottomView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
