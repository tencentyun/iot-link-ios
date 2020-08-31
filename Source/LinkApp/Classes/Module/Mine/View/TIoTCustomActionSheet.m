//
//  TIoTCustomActionSheet.m
//  LinkApp
//
//  Created by ccharlesren on 2020/8/15.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTCustomActionSheet.h"
@interface TIoTCustomActionSheet ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *centigradeTemperaturView;//摄氏温度
@property (nonatomic, strong) UIView *FahrenheitView;//华氏温度
@property (nonatomic, strong) UIView *detailChooiceView;
@property (nonatomic, strong) UIView *actionView;
@end

@implementation TIoTCustomActionSheet

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    
    self.backgroundColor = kRGBAColor(0, 0, 0, 0.6);
    
    CGFloat kContentHeight = 180 * kScreenAllHeightScale;
    
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.leading.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(kContentHeight);
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissView)];
    [self addGestureRecognizer:tapGesture];
    
    [self changeViewRectConnerWithView:self.contentView withRect:CGRectMake(0, 0, kScreenWidth, kContentHeight)];
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        
        [_contentView addSubview:self.detailChooiceView];
        [self.detailChooiceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.top.equalTo(_contentView);
            make.height.mas_equalTo(100 * kScreenAllHeightScale);
        }];
        
        [_contentView addSubview:self.actionView];
        [self.actionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.detailChooiceView.mas_bottom).offset(10 * kScreenAllHeightScale);
            make.trailing.leading.equalTo(_contentView);
            make.height.mas_equalTo(85 * kScreenAllHeightScale);
        }];
    }
    
    return _contentView;
}

- (UIView *)detailChooiceView {
    if (!_detailChooiceView) {
        _detailChooiceView = [[UIView alloc]init];
        _detailChooiceView.backgroundColor = [UIColor whiteColor];
        
        CGFloat kChoiceHeight = 50 * kScreenAllHeightScale;
        
        //华氏温度
        UIButton *fahrenheitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setSpecificButtonFormat:fahrenheitBtn withTitle:@"℉"];
        [fahrenheitBtn addTarget:self action:@selector(chooseFahrenheitStyle) forControlEvents:UIControlEventTouchUpInside];
        [_detailChooiceView addSubview:fahrenheitBtn];
        [fahrenheitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.top.equalTo(_detailChooiceView);
            make.height.mas_equalTo(kChoiceHeight);
        }];
        
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        [_detailChooiceView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.equalTo(_detailChooiceView);
            make.height.mas_equalTo(1);
            make.top.equalTo(fahrenheitBtn.mas_bottom);
        }];
        
        //摄氏温度
        UIButton *celsius = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setSpecificButtonFormat:celsius withTitle:@"℃"];
        [celsius addTarget:self action:@selector(chooseCelsius) forControlEvents:UIControlEventTouchUpInside];
        [_detailChooiceView addSubview:celsius];
        [celsius mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.equalTo(_detailChooiceView);
            make.top.equalTo(line.mas_bottom);
            make.height.mas_equalTo(kChoiceHeight);
        }];
        
    }
    return _detailChooiceView;
}

- (UIView *)actionView {
    if (!_actionView) {
        _actionView = [[UIView alloc]init];
        _actionView.backgroundColor = [UIColor whiteColor];
        
        CGFloat kdismissBtnHeight = 50 * kScreenAllHeightScale;
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissButton addTarget:self action:@selector(dismissActionView) forControlEvents:UIControlEventTouchUpInside];
        [self setSpecificButtonFormat:dismissButton withTitle:@"取消"];
        [_actionView addSubview:dismissButton];
        [dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.top.equalTo(_actionView);
            make.height.mas_equalTo(kdismissBtnHeight);
        }];
    }
    return _actionView;
}

#pragma mark - private method
//设置button样式
- (void)setSpecificButtonFormat:(UIButton *)button withTitle:(NSString *)title {
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [button setTitleColor:[UIColor colorWithHexString:kTemperatureHexColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
}

//设置圆角
- (void)changeViewRectConnerWithView:(UIView *)view withRect:(CGRect )rect{
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer * layer = [[CAShapeLayer alloc]init];
    layer.frame = view.bounds;
    layer.path = path.CGPath;
    view.layer.mask = layer;

}

//隐藏actionSheet
- (void)dismissActionView {
    [self dismissView];
}

//转华氏温度
- (void)chooseFahrenheitStyle {
    if (self.choiceFahrenheitBlock) {
        self.choiceFahrenheitBlock();
        [self dismissActionView];
    }
    
}

//转摄氏温度
- (void)chooseCelsius {
    if (self.choiceCelsiusBlock) {
        self.choiceCelsiusBlock();
        [self dismissActionView];
    }
}

#pragma mark - event
- (void)shwoActionSheetView {
    [[[UIApplication sharedApplication] delegate].window addSubview:self];
}

- (void)dismissView {
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
