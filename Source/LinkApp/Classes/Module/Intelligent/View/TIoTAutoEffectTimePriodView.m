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

@interface TIoTAutoEffectTimePriodView ()
@property (nonatomic, strong) UIView *backMaskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIView *bottomBackView;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;
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
    CGFloat kRepeatViewHeight = 125; //重复周期选择view高度
    CGFloat kMiddleHeight = KItemHeight + kRepeatViewHeight + kSplitLineHeight; //中间view高度
    CGFloat kBottomViewHeight = 50;//底部view高度
    CGFloat kHeight = kTopViewHeight + kMiddleHeight + kBottomViewHeight + 2*kIntervalHeight; //总高度
    
    CGFloat KPaddingLeft = 24;
    CGFloat KPaddingRight = 27;
    
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
        make.left.right.bottom.equalTo(self.backMaskView);
        make.height.mas_equalTo(kHeight);
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
    UIButton *allDayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [allDayButton setBackgroundColor:[UIColor whiteColor]];
    [self.topView addSubview:allDayButton];
    [allDayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.topView);
        make.top.equalTo(splitLineTwo.mas_bottom);
        make.height.mas_equalTo(KItemHeight);
    }];
    
    UILabel *allDayTipLabel = [[UILabel alloc]init];
    [allDayButton addSubview:allDayTipLabel];
    [allDayTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
    }];
    

    UIView *splitLineThree = [[UIView alloc]init];
    splitLineThree.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.topView addSubview:splitLineThree];
    [splitLineThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(allDayButton.mas_bottom);
        make.left.right.equalTo(self.topView);
        make.height.mas_equalTo(kSplitLineHeight);
    }];

    //自定义
    UIButton *customTimePriodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customTimePriodButton setBackgroundColor:[UIColor whiteColor]];
    [self.topView addSubview:customTimePriodButton];
    [customTimePriodButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(splitLineThree.mas_bottom);
        make.left.right.equalTo(self.topView);
        make.height.mas_equalTo(KItemHeight);
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
    
}

#pragma mark - event

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
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
