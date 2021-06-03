//
//  TIoTDemoCustomChoiceDateView.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/3.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoCustomChoiceDateView.h"

static CGFloat const kDateViewHeight = 44;
static CGFloat const kDateScrollHeight = 72;

@interface TIoTDemoCustomChoiceDateView ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIButton *dateButton;
@end

@implementation TIoTDemoCustomChoiceDateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupScrollSubViews];
    }
    return self;
    
}

- (void)setupScrollSubViews {
    
    //顶部选择时间底层View
    UIView *topDateView = [[UIView alloc]init];
    topDateView.backgroundColor = [UIColor whiteColor];
    [self addSubview:topDateView];
    [topDateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(kDateViewHeight);
    }];
    
    CGFloat kDaateButtonWidth = 120;
    CGFloat kIntervalSapce = 4;
    
    self.dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dateButton.frame = CGRectMake(kScreenWidth/2-kDaateButtonWidth/2, 10, kDaateButtonWidth, 24);
    [self.dateButton setButtonFormateWithTitlt:@"2020-08-29" titleColorHexString:kVideoDemoDateTipTextColor font:[UIFont wcPfRegularFontOfSize:17]];
    [self.dateButton setImage:[UIImage imageNamed:@"choiceDate_tip"] forState:UIControlStateNormal];
    [self.dateButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.dateButton.imageView.frame.size.width-kIntervalSapce, 0, self.dateButton.imageView.frame.size.width+kIntervalSapce)];
    [self.dateButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.dateButton.titleLabel.bounds.size.width+kIntervalSapce, 0, -self.dateButton.titleLabel.bounds.size.width - kIntervalSapce)];
    [self.dateButton addTarget:self action:@selector(chooseDate:) forControlEvents:UIControlEventTouchUpInside];
    [topDateView addSubview:self.dateButton];
    
    CGFloat kWidthMargin = 16; //左右边距
    CGFloat kButtonSize = 28; //按钮宽搞
    CGFloat kScrollViewWidth = kScreenWidth-2*kWidthMargin-2*kButtonSize; //scrollView 总长度
    CGFloat kScrollViewHeight = 72; //scrollview高度
    CGFloat kItemWith = 60; //每小时长度
    CGFloat kMinItemWidth = (60 - 5)/6;
    CGFloat kTipLabelWidth = 38;
    CGFloat kTopPadding = 4; //长刻度距离scrollview 高度
    CGFloat kMinTopPadding = 10; //段刻度距离scrollview 高度
    CGFloat kMinLineHeight = 20;
    
    //刻度scrollview
    UIScrollView *dateScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(kWidthMargin+kButtonSize, CGRectGetMaxY(self.dateButton.frame), kScrollViewWidth, kScrollViewHeight)];
    dateScrollView.backgroundColor = [UIColor greenColor];
    [self addSubview:dateScrollView];
    dateScrollView.delegate = self;
    dateScrollView.contentSize = CGSizeMake(kItemWith*24 + kScrollViewWidth, 50);
    
    for (int i = 0; i < 25; i++) {
        //小时刻度
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(i*kItemWith + kScrollViewWidth/2, kTopPadding, 1, 32)];
        lineView.backgroundColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
        [dateScrollView addSubview:lineView];
        
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame) - kTipLabelWidth/2, CGRectGetMaxY(lineView.frame)+8, kTipLabelWidth, 18)];
        [timeLabel setLabelFormateTitle:[NSString stringWithFormat:@"%d:00",i] font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kVideoDemoTextContentColor textAlignment:NSTextAlignmentCenter];
        if (i<10) {
            timeLabel.text = [NSString stringWithFormat:@"0%d:00",i];
        }
        [dateScrollView addSubview:timeLabel];
        
        if (i < 24) {
            //每小时内6等分刻度线
            for (int j = 1; j <= 5; j++) {
                UIView *minLine = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame)+j*kMinItemWidth, kMinTopPadding, 1, kMinLineHeight)];
                minLine.backgroundColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
                [dateScrollView addSubview:minLine];
            }
        }
    }
    
    //中间刻度标记
    UIView *midLine = [[UIView alloc]init];
    midLine.backgroundColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    [self addSubview:midLine];
    [midLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(40);
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(dateScrollView.mas_top).offset(kTopPadding);
    }];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"left_date"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(choosePreviousDate) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kWidthMargin);
        make.width.height.mas_equalTo(kButtonSize);
        make.top.equalTo(topDateView.mas_bottom);
    }];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"right_date"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(chooseNextDate) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightButton];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kButtonSize);
        make.top.equalTo(topDateView.mas_bottom);
        make.right.equalTo(self.mas_right).offset(-kWidthMargin);
    }];

}

- (void)chooseDate:(UIButton *)button {
    if (self.chooseDateBlock) {
        self.chooseDateBlock(button);
    }
}

- (void)choosePreviousDate {
    
}

- (void)chooseNextDate {
    
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    self.sliderBottomView.frame = CGRectMake(-scrollView.contentOffset.x + self.kLeftPadding, CGRectGetMaxY(self.calendarBtn.frame)+self.kTopPadding, self.kScrollContentWidth - self.kLeftPadding*2, self.kSliderHeight);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
