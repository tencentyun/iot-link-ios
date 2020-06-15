//
//  WCSlideView.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/23.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCSlideView.h"

@implementation WCSlider

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

@interface WCSlideView ()
@property (nonatomic,copy) NSString *type;//数据类型，整形还是浮点

@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *valueLab;

@property (nonatomic,strong) UIButton *deleteBtn;

@end

@implementation WCSlideView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = kRGBAColor(0, 0, 0, 0.7);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:tap];
    
    self.whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 260)];
    _whiteView.backgroundColor = [UIColor whiteColor];
    //占用手势
    UITapGestureRecognizer *zw = [[UITapGestureRecognizer alloc] init];
    [_whiteView addGestureRecognizer:zw];
    [self addSubview:_whiteView];
//    [_whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.mas_equalTo(0);
//        make.height.mas_equalTo(260);
//    }];
    
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.textColor = kRGBColor(51, 51, 51);
    self.titleLab.font = [UIFont systemFontOfSize:18];
    [_whiteView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(_whiteView).offset(20);
    }];
    
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteBtn setTitle:@"删除动作" forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:kMainColor forState:UIControlStateNormal];
    self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    self.deleteBtn.hidden = YES;
    [self.deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [_whiteView addSubview:self.deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
    }];
    
    self.valueLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, kScreenWidth - 40, 30)];
    self.valueLab.text = @"0%";
    self.valueLab.textAlignment = NSTextAlignmentCenter;
    self.valueLab.textColor = kRGBColor(51, 51, 51);
    self.valueLab.font = [UIFont boldSystemFontOfSize:24];
    [_whiteView addSubview:self.valueLab];
    
    self.slider = [[WCSlider alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.valueLab.frame), kScreenWidth - 40, 40)];
    self.slider.minimumValue = 0;// 设置最小值
    self.slider.maximumValue = 100;// 设置最大值
    self.slider.value = 0;// 设置初始值
    self.slider.continuous = YES;// 设置可连续变化
    self.slider.minimumTrackTintColor = kMainColor;//滑轮左边颜色，如果设置了左边的图片就不会显示
    self.slider.maximumTrackTintColor = kRGBColor(236, 236, 236); //滑轮右边颜色，如果设置了右边的图片就不会显示
    //    slider.thumbTintColor = [UIColor redColor];//设置了滑轮的颜色，如果设置了滑轮的样式图片就不会显示
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_whiteView addSubview:self.slider];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.slider.frame) + 35, kScreenWidth, 1)];
    line.backgroundColor = kRGBColor(245, 245, 245);
    [_whiteView addSubview:line];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, CGRectGetMaxY(line.frame), kScreenWidth, 60);
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn setTitleColor:kFontColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [_whiteView addSubview:btn];
}

- (void)sliderValueChanged:(id)sender{
    UISlider *slider = (UISlider *)sender;
    if ([self.type isEqualToString:@"int"]) {
        self.valueLab.text = [NSString stringWithFormat:@"%.f%@", slider.value,self.dic[@"define"][@"unit"]];
    }
    else
    {
        self.valueLab.text = [NSString stringWithFormat:@"%.1f%@", slider.value,self.dic[@"define"][@"unit"]];
    }
    
//    [self.valueLab mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset((slider.value - slider.minimumValue)/(slider.maximumValue - slider.minimumValue)*(kScreenWidth-75) + 25);
//    }];
}

- (void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.whiteView.frame = CGRectMake(0, kScreenHeight - 260, kScreenWidth, 260);
    }];
}

- (void)hide{
    [self removeFromSuperview];
}

- (void)done
{
    [self hide];
    if (self.updateData) {
        NSDictionary *dic = @{self.dic[@"id"]:@([self.valueLab.text integerValue])};
        self.updateData(dic);
    }
}

- (void)deleteAction
{
    [self hide];
    if (self.deleteTap) {
        self.deleteTap();
    }
}


#pragma mark - getter setter

- (void)setShowValue:(NSString *)showValue
{
    _showValue = showValue;
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    self.titleLab.text = dic[@"name"];
    self.slider.minimumValue = [dic[@"define"][@"min"] integerValue];// 设置最小值
    self.slider.maximumValue = [dic[@"define"][@"max"] integerValue];// 设置最大值
    if (self.showValue) {
        self.slider.value = [self.showValue integerValue];// 设置初始值
    }
    else
    {
        self.slider.value = [dic[@"status"][@"Value"]?:dic[@"define"][@"start"] integerValue];// 设置初始值
    }
    
    
    self.type = dic[@"define"][@"type"];
    if ([@"int" isEqualToString:dic[@"define"][@"type"]]) {
        self.valueLab.text = [NSString stringWithFormat:@"%.f%@", roundf(self.slider.value) ,dic[@"define"][@"unit"]];
    }
    else
    {
        self.valueLab.text = [NSString stringWithFormat:@"%.1f%@", self.slider.value ,dic[@"define"][@"unit"]];
    }
    
//    [self.valueLab mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset((self.slider.value - self.slider.minimumValue)/(self.slider.maximumValue - self.slider.minimumValue)*(kScreenWidth-75) + 25);
//    }];
}

- (void)setIsAction:(BOOL)isAction
{
    self.deleteBtn.hidden = !isAction;
}

@end
