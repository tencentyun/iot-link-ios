//
//  TIoTChooseSliderValueView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTChooseSliderValueView.h"
#import "UIView+XDPExtension.h"
#import "UILabel+TIoTExtension.h"


@implementation TIoTCustomSlider

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    bounds = [super trackRectForBounds:bounds];
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, 10);
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    bounds = [super thumbRectForBounds:bounds trackRect:rect value:value];
    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
}
@end

@interface TIoTChooseSliderValueView ()
@property (nonatomic, strong) UIView *backMaskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *sliderBackView;

@property (nonatomic,copy) NSString *type;//数据类型，整形还是浮点

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *valueLab;

@end

@implementation TIoTChooseSliderValueView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViewUI];
    }
    return self;
}

- (void)setupSubViewUI {
    
    CGFloat kViewHeight = 236;
    CGFloat kTopViewHeight = 48;
    
    [self addSubview:self.backMaskView];
    [self.backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    [self.backMaskView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.backMaskView);
        make.height.mas_equalTo(kViewHeight);
    }];
    
    [self changeViewRectConnerWithView:self.contentView withRect:CGRectMake(0, 0, kScreenWidth, kViewHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    
    [self.contentView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
        make.height.mas_equalTo(kTopViewHeight);
    }];

    UILabel *viewTitle = [[UILabel alloc]init];
    [viewTitle setLabelFormateTitle:@"亮度test" font:[UIFont wcPfMediumFontOfSize:16] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    [self.topView addSubview:viewTitle];
    [viewTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.topView);
    }];
    
    UIView *slideLine = [[UIView alloc]init];
    slideLine.backgroundColor = [UIColor colorWithHexString:@"#F3F3F5"];
    [self.contentView addSubview:slideLine];
    [slideLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];

    
    self.sliderBackView = [[UIView alloc]init];
    self.sliderBackView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.sliderBackView];
    [self.sliderBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(slideLine.mas_bottom);
        make.left.right.bottom.equalTo(self.contentView);
    }];
    
    self.valueLab = [[UILabel alloc]init];
    [self.valueLab setLabelFormateTitle:@"0.0" font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    [self.sliderBackView addSubview:self.valueLab];
    [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.sliderBackView.mas_top).offset(20);
        make.height.mas_equalTo(30);
    }];
    
    
    self.slider = [[TIoTCustomSlider alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.valueLab.frame)+ 50, kScreenWidth - 40, 40)];
    self.slider.minimumValue = 0;// 设置最小值
    self.slider.maximumValue = 100;// 设置最大值
    self.slider.value = 0;// 设置初始值
    self.slider.continuous = YES;// 设置可连续变化
    self.slider.minimumTrackTintColor = kMainColor;//滑轮左边颜色，如果设置了左边的图片就不会显示
    self.slider.maximumTrackTintColor = kRGBColor(236, 236, 236); //滑轮右边颜色，如果设置了右边的图片就不会显示
    //    slider.thumbTintColor = [UIColor redColor];//设置了滑轮的颜色，如果设置了滑轮的样式图片就不会显示
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderBackView addSubview:self.slider];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.backMaskView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.backMaskView);
        make.bottom.equalTo(self.contentView.mas_top);
    }];

    
}

#pragma mark - event

- (void)sliderValueChanged:(id)sender{
    UISlider *slider = (UISlider *)sender;
    if ([self.type isEqualToString:@"int"]) {
        self.valueLab.text = [NSString stringWithFormat:@"%.f", slider.value];
    }
    else
    {
        self.valueLab.text = [NSString stringWithFormat:@"%.1f", slider.value];
    }
}

- (void)setShowValue:(NSString *)showValue
{
    _showValue = showValue;
}

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
}

#pragma mark - lazy loading

- (UIView *)backMaskView {
    if (!_backMaskView) {
        _backMaskView = [[UIView alloc]init];
        _backMaskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    }
    return _backMaskView;
}

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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
