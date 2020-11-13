//
//  TIoTAutoEffectTimePriodView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/13.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoEffectTimePriodView.h"
#import "UIView+XDPExtension.h"
#import "TIoTIntelligentBottomActionView.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTAutoIntellSettingCustomTimeCell.h"
#import "TIoTAutoCustomTimingView.h"
#import "TIoTAutoCustomTimePeriodView.h"

static NSString *const kAutoRepeatPeriodViewCellID = @"kAutoRepeatPeriodViewCellID";

@interface TIoTAutoEffectTimePriodView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UIView *backMaskView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *allDayButton;
@property (nonatomic, strong) UIButton *customTimePriodButton;
@property (nonatomic, strong) UIImageView *allDayIconImage;
@property (nonatomic, strong) UILabel *customTimeValueLabel; //显示生效的时间（与控制器同步）
@property (nonatomic, strong) UIImageView *customIconImage;

@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UICollectionView *collection;
@property (nonatomic, strong) NSMutableArray *timePeriodArray;

@property (nonatomic, strong) UIView *bottomBackView;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;

@property (nonatomic, assign) NSInteger timerSettedNum;//记录pick所选重复定时类型（和控制器显示的同步）
@property (nonatomic, strong) NSArray *timerSettedIDArray; //用户选择的自定义数组（星期标识数组）
@property (nonatomic, assign) NSInteger repeatTimePeriodNum;//记录选择重复时间段block返回后的index

@property (nonatomic, assign) CGFloat kHeight;
@end

@implementation TIoTAutoEffectTimePriodView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViewsUI];
    }
    return self;
}

- (void)setupSubViewsUI {
    
    CGFloat kSplitLineHeight = 1; //分割线高度
    CGFloat KItemHeight = 50; //每项高度
    CGFloat kTopViewHeight = KItemHeight * 4 + kSplitLineHeight * 3; //顶部view高度
    CGFloat kIntervalHeight = 8; //间隔高度
    CGFloat kRepeatViewHeight = 135; //重复周期选择view高度
    CGFloat kMiddleHeight = KItemHeight + kRepeatViewHeight + kSplitLineHeight; //中间view高度
    CGFloat kBottomViewHeight = 50;//底部view高度
    self.kHeight = kTopViewHeight + kMiddleHeight + kBottomViewHeight + 2*kIntervalHeight; //总高度
    
    CGFloat KPaddingLeft = 24; //icon 左边距
    CGFloat KPaddingRight = 27; //icon 右边距
    CGFloat kIconWidthHeight = 20; //选中icon
    
    
    if (@available (iOS 11.0, *)) {
        self.kHeight = self.kHeight + [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
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
    [self changeViewRectConnerWithView:self.contentView withRect:CGRectMake(0, 0, kScreenWidth, self.kHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    [self.backMaskView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.backMaskView);
        make.height.mas_equalTo(self.kHeight);
    }];
    
    //MARK:顶部视图
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(kTopViewHeight);
    }];

    //view title
    UILabel *timeTitleLabel = [[UILabel alloc]init];
    [timeTitleLabel setLabelFormateTitle:NSLocalizedString(@"auto_effective_time_period", @"生效时间段") font:[UIFont wcPfMediumFontOfSize:16] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    [self.topView addSubview:timeTitleLabel];
    [timeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self.topView);
        make.height.mas_equalTo(KItemHeight);
    }];

    UIView *splitLineOne = [[UIView alloc]init];
    splitLineOne.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.topView addSubview:splitLineOne];
    [splitLineOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeTitleLabel.mas_bottom);
        make.left.right.equalTo(self.topView);
        make.height.mas_equalTo(kSplitLineHeight);
    }];
    
    //时间段 tip
    UILabel *timePriodLabel = [[UILabel alloc]init];
    [timePriodLabel setLabelFormateTitle:NSLocalizedString(@"auto_time_priod", @"时间段") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#6C7078" textAlignment:NSTextAlignmentLeft];
    [self.topView addSubview:timePriodLabel];
    [timePriodLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(splitLineOne.mas_bottom);
        make.right.equalTo(self.topView);
        make.left.equalTo(self.topView).offset(KPaddingLeft);
        make.height.mas_equalTo(KItemHeight);
    }];

    UIView *splitLineTwo = [[UIView alloc]init];
    splitLineTwo.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.topView addSubview:splitLineTwo];
    [splitLineTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timePriodLabel.mas_bottom);
        make.left.right.equalTo(self.topView);
        make.height.mas_equalTo(kSplitLineHeight);
    }];

    //全天
    self.allDayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.allDayButton setBackgroundColor:[UIColor whiteColor]];
    [self.allDayButton addTarget:self action:@selector(selectedTimePeriod:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.allDayButton];
    [self.allDayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.topView);
        make.top.equalTo(splitLineTwo.mas_bottom);
        make.height.mas_equalTo(KItemHeight);
    }];
    
    UILabel *allDayTipLabel = [[UILabel alloc]init];
    [allDayTipLabel setLabelFormateTitle:NSLocalizedString(@"auto_allDay", @"全天（24小时）") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.allDayButton addSubview:allDayTipLabel];
    [allDayTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.allDayButton.mas_left).offset(KPaddingLeft);
        make.centerY.equalTo(self.allDayButton.mas_centerY);
        make.height.equalTo(self.allDayButton);
    }];

    self.allDayIconImage = [[UIImageView alloc]init];
    self.allDayIconImage.image =[UIImage imageNamed:@"procolSelect"];
    [self.allDayButton addSubview:self.allDayIconImage];
    [self.allDayIconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.allDayButton.mas_right).offset(-KPaddingRight);
        make.centerY.equalTo(self.allDayButton);
        make.height.width.mas_equalTo(kIconWidthHeight);
    }];

    UIView *splitLineThree = [[UIView alloc]init];
    splitLineThree.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.topView addSubview:splitLineThree];
    [splitLineThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.allDayButton.mas_bottom);
        make.left.right.equalTo(self.topView);
        make.height.mas_equalTo(kSplitLineHeight);
    }];

    //自定义
    self.customTimePriodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.customTimePriodButton setBackgroundColor:[UIColor whiteColor]];
    [self.customTimePriodButton addTarget:self action:@selector(selectedTimePeriod:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.customTimePriodButton];
    [self.customTimePriodButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(splitLineThree.mas_bottom);
        make.left.right.equalTo(self.topView);
        make.height.mas_equalTo(KItemHeight);
    }];
    
    UILabel *customTipLabel = [[UILabel alloc]init];
    [customTipLabel setLabelFormateTitle:NSLocalizedString(@"auto_repeatTiming_custom", @"自定义") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.customTimePriodButton addSubview:customTipLabel];
    [customTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customTimePriodButton.mas_left).offset(KPaddingLeft);
        make.centerY.equalTo(self.customTimePriodButton.mas_centerY);
        make.height.equalTo(self.allDayButton);
    }];
    
    self.customTimeValueLabel = [[UILabel alloc]init];
    [self.customTimeValueLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.customTimePriodButton addSubview:self.customTimeValueLabel];
    [self.customTimeValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(customTipLabel.mas_right);
        make.centerY.equalTo(self.customTimePriodButton.mas_centerY);
        make.height.equalTo(self.allDayButton);
    }];
    
    self.customIconImage = [[UIImageView alloc]init];
    self.customIconImage.image =[UIImage imageNamed:@"procolDefault"];
    [self.customTimePriodButton addSubview:self.customIconImage];
    [self.customIconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.customTimePriodButton.mas_right).offset(-KPaddingRight);
        make.centerY.equalTo(self.customTimePriodButton.mas_centerY);
        make.height.width.mas_equalTo(kIconWidthHeight);
    }];
    
    //MARK:中间视图
    self.middleView = [[UIView alloc]init];
    self.middleView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.middleView];
    [self.middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom).offset(kIntervalHeight);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(kMiddleHeight);
    }];
    
    //重复周期tip
    UILabel *repeatTipLabel = [[UILabel alloc]init];
    [repeatTipLabel setLabelFormateTitle:NSLocalizedString(@"auto_repeat_cycle", @"重复周期") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#6C7078" textAlignment:NSTextAlignmentLeft];
    [self.middleView addSubview:repeatTipLabel];
    [repeatTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.middleView.mas_left).offset(KPaddingLeft);
        make.right.equalTo(self.middleView);
        make.height.mas_equalTo(KItemHeight);
    }];
    
    UIView *splitLineFour = [[UIView alloc]init];
    splitLineFour.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.middleView addSubview:splitLineFour];
    [splitLineFour mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(repeatTipLabel.mas_bottom);
        make.left.right.equalTo(self.middleView);
        make.height.mas_equalTo(kSplitLineHeight);
    }];
    
    [self.middleView addSubview:self.collection];
    self.collection.backgroundColor = [UIColor whiteColor];
    [self.collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.middleView);
        make.top.equalTo(splitLineFour.mas_bottom);
        make.height.mas_equalTo(kRepeatViewHeight);
    }];

    //MARK:底部视图
    self.bottomBackView = [[UIView alloc]init];
    self.bottomBackView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.bottomBackView];
    [self.bottomBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.middleView.mas_bottom).offset(kIntervalHeight);
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
    
    self.defaultRepeatTimeNum = 0;
}

- (void)drawRect:(CGRect)rect {
    
    [self didselectedCollection:self.collection indexPath:[NSIndexPath indexPathForItem:self.defaultRepeatTimeNum inSection:0]];
}


#pragma mark - event

- (void)setEffectTimeDic:(NSMutableDictionary *)effectTimeDic {
    _effectTimeDic = effectTimeDic;
    NSString *customTime = @"";
    if (effectTimeDic == nil) {
        self.effectTimeDic = [NSMutableDictionary dictionaryWithDictionary:@{@"time":@"00:00-23:59",@"repeatType":@""}];
        return;
    }else {
        customTime = effectTimeDic[@"time"]?:@"";
        self.customTimeValueLabel.text = [NSString stringWithFormat:@"（%@）",customTime];
    }
}

- (void)selectedTimePeriod:(UIButton *)button {
    if (button == self.allDayButton) {
        self.allDayIconImage.image =[UIImage imageNamed:@"procolSelect"];
        self.customIconImage.image =[UIImage imageNamed:@"procolDefault"];
    }else if (button == self.customTimePriodButton) {
        self.allDayIconImage.image =[UIImage imageNamed:@"procolDefault"];
        self.customIconImage.image =[UIImage imageNamed:@"procolSelect"];
        
        
        CGFloat kTopViewHeight = 50;
        CGFloat kPickViewHeight = 272;
        CGFloat kBottomViewHeight = 50;//底部view高度
        CGFloat KIntervalHeight = 8;
        CGFloat kHeight = kTopViewHeight + kPickViewHeight + kBottomViewHeight + KIntervalHeight;
        if (@available (iOS 11.0, *)) {
            kHeight = kHeight + [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
        }
        
        __weak typeof(self)WeakSelf = self;
        
        //MARK: 自定义时间段 选择
        TIoTAutoCustomTimePeriodView *choiceTimePeriodView = [[TIoTAutoCustomTimePeriodView alloc]init];
        NSMutableString * customTime = [[NSMutableString alloc]initWithString:self.customTimeValueLabel.text];
        //删除第一个 最后一个字符船夫
        if (![NSString isNullOrNilWithObject:customTime]) {
            
            if ([customTime containsString:@"（"]) {
                [customTime deleteCharactersInRange:NSMakeRange(0, 1)];
            }
            
            if ([customTime containsString:@"）"]) {
                [customTime deleteCharactersInRange:NSMakeRange(customTime.length-1, 1)];
            }
        }else {
            customTime = [NSMutableString stringWithString:@""];
        }
        
        choiceTimePeriodView.previousSelectedTime = [customTime copy];
        
        //取消
        choiceTimePeriodView.cancelChoiceTimePeriodBlock = ^{
            [WeakSelf.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(WeakSelf.kHeight);
            }];
            
            if ([WeakSelf.customTimeValueLabel.text isEqualToString:@"00:00-23:59"]) {
                WeakSelf.customTimeValueLabel.text = @"";
            }
            if (![NSString isNullOrNilWithObject:WeakSelf.customTimeValueLabel.text]) {
                WeakSelf.allDayIconImage.image =[UIImage imageNamed:@"procolDefault"];
                WeakSelf.customIconImage.image =[UIImage imageNamed:@"procolSelect"];
            }else {
                WeakSelf.allDayIconImage.image =[UIImage imageNamed:@"procolSelect"];
                WeakSelf.customIconImage.image =[UIImage imageNamed:@"procolDefault"];
            }
            
        };
        //保存
        choiceTimePeriodView.saveChoiceTimePeriodBlock = ^(NSString * _Nonnull timeString) {
            
            [WeakSelf.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(WeakSelf.kHeight);
            }];
            
            if ([timeString isEqualToString:@"00:00-23:59"]) {
                WeakSelf.customTimeValueLabel.text = @"";
                WeakSelf.allDayIconImage.image =[UIImage imageNamed:@"procolSelect"];
                WeakSelf.customIconImage.image =[UIImage imageNamed:@"procolDefault"];
            }else {
                WeakSelf.allDayIconImage.image =[UIImage imageNamed:@"procolDefault"];
                WeakSelf.customIconImage.image =[UIImage imageNamed:@"procolSelect"];
                NSString *timeTempStr = timeString?:@"";
                WeakSelf.customTimeValueLabel.text = [NSString stringWithFormat:@"（%@）",timeTempStr];
            }
        };
        
        [self.contentView addSubview:choiceTimePeriodView];
        [choiceTimePeriodView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(kHeight);
        }];
        
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kHeight);
        }];
        
    }
}

//MARK: 点击获取
- (void)didselectedCollection:(UICollectionView *)collection indexPath:(NSIndexPath *)indexPach {
    [collection selectItemAtIndexPath:indexPach animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    if ([collection.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [collection.delegate collectionView:collection didSelectItemAtIndexPath:indexPach];
    }
}

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.timePeriodArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAutoIntellSettingCustomTimeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAutoRepeatPeriodViewCellID forIndexPath:indexPath];
    cell.itemString = self.timePeriodArray[indexPath.row];
    cell.autoRepeatTimeType = AutoRepeatTimeTypeTimePeriod;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAutoIntellSettingCustomTimeCell *cell = (TIoTAutoIntellSettingCustomTimeCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = YES;
    if (indexPath.row != self.timePeriodArray.count - 1) {
        self.timerSettedNum = indexPath.row + 1;
    }else if (indexPath.row == self.timePeriodArray.count - 1) {
        
            CGFloat kBottomViewHeight = 50;//底部view高度
            CGFloat kPickViewHeight = 260;//collection高度
            CGFloat kRepeatViewHeight = kPickViewHeight + kBottomViewHeight;  //自定义周期view高度
            if (@available (iOS 11.0, *)) {
                kRepeatViewHeight = kRepeatViewHeight +[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
            }
            
            __weak typeof(self)weakSelf = self;
            self.defaultRepeatTimeNum = self.timerSettedNum;
            TIoTAutoCustomTimingView *customTimeView = [[TIoTAutoCustomTimingView alloc]init];
            customTimeView.defaultTimeNum = self.defaultRepeatTimeNum;
            customTimeView.autoRepeatType = AutoRepeatTypeEffectTimePeriod;
            
            customTimeView.autoKeepRecordSelectedBefore = ^(NSInteger defaultTimeNum) {
                [weakSelf didselectedCollection:weakSelf.collection indexPath:[NSIndexPath indexPathForItem:defaultTimeNum inSection:0]];
                
                weakSelf.hidden = NO;
            };
            
            customTimeView.saveCustomTimerBlock = ^(NSArray * _Nonnull dateArray, NSArray * _Nonnull originWeekArray) {
                NSLog(@"----%@",dateArray);

                [weakSelf.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_offset(self.kHeight);
                }];
                
                //MARK: 选择自定义时间段后，返回刷新当前view数据
                        NSInteger indexNum = 3;
                        NSMutableString *dateString = [[NSMutableString alloc]init];
                        NSMutableString *repeatContentString = [[NSMutableString alloc]init];

                        for (int i = 0;i < dateArray.count; i++) {
                            [dateString appendString:dateArray[i]];
                        }

                        if ([dateString isEqualToString:@"1000001"]) {
                            indexNum = 2; //周末
                            weakSelf.repeatTimePeriodNum = indexNum;
                            weakSelf.timerSettedNum = indexNum;
                            [weakSelf didselectedCollection:weakSelf.collection indexPath:[NSIndexPath indexPathForItem:indexNum inSection:0]];
                            
                        }else if ([dateString isEqualToString:@"1111111"]) {
                            indexNum = 0;//每天
                            weakSelf.repeatTimePeriodNum = indexNum;
                            weakSelf.timerSettedNum = indexNum;
                            [weakSelf didselectedCollection:weakSelf.collection indexPath:[NSIndexPath indexPathForItem:indexNum inSection:0]];

                            
                        }else if ([dateString isEqualToString:@"0111110"]) {
                            indexNum = 1;//工作日
                            weakSelf.repeatTimePeriodNum = indexNum;
                            weakSelf.timerSettedNum = indexNum;
                            [weakSelf didselectedCollection:weakSelf.collection indexPath:[NSIndexPath indexPathForItem:indexNum inSection:0]];
                            
                            
                        }else {
                            //自定义
                            if (weakSelf.defaultRepeatTimeNum != weakSelf.repeatTimePeriodNum) {
                                
                            }else {
                                indexNum = 3;
                                weakSelf.repeatTimePeriodNum = indexNum;
                                weakSelf.timerSettedNum = indexNum;
                                [weakSelf didselectedCollection:weakSelf.collection indexPath:[NSIndexPath indexPathForItem:indexNum inSection:0]];
                            }

                        }

    //                    [weakSelf dismissView];
            };
        
            customTimeView.selectedRepeatIndexNumber = weakSelf.timerSettedNum;
    //        customTimeView.dateIDArray = weakSelf.timerSettedIDArray;
            [weakSelf.contentView addSubview:customTimeView];
            [customTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(weakSelf.contentView);
                make.height.mas_equalTo(kRepeatViewHeight);
            }];
        
        [weakSelf.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(kRepeatViewHeight);
        }];
        
        
    }
    
}

#pragma mark - lazy loading

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
            if (weakSelf.generateTimePeriodBlock) {
                [weakSelf.effectTimeDic setValue:weakSelf.customTimeValueLabel.text forKey:@"time"];
                
                weakSelf.generateTimePeriodBlock(weakSelf.effectTimeDic);
            }
            [weakSelf dismissView];
        };
        
    }
    return _bottomView;
}

- (UICollectionView *)collection {
    if (!_collection) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat itemWidth = 100*kScreenAllWidthScale;
        CGFloat itemHeight = 40*kScreenAllHeightScale;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(16, 24, 16, 24);
        flowLayout.minimumLineSpacing = 10;
//        flowLayout.minimumInteritemSpacing = 0;
        _collection = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collection.backgroundColor = [UIColor whiteColor];
        _collection.delegate = self;
        _collection.dataSource = self;
        _collection.scrollEnabled = NO;
        [_collection registerClass:[TIoTAutoIntellSettingCustomTimeCell class] forCellWithReuseIdentifier:kAutoRepeatPeriodViewCellID];
    }
    return _collection;
}

- (NSMutableArray *)timePeriodArray {
    if (!_timePeriodArray) {
        _timePeriodArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"everyday", @"每天"),
                                                            NSLocalizedString(@"work_day", @"工作日"),
                                                            NSLocalizedString(@"weekend", @"周末"),
                                                            NSLocalizedString(@"auto_repeatTiming_custom", @"自定义")]];
    }
    return _timePeriodArray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
