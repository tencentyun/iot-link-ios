//
//  TIoTAutoCustomTimingView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoCustomTimingView.h"
#import "UIView+XDPExtension.h"
#import "TIoTIntelligentBottomActionView.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTAutoIntellSettingCustomTimeCell.h"

static NSString *const kAutoCollectionViewCellID = @"kAutoCollectionViewCellID";

@interface TIoTAutoCustomTimingView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UIView *contentView;    //灰色底
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomBackView; //底部自定义view父view （白色底）

@property (nonatomic, strong) UICollectionView *collection;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;
@property (nonatomic, strong) NSMutableArray *customTimeDataArray; //原始数据
@property (nonatomic, strong) NSMutableArray *selectedTimeDataArray; //用户选择后的数据
@end

@implementation TIoTAutoCustomTimingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViewUI];
    }
    return self;
}

- (void)setupViewUI {
    
    CGFloat kTopViewHeight = 50; //顶部高度
    CGFloat kCollectionHeight = 200;//collection高度
    CGFloat kIntervalHeight = 10; //底部view距离cellectionview间距
    CGFloat kBottomViewHeight = 56;//底部view高度
    CGFloat kHeight = kCollectionHeight + kBottomViewHeight;  //总高度
    if (@available (iOS 11.0, *)) {
        kHeight = kHeight +[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
    [self addSubview:self.contentView];
    self.contentView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    [self.contentView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
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
    
    [self.contentView addSubview:self.collection];
    [self.collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(slideLine.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(kCollectionHeight);
    }];
    
    self.bottomBackView = [[UIView alloc]init];
    self.bottomBackView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.bottomBackView];
    [self.bottomBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.top.equalTo(self.collection.mas_bottom).offset(kIntervalHeight);
        
    }];
    
    [self.bottomBackView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bottomBackView);
        make.top.equalTo(self.bottomBackView.mas_top);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
}
#pragma mark - event

/**
 返回重复选择定时自定义view
 */
- (void)goBackForward {
    
    if (self.autoKeepRecordSelectedBefore) {
        if (self.autoRepeatType == AutoRepeatTypeEffectTimePeriod) {
            self.defaultTimeNum = self.defaultTimeNum -1;
        }
        self.autoKeepRecordSelectedBefore(self.defaultTimeNum);
    }
    
    [self removeFromSuperview];
}

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.customTimeDataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAutoIntellSettingCustomTimeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAutoCollectionViewCellID forIndexPath:indexPath];
    cell.itemString = self.customTimeDataArray[indexPath.row];
    cell.autoRepeatTimeType = AutoRepeatTimeTypeTimerCustom;
    cell.isSelected = NO;
    
    switch (self.selectedRepeatIndexNumber) {
        case AutoInteSelectedRepeatTypeOnce: { //一次
            break;
        }
        case AutoInteSelectedRepeatTypeEveryday: { //每天
            cell.isSelected = YES;
            [self.selectedTimeDataArray replaceObjectAtIndex:indexPath.row withObject:@"1"];
            break;
        }
        case AutoInteSelectedRepeatTypeWorkday: { //工作日
            if (!(indexPath.row == 0 || indexPath.row == 6)) {
                cell.isSelected = YES;
                [self.selectedTimeDataArray replaceObjectAtIndex:indexPath.row withObject:@"1"];
            }
            break;
        }
        case AutoInteSelectedRepeatTypeWeekend: { //周末
            if (indexPath.row == 0 || indexPath.row == 6) {
                [self.selectedTimeDataArray replaceObjectAtIndex:indexPath.row withObject:@"1"];
                cell.isSelected = YES;
            }
            break;
        }
        case AutoInteSelectedRepeatTypeCustom: { //自定义
            if (self.dateIDArray) {
                if ([self.dateIDArray[indexPath.row] isEqualToString:@"1"]) {
                    cell.isSelected = YES;
                    [self.selectedTimeDataArray replaceObjectAtIndex:indexPath.row withObject:@"1"];
                }else {
                    cell.isSelected = NO;
                }
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TIoTAutoIntellSettingCustomTimeCell *cell = (TIoTAutoIntellSettingCustomTimeCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isSelected == YES) {
        cell.isSelected = NO;
        [self.selectedTimeDataArray replaceObjectAtIndex:indexPath.row withObject:@"0"];
    }else {
        cell.isSelected = YES;
        [self.selectedTimeDataArray replaceObjectAtIndex:indexPath.row withObject:@"1"];
    }
}

#pragma mark - lazy laoding

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        __weak typeof(self)weakSelf = self;
        
        [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"save", @"保存")]];
        
        _bottomView.firstBlock = ^{
            if (weakSelf.autoKeepRecordSelectedBefore) {
                if (self.autoRepeatType == AutoRepeatTypeEffectTimePeriod) {
                    weakSelf.defaultTimeNum = weakSelf.defaultTimeNum -1;
                }
                weakSelf.autoKeepRecordSelectedBefore(weakSelf.defaultTimeNum);
            }
            [weakSelf dismissView];
        };
        
        _bottomView.secondBlock = ^{
//MARK:保存选择选值回调
            BOOL isEmtpyItem = [weakSelf.selectedTimeDataArray containsObject:@"1"];
            
            if (!isEmtpyItem) {
                [MBProgressHUD showMessage:NSLocalizedString(@"auto_atLeast_oneday", @"请至少选择一天") icon:@""];
            }else {
                if (weakSelf.saveCustomTimerBlock) {
                    weakSelf.saveCustomTimerBlock([weakSelf.selectedTimeDataArray copy], [weakSelf.customTimeDataArray copy]);
                }
                [weakSelf dismissView];
                
            }
            
             
        };
        
    }
    return _bottomView;
}

- (NSMutableArray *)customTimeDataArray {
    if (!_customTimeDataArray) {
        _customTimeDataArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"sunday", @"周日"),
                                                          NSLocalizedString(@"monday", @"周一"),
                                                          NSLocalizedString(@"tuesday", @"周二"),
                                                          NSLocalizedString(@"wednesday", @"周三"),
                                                          NSLocalizedString(@"thursday", @"周四"),
                                                          NSLocalizedString(@"friday", @"周五"),
                                                          NSLocalizedString(@"saturday", @"周六")]];
    }
    return _customTimeDataArray;
}


- (void)setDateIDArray:(NSArray *)dateIDArray {
    if (dateIDArray == nil) {
        return;
    }
    _dateIDArray = dateIDArray;
    
}

- (NSMutableArray *)selectedTimeDataArray {
    if (!_selectedTimeDataArray) {
        _selectedTimeDataArray = [NSMutableArray array];
        for (int i = 0; i <self.customTimeDataArray.count; i++) {
            [_selectedTimeDataArray addObject:@"0"];
        }
        
    }
    return _selectedTimeDataArray;
}

- (UICollectionView *)collection {
    if (!_collection) {
        
//        CGFloat kPadding = 24; //左右边距
//        CGFloat kIntervalSpace = 12;//每行item间距
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat itemWidth = 100*kScreenAllWidthScale;
        CGFloat itemHeight = 40*kScreenAllHeightScale;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 24, 6, 24);
//        flowLayout.minimumLineSpacing = 0;
//        flowLayout.minimumInteritemSpacing = 0;
        _collection = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collection.backgroundColor = [UIColor whiteColor];
        _collection.delegate = self;
        _collection.dataSource = self;
        _collection.scrollEnabled = NO;
        [_collection registerClass:[TIoTAutoIntellSettingCustomTimeCell class] forCellWithReuseIdentifier:kAutoCollectionViewCellID];
    }
    return _collection;
}

@end
