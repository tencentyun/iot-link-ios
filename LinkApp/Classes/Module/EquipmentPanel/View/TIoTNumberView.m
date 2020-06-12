//
//  WCNumberView.m
//  TenextCloud
//
//  Created by Wp on 2020/1/3.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTNumberView.h"
#import "SliderView.h"
#import "UIImage+Ex.h"

@interface TIoTNumberView()

@property (nonatomic,strong) UIImageView *bgView;

@property (nonatomic,strong) SliderView *slider;
@property (nonatomic,strong) UILabel *nameLab;
@property (nonatomic,strong) UILabel *valueLab;

@property (nonatomic,strong) CAShapeLayer *scaleLayer;//刻度
@property (nonatomic,strong) CAShapeLayer *addlayer;//加减号

@property (nonatomic,copy) NSString *unit;//单位
@end

@implementation TIoTNumberView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.bgView];
    
    
    UILabel *titlab = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.frame.size.width, 20)];
    titlab.text = @"颜色";
    titlab.textColor = kFontColor;
    titlab.textAlignment = NSTextAlignmentCenter;
    titlab.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    [self addSubview:titlab];
    self.nameLab = titlab;
    
    UILabel *colorLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titlab.frame) + 20, self.frame.size.width, 36)];
    colorLab.text = @"红色";
    colorLab.textColor = kFontColor;
    colorLab.textAlignment = NSTextAlignmentCenter;
    colorLab.font = [UIFont systemFontOfSize:36 weight:UIFontWeightMedium];
    [self addSubview:colorLab];
    self.valueLab = colorLab;
    
    
    //刻度
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = CGRectMake(0, CGRectGetMaxY(colorLab.frame) + 50, self.frame.size.width, 9);
    CGFloat avg = (self.frame.size.width - 37 * 2) / 10.0;
    UIBezierPath *be = [UIBezierPath bezierPath];
    for (int i = 0; i < 11; i ++) {
        [be moveToPoint:CGPointMake(avg * i + 37, 0)];
        [be addLineToPoint:CGPointMake(avg * i + 37, CGRectGetHeight(layer.frame))];
    }
    layer.path = be.CGPath;
    layer.lineWidth = 2;
    layer.strokeColor = [UIColor grayColor].CGColor;
    [self.layer addSublayer:layer];
    self.scaleLayer = layer;
    
    
    //滑动条
    self.slider = [[SliderView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(layer.frame) + 20, self.frame.size.width - 32, 40)];
    _slider.minValue = 0;
    _slider.value = 50;
    _slider.maxValue = 100;
    _slider.normalColor = [UIColor whiteColor];

    _slider.trackColors = @[(__bridge id)kRGBColor(0, 82, 217).CGColor,(__bridge id)kRGBColor(106, 255, 255).CGColor];
    _slider.trackSize = CGSizeMake(kScreenWidth, 20);
    _slider.thumbSize = CGSizeMake(40, 40);
    self.slider.thumbImage = [UIImage getGradientImageWithColors:@[kRGBColor(106, 255, 255),kRGBColor(0, 82, 217)] imgSize:CGSizeMake(40, 40)];
    WeakObj(self);
    _slider.update = ^(CGFloat value) {
        if (selfWeak.update) {
            
            if ([@"int" isEqualToString:selfWeak.info[@"define"][@"type"]]) {
                selfWeak.update(@{selfWeak.info[@"id"]:@(roundf(value))});
            }
            else if ([@"float" isEqualToString:selfWeak.info[@"define"][@"type"]])
            {
                selfWeak.update(@{selfWeak.info[@"id"]:@(value)});
            }
        }
    };
    [self addSubview:self.slider];
    
    
    CAShapeLayer *layer2 = [[CAShapeLayer alloc] init];
    layer2.frame = CGRectMake(0, CGRectGetMaxY(self.slider.frame) + 20, self.frame.size.width, 20);
    
    UIBezierPath *bez = [UIBezierPath bezierPath];
    [bez moveToPoint:CGPointMake(37, 10)];
    [bez addLineToPoint:CGPointMake(37 + 20, 10)];
    
    [bez moveToPoint:CGPointMake(self.frame.size.width - 37 - 20, 10)];
    [bez addLineToPoint:CGPointMake(self.frame.size.width - 37, 10)];
    
    [bez moveToPoint:CGPointMake(self.frame.size.width - 37 - 10, 0)];
    [bez addLineToPoint:CGPointMake(self.frame.size.width - 37 - 10, 20)];
    
    layer2.path = bez.CGPath;
    layer2.lineWidth = 4;
    layer2.strokeColor = [UIColor whiteColor].CGColor;
    self.addlayer = layer2;
    [self.layer addSublayer:layer2];
    
    
    [self.slider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
}


#pragma mark -

- (void)setInfo:(NSDictionary *)info
{
    [super setInfo:info];
    self.nameLab.text = info[@"name"];
    self.unit = info[@"define"][@"unit"];
    NSString *min = [NSString stringWithFormat:@"%@",info[@"define"][@"min"]];
    NSString *max = [NSString stringWithFormat:@"%@",info[@"define"][@"max"]];
    self.slider.minValue = [min floatValue];
    self.slider.maxValue = [max floatValue];
    
    float value = [info[@"status"][@"Value"] floatValue];
    if (value < [min floatValue]) {
        value = [min floatValue];
    }
    self.valueLab.text = [NSString stringWithFormat:@"%.f %@",value,self.unit];
    [self.slider reloadData:value];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"value"]) {
        NSLog(@"%@",change);
        self.valueLab.text = [NSString stringWithFormat:@"%.f %@",[change[NSKeyValueChangeNewKey] floatValue],self.unit];
    }
}

- (void)setStyle:(WCThemeStyle)style
{
    if (style == WCThemeSimple) {
        self.bgView.hidden = YES;
        self.nameLab.textColor = kFontColor;
        self.valueLab.textColor = kFontColor;
        self.scaleLayer.strokeColor = kRGBColor(172, 172, 172).CGColor;
        self.slider.normalColor = kRGBColor(208, 208, 208);
        self.addlayer.strokeColor = kFontColor.CGColor;
    }
    else if (style == WCThemeStandard)
    {
        self.bgView.hidden = YES;
        self.nameLab.textColor = [UIColor whiteColor];
        self.valueLab.textColor = [UIColor whiteColor];
        self.scaleLayer.strokeColor = kRGBColor(175, 183, 193).CGColor;
        self.slider.normalColor = [UIColor whiteColor];
        self.addlayer.strokeColor = [UIColor whiteColor].CGColor;
    }
    else if (style == WCThemeDark)
    {
        self.nameLab.textColor = [UIColor whiteColor];
        self.valueLab.textColor = [UIColor whiteColor];
        self.scaleLayer.strokeColor = kRGBColor(114, 133, 164).CGColor;
        self.slider.normalColor = [UIColor whiteColor];
        self.addlayer.strokeColor = [UIColor whiteColor].CGColor;
    }
}


- (UIImageView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_enum"]];
        _bgView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
    return _bgView;
}

@end
