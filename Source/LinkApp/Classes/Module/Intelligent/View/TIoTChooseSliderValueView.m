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
#import "TIoTIntelligentBottomActionView.h"
#import "UIButton+LQRelayout.h"

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
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;
@property (nonatomic, strong) UIView *sliderBackView;
@property (nonatomic, strong) UILabel *viewTitle;
//@property (nonatomic,copy) NSString *type;//数据类型，整形还是浮点  用model中type判断

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *valueLab;
@property (nonatomic, assign) CGFloat sliderWidth;
@property (nonatomic, strong) UIButton *reduceButton;
@property (nonatomic, strong) UIButton *increaseButton;
@property (nonatomic, assign) NSInteger kvalueLabPadding;

@property (nonatomic, strong) UIButton *greaterButton;//大于
@property (nonatomic, strong) UIButton *equalButton;//等于
@property (nonatomic, strong) UIButton *lesserButton;//小于

@property (nonatomic, strong) NSString *compareValueString;
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
    
    self.compareValueString = @"gt";
    
    CGFloat kBottomViewHeight = 56;
    CGFloat kViewHeight = 236 + kBottomViewHeight;
    CGFloat kTopViewHeight = 48;
    
    CGFloat kPadding = 30;
    CGFloat kLeftButtonWithHeight = 28;
    CGFloat kSliderLeftSpace = 20;
    
    CGFloat kCompareBtnWidht = 45;
    CGFloat kCompareBtnHeight = 28;
    
    CGFloat kSliderWidth = kScreenWidth - kPadding*2 - kLeftButtonWithHeight*2 - kSliderLeftSpace*2;
    self.sliderWidth = kSliderWidth;
    
    self.kvalueLabPadding = kSliderLeftSpace + kLeftButtonWithHeight + kPadding;
    
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

    self.viewTitle= [[UILabel alloc]init];
    [self.viewTitle setLabelFormateTitle:@"" font:[UIFont wcPfMediumFontOfSize:16] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    [self.topView addSubview:self.viewTitle];
    [self.viewTitle mas_makeConstraints:^(MASConstraintMaker *make) {
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


    self.reduceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.reduceButton.layer.cornerRadius = kLeftButtonWithHeight/2;
    [self.reduceButton setImage:[UIImage imageNamed:@"intelligent_reduce"] forState:UIControlStateNormal];
    [self.reduceButton setImage:[UIImage imageNamed:@"intelligent_reduce"] forState:UIControlStateHighlighted];
    [self.reduceButton addTarget:self action:@selector(reduceValue) forControlEvents:UIControlEventTouchUpInside];
    [self.sliderBackView addSubview:self.reduceButton];
    [self.reduceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sliderBackView.mas_left).offset(kPadding);
        CGFloat kReduceBtnY = (kViewHeight - kBottomViewHeight - kTopViewHeight)/2+20;
        make.top.mas_equalTo(kReduceBtnY);
        make.width.height.mas_equalTo(kLeftButtonWithHeight);
    }];

    self.increaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.increaseButton.layer.cornerRadius = kLeftButtonWithHeight/2;
    [self.increaseButton setImage:[UIImage imageNamed:@"intelligent_increase"] forState:UIControlStateNormal];
    [self.increaseButton setImage:[UIImage imageNamed:@"intelligent_increase"] forState:UIControlStateHighlighted];
    [self.increaseButton addTarget:self action:@selector(increseValue) forControlEvents:UIControlEventTouchUpInside];
    [self.sliderBackView addSubview:self.increaseButton];
    [self.increaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.sliderBackView.mas_right).offset(-kPadding);
        make.top.equalTo(self.reduceButton.mas_top);
        make.width.height.equalTo(self.reduceButton);
    }];
    
    self.valueLab = [[UILabel alloc]init];
    [self.valueLab setLabelFormateTitle:@"0.0" font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    [self.sliderBackView addSubview:self.valueLab];
    [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.reduceButton.mas_top).offset(-10);
        make.height.mas_equalTo(30);
    }];
    
    self.slider = [[TIoTCustomSlider alloc]init];
    self.slider.minimumValue = self.model.define.min.intValue?:0;// 设置最小值
    self.slider.maximumValue = self.model.define.max.intValue?:100;// 设置最大值
    self.slider.value = self.model.define.start.intValue?:0;// 设置初始值
    self.slider.continuous = YES;// 设置可连续变化
    self.slider.minimumTrackTintColor = [UIColor colorWithHexString:kIntelligentMainHexColor];//滑轮左边颜色，如果设置了左边的图片就不会显示
    self.slider.maximumTrackTintColor = kRGBColor(236, 236, 236); //滑轮右边颜色，如果设置了右边的图片就不会显示
    //    slider.thumbTintColor = [UIColor redColor];//设置了滑轮的颜色，如果设置了滑轮的样式图片就不会显示
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderBackView addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.reduceButton.mas_right).offset(kSliderLeftSpace);
        make.right.equalTo(self.increaseButton.mas_left).offset(-kSliderLeftSpace);
        make.centerY.equalTo(self.reduceButton.mas_centerY).offset(-5);
        make.width.mas_equalTo(kSliderWidth);
        make.height.mas_equalTo(40);
    }];

    self.greaterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.greaterButton.layer.cornerRadius = 13;
    [self.greaterButton setButtonFormateWithTitlt:NSLocalizedString(@"auto_gt", @"大于") titleColorHexString:kTemperatureHexColor font:[UIFont wcPfRegularFontOfSize:16]];
    [self.greaterButton addTarget:self action:@selector(clickCompareButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.sliderBackView addSubview:self.greaterButton];
    [self.greaterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider.mas_left).offset(-4);
        make.top.equalTo(self.sliderBackView.mas_top).offset(30);
        make.width.mas_equalTo(kCompareBtnWidht);
        make.height.mas_equalTo(kCompareBtnHeight);
    }];
    
    self.equalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.equalButton.layer.cornerRadius = 13;
    [self.equalButton setButtonFormateWithTitlt:NSLocalizedString(@"auto_equal", @"等于") titleColorHexString:kTemperatureHexColor font:[UIFont wcPfRegularFontOfSize:16]];
    [self.equalButton addTarget:self action:@selector(clickCompareButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.sliderBackView addSubview:self.equalButton];
    [self.equalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kCompareBtnWidht);
        make.height.mas_equalTo(kCompareBtnHeight);
        make.top.equalTo(self.greaterButton.mas_top);
        make.centerX.equalTo(self.sliderBackView.mas_centerX);
    }];
    
    self.lesserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lesserButton.layer.cornerRadius = 13;
    [self.lesserButton setButtonFormateWithTitlt:NSLocalizedString(@"auto_lt", @"auto_lt") titleColorHexString:kTemperatureHexColor font:[UIFont wcPfRegularFontOfSize:16]];
    [self.lesserButton addTarget:self action:@selector(clickCompareButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.sliderBackView addSubview:self.lesserButton];
    [self.lesserButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kCompareBtnWidht);
        make.height.mas_equalTo(kCompareBtnHeight);
        make.top.equalTo(self.greaterButton.mas_top);
        make.right.equalTo(self.slider.mas_right).offset(4);
    }];

    [self.contentView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.backMaskView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.backMaskView);
        make.bottom.equalTo(self.contentView.mas_top);
    }];
    
    [self clickCompareButton:self.greaterButton];
    
}

#pragma mark - event

- (void)clickCompareButton:(UIButton *)sender {
    if (sender == self.greaterButton) {
        self.compareValueString = @"gt";
        [self.greaterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.greaterButton setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
        
        [self.equalButton setTitleColor:[UIColor colorWithHexString:kTemperatureHexColor] forState:UIControlStateNormal];
        [self.equalButton setBackgroundColor:[UIColor whiteColor]];
        [self.lesserButton setTitleColor:[UIColor colorWithHexString:kTemperatureHexColor] forState:UIControlStateNormal];
        [self.lesserButton setBackgroundColor:[UIColor whiteColor]];
    }else if (sender == self.equalButton) {
        self.compareValueString = @"eq";
        [self.equalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.equalButton setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
        
        [self.greaterButton setTitleColor:[UIColor colorWithHexString:kTemperatureHexColor] forState:UIControlStateNormal];
        [self.greaterButton setBackgroundColor:[UIColor whiteColor]];
        [self.lesserButton setTitleColor:[UIColor colorWithHexString:kTemperatureHexColor] forState:UIControlStateNormal];
        [self.lesserButton setBackgroundColor:[UIColor whiteColor]];
    }else if (sender == self.lesserButton) {
        self.compareValueString = @"lt";
        [self.lesserButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.lesserButton setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
        
        [self.greaterButton setTitleColor:[UIColor colorWithHexString:kTemperatureHexColor] forState:UIControlStateNormal];
        [self.greaterButton setBackgroundColor:[UIColor whiteColor]];
        [self.equalButton setTitleColor:[UIColor colorWithHexString:kTemperatureHexColor] forState:UIControlStateNormal];
        [self.equalButton setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)reduceValue {
    
    if ([self.model.define.type isEqualToString:@"int"]) {
        self.slider.value = round(self.slider.value) - self.model.define.step.intValue;
    }
    else
    {
        self.slider.value = self.slider.value - self.model.define.step.floatValue;

    }
    [self sliderValueChanged:self.slider];
}

- (void)increseValue {
    if ([self.model.define.type isEqualToString:@"int"]) {
        self.slider.value = round(self.slider.value) + self.model.define.step.intValue;
    }
    else
    {
        self.slider.value = self.slider.value + self.model.define.step.floatValue;
    }
    [self sliderValueChanged:self.slider];
}

- (void)sliderValueChanged:(id)sender{
    UISlider *slider = (UISlider *)sender;
    if ([self.model.define.type isEqualToString:@"int"]) {
        self.valueLab.text = [NSString stringWithFormat:@"%.f%@", roundf(slider.value) ,self.model.define.unit?:@""];
    }
    else
    {
        self.valueLab.text = [NSString stringWithFormat:@"%.1f%@", slider.value ,self.model.define.unit?:@""];
    }
    
    CGFloat KSliderValueX = 0;
    CGFloat kValueWidth = CGRectGetWidth(self.valueLab.frame);
    CGFloat kValueLabX = 0;
    KSliderValueX = self.slider.value/(self.slider.maximumValue - self.slider.minimumValue)*(self.sliderWidth);
    kValueLabX = KSliderValueX + self.kvalueLabPadding - kValueWidth/2;

    [self.valueLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kValueLabX);
    }];
    
}

- (void)setModel:(TIoTPropertiesModel *)model {
    _model = model;
    if ([self.model.define.type isEqualToString:@"int"]) {
        self.valueLab.text = [NSString stringWithFormat:@"%@%@", model.define.start ,model.define.unit?:@""];
        self.slider.value = model.define.start.intValue;
    }
    else
    {
        self.valueLab.text = [NSString stringWithFormat:@"%.1f%@", model.define.start.floatValue ,model.define.unit?:@""];
        self.slider.value = model.define.start.floatValue;
    }
    
    CGFloat kValueWidth = [self WidthWithString:self.valueLab.text font:[UIFont wcPfRegularFontOfSize:16] height:30];
    CGFloat KSliderValueX = self.slider.value/(self.slider.maximumValue - self.slider.minimumValue)*(self.sliderWidth);
    CGFloat kValueLabX = KSliderValueX + self.kvalueLabPadding - kValueWidth/2;
    
    [self.valueLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kValueLabX);
    }];
    
}

-(CGFloat)WidthWithString:(NSString*)string font:(UIFont *)font height:(CGFloat)height

{
    
    NSDictionary *attrs = @{NSFontAttributeName:font};
    
    return [string boundingRectWithSize:CGSizeMake(0, height) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size.width;
    
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

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        __weak typeof(self)weakSelf = self;
        
        [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"save", @"保存")]];
        
        _bottomView.firstBlock = ^{
            
            [weakSelf dismissView];
        };
        
        _bottomView.secondBlock = ^{
            if (weakSelf.sliderTaskValueBlock) {
                NSString *valueString = @"";
                if ([weakSelf.model.define.type isEqualToString:@"int"]) {
                    valueString = [NSString stringWithFormat:@"%.f%@", roundf(weakSelf.slider.value) ,weakSelf.model.define.unit?:@""];
                }
                else if ([weakSelf.model.define.type isEqualToString:@"float"])
                {
                    valueString = [NSString stringWithFormat:@"%.1f%@", weakSelf.slider.value ,weakSelf.model.define.unit?:@""];
                }
                
                weakSelf.sliderTaskValueBlock(valueString,weakSelf.model,[NSString stringWithFormat:@"%.1f",weakSelf.slider.value],weakSelf.compareValueString);
            }
            
            [weakSelf dismissView];
        };
        
    }
    return _bottomView;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.viewTitle.text = self.model.name?:@"";
    
    if (self.isEdited == YES && self.isActionType == NO) {
        NSString *opStr = self.conditionModel.Property.Op?:@"";
        if ([opStr isEqualToString:@"eq"]) { //条件操作符  eq 等于  ne 不等于  gt 大于  lt 小于  ge 大等于  le 小等于
            [self clickCompareButton:self.equalButton];
            
        }else if ([opStr isEqualToString:@"ne"]) {

        }else if ([opStr isEqualToString:@"gt"]) {
            [self clickCompareButton:self.greaterButton];
            
        }else if ([opStr isEqualToString:@"lt"]) {
            [self clickCompareButton:self.lesserButton];
            
        }else if ([opStr isEqualToString:@"ge"]) {

        }else if ([opStr isEqualToString:@"le"]) {

        }
    }
}

@end
