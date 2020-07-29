//
//  TIoTStepTipView.m
//  LinkApp
//
//  Created by Sun on 2020/7/28.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTStepTipView.h"

@interface TIoTStepTipView()

@property (nonatomic, strong) NSArray *tipsArray;
///当前处于第几步
@property (nonatomic, assign) NSInteger step;

@end

@implementation TIoTStepTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.step = 2;
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    for (int i = 0; i < self.tipsArray.count; i++) {
        CGFloat kSelfWidth = kScreenWidth;//self.bounds.size.width;
        
        CGFloat edgeSpace = 18.0f;
        CGFloat stepLabelWidth = 24.0f;
        CGFloat viewWidth = (kSelfWidth - 2*edgeSpace - _tipsArray.count*stepLabelWidth)/(_tipsArray.count - 1.0f);
        CGFloat viewHeight = 4.0f;
        
        UILabel *stepLabel = [[UILabel alloc] init];
        stepLabel.frame = CGRectMake(edgeSpace + (stepLabelWidth + viewWidth)*i, 0, stepLabelWidth, stepLabelWidth);
        stepLabel.text = [NSString stringWithFormat:@"%d", i+1];
        stepLabel.font = [UIFont wcPfRegularFontOfSize:12];
        stepLabel.textColor = [UIColor whiteColor];
        stepLabel.textAlignment = NSTextAlignmentCenter;
        stepLabel.layer.masksToBounds = YES;
        stepLabel.layer.cornerRadius = stepLabelWidth*0.5f;
        [self addSubview:stepLabel];
        
        if (_tipsArray.count != i+1) {
            UIView *view = [[UIView alloc] init];
            view.frame = CGRectMake(CGRectGetMaxX(stepLabel.frame), (stepLabelWidth - viewHeight)*0.5, viewWidth, viewHeight);
            [self addSubview:view];
            if (self.step <= i+1) {
                view.backgroundColor = [UIColor lightGrayColor];
            } else {
                view.backgroundColor = kMainColor;
            }
        }
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.bounds = CGRectMake(0, 0, stepLabelWidth, stepLabelWidth);
        tipLabel.text = _tipsArray[i];
        tipLabel.font = [UIFont wcPfRegularFontOfSize:12];
        [tipLabel sizeToFit];
        tipLabel.center = CGPointMake(stepLabel.center.x, CGRectGetMaxY(stepLabel.frame) + 20.0f);
        [self addSubview:tipLabel];
        
        if (self.step < i+1) {
            stepLabel.backgroundColor = [UIColor lightGrayColor];
            tipLabel.textColor = [UIColor lightGrayColor];
        } else {
            stepLabel.backgroundColor = kMainColor;
            tipLabel.textColor = kMainColor;
        }
    }
}

#pragma mark setter or getter

- (NSArray *)tipsArray {
    if (!_tipsArray) {
        _tipsArray = @[@"配置硬件", @"选择目标WiFi", @"开始配网"];
    }
    return _tipsArray;
}

@end
