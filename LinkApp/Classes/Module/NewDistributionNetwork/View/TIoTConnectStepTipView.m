//
//  TIoTConnectStepTipView.m
//  LinkApp
//
//  Created by Sun on 2020/7/30.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTConnectStepTipView.h"

@interface TIoTConnectStepTipView ()

@property (nonatomic, strong) NSArray *titlesArray;
/// 保存菊花视图
@property (nonatomic, strong) NSMutableArray *activityIndicatorsArray;
/// 保存对勾视图
@property (nonatomic, strong) NSMutableArray *checkImageViewsArray;

@end

@implementation TIoTConnectStepTipView

- (instancetype)initWithTitlesArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _titlesArray = array;
        _activityIndicatorsArray = [NSMutableArray array];
        _checkImageViewsArray = [NSMutableArray array];
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    for (int i = 0; i < _titlesArray.count; i++) {
        CGFloat edgeSpace = 10.0f;
        CGFloat activityIndicatorWidth = 24.0f;
        CGFloat tipLabelWidth = 135;
        
        UIView *bgLeftView = [[UIView alloc] init];
        bgLeftView.frame = CGRectMake(0, 0+(edgeSpace + activityIndicatorWidth)*i, activityIndicatorWidth, activityIndicatorWidth);
        [self addSubview:bgLeftView];
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        activityIndicator.frame = CGRectMake(0, 0, activityIndicatorWidth, activityIndicatorWidth);
        [bgLeftView addSubview:activityIndicator];
        [_activityIndicatorsArray addObject:activityIndicator];
        //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
        activityIndicator.hidesWhenStopped = NO;
        [activityIndicator startAnimating];
        
        UIImageView *checkImageView = [[UIImageView alloc] init];
        checkImageView.frame = CGRectMake(0, 0, activityIndicatorWidth, activityIndicatorWidth);
        checkImageView.image = [UIImage imageNamed:@"new_distri_check123"];
        [bgLeftView addSubview:checkImageView];
        checkImageView.hidden = YES;
        [_checkImageViewsArray addObject:checkImageView];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.frame = CGRectMake(CGRectGetMaxX(bgLeftView.frame) + 7, CGRectGetMinY(bgLeftView.frame), tipLabelWidth, activityIndicatorWidth);
        tipLabel.text = _titlesArray[i];
        tipLabel.font = [UIFont wcPfRegularFontOfSize:15];
        tipLabel.textColor = kRGBColor(136, 136, 136);
        [self addSubview:tipLabel];
    }
}

- (void)setStep:(NSInteger)step {
    _step = step;
    for (int i = 0; i < _titlesArray.count; i++) {
        UIActivityIndicatorView *activityIndicator = _activityIndicatorsArray[i];
        UIImageView *checkImageView = _checkImageViewsArray[i];
        if (i+1 > _step) {
            break;
        } else {
            [activityIndicator stopAnimating];
            activityIndicator.hidden = YES;
            checkImageView.hidden = NO;
        }
    }
}

@end
