//
//  TIoTDemoCustomChoiceDateView.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/3.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoCustomChoiceDateView.h"
#import "NSDate+TIoTCustomCalendar.h"
#import "NSString+Extension.h"

static CGFloat const kDateViewHeight = 44;
static CGFloat const kDateScrollHeight = 72; //scrollview高度
static CGFloat const kWidthMargin = 16; //左右边距
static CGFloat const kButtonSize = 28; //按钮宽搞
static CGFloat const kItemWith = 60; //每小时长度
static CGFloat const kMinItemWidth = (60 - 5)/6;
static CGFloat const kTipLabelWidth = 38;
static CGFloat const kTopPadding = 4; //长刻度距离scrollview 高度
static CGFloat const kMinTopPadding = 10; //段刻度距离scrollview 高度
static CGFloat const kMinLineHeight = 20;
static CGFloat const kIntervalSapce = 4;
static NSInteger secondsNumber = 86400;  //24*60*60

@implementation TIoTTimeModel

@end

@interface TIoTDemoCustomChoiceDateView ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIView *topDateView;
@property (nonatomic, strong) UIButton *dateButton;
@property (nonatomic, strong) UIScrollView *dateScrollView;
@property (nonatomic, assign) CGFloat kScrollViewWidth;
@property (nonatomic, strong) UIView *midLine;
@property (nonatomic, strong) NSString *defaultDateString;
@property (nonatomic, assign) NSInteger currentTime;
@property (nonatomic, strong) NSMutableArray *dateAllSegmentArrray;

@property (nonatomic, assign) NSInteger minDistanceValue;
@property (nonatomic, assign) NSInteger tempDisValue;
@end

@implementation TIoTDemoCustomChoiceDateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTopDateChoiceViews];
        [self setupScrollSubViews];
        [self setupAroundView];
    }
    return self;
    
}

- (void)setupScrollSubViews {
    
    //刻度scrollview
    self.dateScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(kWidthMargin+kButtonSize, CGRectGetMaxY(self.topDateView.frame), self.kScrollViewWidth, kDateScrollHeight)];
    self.dateScrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.dateScrollView];
    self.dateScrollView.delegate = self;
    self.dateScrollView.showsHorizontalScrollIndicator = NO;
    self.dateScrollView.contentSize = CGSizeMake(kItemWith*24 + self.kScrollViewWidth, 50);
    
    for (int i = 0; i < 25; i++) {
        //小时刻度
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(i*kItemWith + self.kScrollViewWidth/2, kTopPadding, 1, 32)];
        lineView.backgroundColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
        [self.dateScrollView addSubview:lineView];
        
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame) - kTipLabelWidth/2, CGRectGetMaxY(lineView.frame)+8, kTipLabelWidth, 18)];
        [timeLabel setLabelFormateTitle:[NSString stringWithFormat:@"%d:00",i] font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kVideoDemoTextContentColor textAlignment:NSTextAlignmentCenter];
        if (i<10) {
            timeLabel.text = [NSString stringWithFormat:@"0%d:00",i];
        }
        [self.dateScrollView addSubview:timeLabel];
        
        if (i < 24) {
            //每小时内6等分刻度线
            for (int j = 1; j <= 5; j++) {
                UIView *minLine = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame)+j*(kMinItemWidth + 1), kMinTopPadding, 1, kMinLineHeight)];
                minLine.backgroundColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
                [self.dateScrollView addSubview:minLine];
            }
        }
    }

}

- (void)setupTopDateChoiceViews {
    self.backgroundColor = [UIColor whiteColor];
    
    //顶部选择时间底层View
    self.topDateView = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, kDateViewHeight)];
    self.topDateView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.topDateView];
    
    CGFloat kDaateButtonWidth = kDateViewHeight + kDateScrollHeight;
    
    //默认当前日期
    NSDate *date = [NSDate date];
    NSInteger year = [date dateYear];
    NSInteger month = [date dateMonth];
    NSInteger day = [date dateDay];
    self.defaultDateString = [NSString stringWithFormat:@"%02ld-%02ld-%02ld",(long)year,(long)month,(long)day];
    
    self.dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dateButton.frame = CGRectMake(kScreenWidth/2-kDaateButtonWidth/2, 10, kDaateButtonWidth, 24);
    [self.dateButton setButtonFormateWithTitlt:self.defaultDateString titleColorHexString:kVideoDemoDateTipTextColor font:[UIFont wcPfRegularFontOfSize:17]];
    [self.dateButton setImage:[UIImage imageNamed:@"choiceDate_tip"] forState:UIControlStateNormal];
    [self.dateButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.dateButton.imageView.frame.size.width-kIntervalSapce, 0, self.dateButton.imageView.frame.size.width+kIntervalSapce)];
    [self.dateButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.dateButton.titleLabel.bounds.size.width+kIntervalSapce, 0, -self.dateButton.titleLabel.bounds.size.width - kIntervalSapce)];
    [self.dateButton addTarget:self action:@selector(chooseDate:) forControlEvents:UIControlEventTouchUpInside];
    [self.topDateView addSubview:self.dateButton];
    
    self.kScrollViewWidth = kScreenWidth-2*kWidthMargin-2*kButtonSize; //scrollView 长度
}

- (void)setupAroundView {
    //中间刻度标记
    self.midLine = [[UIView alloc]init];
    self.midLine.backgroundColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    [self addSubview:self.midLine];
    [self.midLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(2);
        make.height.mas_equalTo(40);
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.topDateView.mas_bottom);
    }];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"left_date"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(choosePreviousDate) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kWidthMargin);
        make.width.height.mas_equalTo(kButtonSize);
        make.top.equalTo(self.topDateView.mas_bottom).offset(kIntervalSapce);
    }];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"right_date"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(chooseNextDate) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightButton];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kButtonSize);
        make.top.equalTo(self.topDateView.mas_bottom).offset(kIntervalSapce);
        make.right.equalTo(self.mas_right).offset(-kWidthMargin);
    }];
}

- (void)chooseDate:(UIButton *)button {
    if (self.chooseDateBlock) {
        self.chooseDateBlock(button);
    }
}

- (void)choosePreviousDate {
    if (self.previousDateBlcok) {
        TIoTTimeModel *model = [self filterLatestTimeModelWithAction:YES];
        self.nextDateBlcok(model);
    }
}

- (void)chooseNextDate {
    if (self.nextDateBlcok) {
        TIoTTimeModel *model = [self filterLatestTimeModelWithAction:NO];
        self.nextDateBlcok(model);
    }
}

/// MARK: 选择距离当前值最近的model
- (TIoTTimeModel *)filterLatestTimeModelWithAction:(BOOL)isLeft {
    __weak typeof(self) weakSelf = self;
    self.minDistanceValue = 0;
    __block NSInteger modelIdx = 0;
    __block CGFloat scrollOffsetX = 0;
    __block TIoTTimeModel *scrollModel = [TIoTTimeModel new];
    self.tempDisValue = 0;
    
    if (self.videoTimeSegmentArray.count != 0) {
        [self.videoTimeSegmentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TIoTTimeModel *model = obj;
            
            if (isLeft == YES) {

                    if (weakSelf.currentTime >= model.endTime) {
                        
                        if (self.minDistanceValue <= self.tempDisValue) {
                            self.tempDisValue = self.minDistanceValue;
                            modelIdx = idx;
                            NSLog(@"--!!!!-%ld~~~~~%ld",(long)self.tempDisValue,self.minDistanceValue);
                        }else {
                            
                            self.tempDisValue = self.minDistanceValue;
                            modelIdx = idx;
                        }
                        self.minDistanceValue = fabs(weakSelf.currentTime - model.endTime);

                    }else {
                        if (idx == 0) {
                            scrollModel = nil;
                            modelIdx = -1;
                            *stop = YES;
                        }

                    }

            }else {

                if (weakSelf.currentTime <= model.startTime) {
                    if (self.minDistanceValue <= self.tempDisValue) {
                        self.tempDisValue = self.minDistanceValue;
                        modelIdx = idx;
                    }
                    self.minDistanceValue = fabs(model.startTime - weakSelf.currentTime);

                }else {
                        if (idx == weakSelf.videoTimeSegmentArray.count - 1) {
                            scrollModel = nil;
                            modelIdx = -1;
                            *stop = YES;
                        }
                }
            }
            
        }];
        
        if (modelIdx != -1) {
            scrollModel = self.videoTimeSegmentArray[modelIdx];
            CGFloat offsetx = scrollModel.startTime/(secondsNumber/(kItemWith*24));
            scrollOffsetX = offsetx;
            weakSelf.currentTime = scrollModel.startTime;
            [self.dateScrollView setContentOffset:CGPointMake(scrollOffsetX, 0) animated:YES];
        }
    }
    return scrollModel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

#pragma mark - setting getting

- (void)setVideoTimeSegmentArray:(NSArray *)videoTimeSegmentArray {
    
    _videoTimeSegmentArray = videoTimeSegmentArray;
//    [self setNeedsLayout];
    
    if (self.dateScrollView.subviews.count != 0) {
        [self.dateScrollView removeFromSuperview];
        [self setupScrollSubViews];
        [self bringSubviewToFront:self.midLine];
    }

    CGFloat kTopPlaceHoldViewPadding = 10;
    CGFloat kPlaceHoldViewHeight = 20;

    if (videoTimeSegmentArray.count != 0) {
        for (TIoTTimeModel *timeSegment in videoTimeSegmentArray) {
            CGFloat x1 = timeSegment.startTime/(secondsNumber/(kItemWith*24))+self.kScrollViewWidth/2;
            CGFloat x2 = timeSegment.endTime/(secondsNumber/(kItemWith*24))+self.kScrollViewWidth/2;
            UIView *view = [UIView new];
            view.backgroundColor = [[UIColor colorWithHexString:kVideoDemoMainThemeColor]colorWithAlphaComponent:0.06];
            view.frame = CGRectMake(x1, kTopPlaceHoldViewPadding, x2-x1, kPlaceHoldViewHeight);
            [self.dateScrollView addSubview:view];
        }
    }
}

- (void)resetSelectedDate:(NSString *)dayDateString {
    [self.dateButton setTitle:dayDateString?:self.defaultDateString forState:UIControlStateNormal];
    [self.dateButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.dateButton.imageView.frame.size.width-kIntervalSapce, 0, self.dateButton.imageView.frame.size.width+kIntervalSapce)];
    [self.dateButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.dateButton.titleLabel.bounds.size.width+kIntervalSapce, 0, -self.dateButton.titleLabel.bounds.size.width - kIntervalSapce)];
    
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self getTimeDataScorllEnd:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self getTimeDataScorllEnd:scrollView];
    }
}

///MARK: 滚动结束时返回当前时间戳和所在model
- (void)getTimeDataScorllEnd:(UIScrollView *)scrollView {
    CGFloat xOffset = scrollView.contentOffset.x;
    NSInteger tempStartTime = xOffset * secondsNumber/(kItemWith*24);
    self.currentTime = tempStartTime;
    NSInteger hour = tempStartTime / (60*60);
    NSInteger mintue = tempStartTime % (60*60) / 60;
    NSInteger second = tempStartTime % (60*60) % 60;
    
    NSString *partTime = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hour,(long)mintue,(long)second];
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",self.dateButton.titleLabel.text,partTime];
    
    NSString *startTimestampString = [NSString getTimeStampWithString:dateString withFormatter:@"YYYY-MM-dd HH:mm:ss" withTimezone:@""];
    
    __weak typeof(self) weakSelf = self;
    [self.videoTimeSegmentArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TIoTTimeModel *model = obj;
        if (tempStartTime >= model.startTime && tempStartTime <= model.endTime) {
            if (weakSelf.timeModelBlock) {
                weakSelf.timeModelBlock(model, startTimestampString.floatValue);
            }
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
