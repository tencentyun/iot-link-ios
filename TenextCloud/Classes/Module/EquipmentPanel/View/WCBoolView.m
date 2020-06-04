//
//  WCBoolView.m
//  TenextCloud
//
//  Created by Wp on 2020/1/3.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCBoolView.h"

@interface WCBoolView()

@property (nonatomic,strong) UIButton *ibtn;
@property (nonatomic,strong) UILabel *iLab;

@end

@implementation WCBoolView

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
    self.ibtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_ibtn setImage:[UIImage imageNamed:@"simple_off1"] forState:UIControlStateNormal];
    [_ibtn setImage:[UIImage imageNamed:@"simple_off2"] forState:UIControlStateHighlighted];
    [_ibtn addTarget:self action:@selector(turnOnOrOff) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_ibtn];
    [self.ibtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(-0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
//        make.height.mas_equalTo(400);
    }];
    
    
    self.iLab = [[UILabel alloc] init];
    _iLab.text = @"电源开关：关闭";
    _iLab.font = [UIFont systemFontOfSize:18];
    _iLab.textColor = kFontColor;
    _iLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_iLab];
    [self.iLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)turnOnOrOff
{
    if (self.info && self.update) {
        NSInteger key = [self.info[@"status"][@"Value"] integerValue];
        self.update(@{self.info[@"id"]:@(key == 0 ? 1 : 0)});
    }
}


- (void)setInfo:(NSDictionary *)info
{
    [super setInfo:info];
    NSInteger key = [info[@"status"][@"Value"] integerValue];
    self.iLab.text = key == 0 ? @"电源开关：关闭" : @"电源开关：开启";
    
    if (self.style == WCThemeSimple) {
        
        [self.ibtn setImage:[UIImage imageNamed:key == 0 ? @"simple_off1" : @"simple_on1"] forState:UIControlStateNormal];
        [self.ibtn setImage:[UIImage imageNamed:key == 0 ? @"simple_off2" : @"simple_on2"] forState:UIControlStateHighlighted];
    }
    else if (self.style == WCThemeStandard)
    {
        
        [self.ibtn setImage:[UIImage imageNamed:key == 0 ? @"standard_off1" : @"standard_on1"] forState:UIControlStateNormal];
        [self.ibtn setImage:[UIImage imageNamed:key == 0 ? @"standard_off2" : @"standard_on2"] forState:UIControlStateHighlighted];
    }
    else if (self.style == WCThemeDark)
    {
        [self.ibtn setImage:[UIImage imageNamed:key == 0 ? @"dark_off1" : @"dark_on1"] forState:UIControlStateNormal];
        [self.ibtn setImage:[UIImage imageNamed:key == 0 ? @"dark_off2" : @"dark_on2"] forState:UIControlStateHighlighted];
    }
    
}

- (void)setStyle:(WCThemeStyle)style
{
    _style = style;
    if (style == WCThemeSimple) {
        
        self.iLab.textColor = kFontColor;
    }
    else if (style == WCThemeStandard)
    {
        
        self.iLab.textColor = [UIColor whiteColor];
    }
    else if (style == WCThemeDark)
    {
        
        self.iLab.textColor = [UIColor whiteColor];
    }
}
@end
