//
//  TIoTAutoSettingRepeatTimingView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoSettingRepeatTimingView.h"
#import "UIView+XDPExtension.h"
#import "TIoTIntelligentBottomActionView.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTAutoCustomTimingView.h"

@interface TIoTAutoSettingRepeatTimingView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIView    *backMaskView;
@property (nonatomic, strong) UIView *backContentView;
@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, strong) NSMutableArray *pickDataArray;
@property (nonatomic, strong) NSString *repeatingTypeString;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;
@property (nonatomic, assign) NSInteger selectedPickCurrentNum;  //选择pick数据 row
@property (nonatomic, assign) NSInteger timerSettedNum; //记录pick所选重复定时类型（和控制器显示的同步）
@property (nonatomic, strong) NSArray *timerSettedIDArray; //用户选择的自定义数组（星期标识数组）
@end

@implementation TIoTAutoSettingRepeatTimingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUISubViews];
    }
    return self;
}

- (void)setupUISubViews {
     
    
    CGFloat kBottomViewHeight = 56;//底部view高度
    CGFloat kPickViewHeight = 260;//pickview高度
    CGFloat kHeight = kPickViewHeight + kBottomViewHeight;  //总高度
    if (@available (iOS 11.0, *)) {
        kHeight = kHeight +[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
    self.backMaskView = [[UIView alloc]init];
    self.backMaskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [self addSubview:self.backMaskView];
    [self.backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.right.bottom.equalTo(self);
    }];
    
    self.backContentView = [[UIView alloc]init];
    self.backContentView.backgroundColor = [UIColor whiteColor];
    [self changeViewRectConnerWithView:self.backContentView withRect:CGRectMake(0, 0, kScreenWidth, kHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    [self.backMaskView addSubview:self.backContentView];
    [self.backContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.backMaskView);
        make.height.mas_equalTo(kHeight);
    }];
    
    
    [self.backContentView addSubview:self.pickView];
    [self.pickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.backContentView);
        make.height.mas_equalTo(kPickViewHeight);
    }];
    
    [self.backContentView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backContentView);
        make.top.equalTo(self.pickView.mas_bottom);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.backMaskView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.backMaskView);
        make.bottom.equalTo(self.backContentView.mas_top);
    }];
    
}

- (void)drawRect:(CGRect)rect {
    [self.pickView selectRow:self.defaultRepeatTimeNum inComponent:0 animated:NO];
    self.timerSettedNum = self.defaultRepeatTimeNum;
    self.selectedPickCurrentNum = self.defaultRepeatTimeNum;
    self.repeatingTypeString = self.pickDataArray[self.defaultRepeatTimeNum];
    if (self.defaultRepeatTimeNum == 4) { //自定义 控制器中重复定时值是 用户选的非常规
        if (![NSString isNullOrNilWithObject:self.dateContentString]) {
            NSMutableArray *tempArray = [NSMutableArray array];
            for (int i= 0; i<self.dateContentString.length; i++) {
                [tempArray addObject:[self.dateContentString substringWithRange:NSMakeRange(i, 1)]];
            }
            
            self.timerSettedIDArray = [tempArray copy];
        }
    }
    
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickDataArray.count;
}

#pragma mark - UIPickerViewDelegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickDataArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.repeatingTypeString = self.pickDataArray[row];
    self.selectedPickCurrentNum = row;
    
}

//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
//    return 48;
//}
//
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
//    UILabel *pickLabel = (UILabel *)view;
//    if (!pickLabel) {
//        pickLabel = [[UILabel alloc]init];
//        pickLabel.adjustsFontSizeToFitWidth = YES;
//        [pickLabel setLabelFormateTitle:self.pickDataArray[row] font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
//    }
//    return pickLabel;
//}


#pragma mark - event

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
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

- (NSMutableArray *)pickDataArray {
    if (!_pickDataArray) {
        NSArray *repeatType = @[NSLocalizedString(@"auto_repeatTiming_once", @"执行一次"),
                                NSLocalizedString(@"everyday", @"每天"),
                                NSLocalizedString(@"work_day", @"工作日"),
                                NSLocalizedString(@"weekend", @"周末"),
                                NSLocalizedString(@"auto_repeatTiming_custom", @"自定义")];
        _pickDataArray = [NSMutableArray arrayWithArray:repeatType];
    }
    return _pickDataArray;
}

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        __weak typeof(self)weakSelf = self;
        
        [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"save", @"保存")]];
        
        _bottomView.firstBlock = ^{
            
            [weakSelf dismissView];
        };
        
        _bottomView.secondBlock = ^{
//MARK:保存选择选值回调
            
            if (weakSelf.selectedPickCurrentNum == weakSelf.pickDataArray.count - 1) {
                TIoTAutoCustomTimingView *customTimeView = [[TIoTAutoCustomTimingView alloc]init];
                customTimeView.defaultTimeNum = weakSelf.defaultRepeatTimeNum;
                customTimeView.autoRepeatType = AutoRepeatTypeTimer;
                //不保存自定义重复选项返回，显示选择自定义之前的pick index
                customTimeView.autoKeepRecordSelectedBefore = ^(NSInteger defaultTimeNum) {
                    [weakSelf.pickView selectRow:defaultTimeNum inComponent:0 animated:NO];
                };
                
                customTimeView.saveCustomTimerBlock = ^(NSArray * _Nonnull dateArray, NSArray * _Nonnull originWeekArray) {
                    NSLog(@"----%@",dateArray);
                    
                    NSInteger indexNum = 4;
                    NSMutableString *dateString = [[NSMutableString alloc]init];
                    NSMutableString *repeatContentString = [[NSMutableString alloc]init];
                    
                    for (int i = 0;i < dateArray.count; i++) {
                        [dateString appendString:dateArray[i]];
                    }
                    
                    if ([dateString isEqualToString:@"1000001"]) {
                        indexNum = 3; //周末
                        if (weakSelf.settingRepeatTimingBlcok) {
                            weakSelf.timerSettedNum = indexNum;
                            weakSelf.settingRepeatTimingBlcok(weakSelf.pickDataArray[indexNum], indexNum, dateString);
                        }
                    }else if ([dateString isEqualToString:@"1111111"]) {
                        indexNum = 1;//每天
                        if (weakSelf.settingRepeatTimingBlcok) {
                            weakSelf.timerSettedNum = indexNum;
                            weakSelf.settingRepeatTimingBlcok(weakSelf.pickDataArray[indexNum], indexNum, dateString);
                        }
                    }else if ([dateString isEqualToString:@"0111110"]) {
                        indexNum = 2;//工作日
                        if (weakSelf.settingRepeatTimingBlcok) {
                            weakSelf.timerSettedNum = indexNum;
                            weakSelf.settingRepeatTimingBlcok(weakSelf.pickDataArray[indexNum], indexNum, dateString);
                        }
                    }else {
                        if (weakSelf.settingRepeatTimingBlcok) {
                            weakSelf.timerSettedNum = indexNum;
                            
                            for (int j = 0; j<dateArray.count; j++) {
                                if ([dateArray[j] isEqualToString:@"1"]) {
                                    [repeatContentString appendString:originWeekArray[j]];
                                }
                            }
                            
                            weakSelf.settingRepeatTimingBlcok(repeatContentString, indexNum, dateString);
                        }
                    }
    

                    [weakSelf dismissView];
                };
                customTimeView.selectedRepeatIndexNumber = weakSelf.timerSettedNum;
                customTimeView.dateIDArray = weakSelf.timerSettedIDArray;
                [weakSelf.backContentView addSubview:customTimeView];
                [customTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.top.bottom.equalTo(weakSelf.backContentView);
                }];
                
            }else {
                if (weakSelf.settingRepeatTimingBlcok) {
                    weakSelf.timerSettedNum = weakSelf.selectedPickCurrentNum;
                    NSString *dateIDTempString = @"0000000";
                    if (weakSelf.selectedPickCurrentNum == 0) { //一次
                        
                    }else if (weakSelf.selectedPickCurrentNum == 1) {//每天
                        dateIDTempString = @"1111111";
                    }else if (weakSelf.selectedPickCurrentNum == 2) {//工作日
                        dateIDTempString = @"0111110";
                    }else if ( weakSelf.selectedPickCurrentNum == 3) {//周末
                        dateIDTempString = @"1000001";
                    }else if (weakSelf.selectedPickCurrentNum == 4) {//自定义
                        
                    }
                    weakSelf.settingRepeatTimingBlcok(weakSelf.repeatingTypeString, weakSelf.selectedPickCurrentNum, dateIDTempString);
                }
                [weakSelf dismissView];
            }

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
