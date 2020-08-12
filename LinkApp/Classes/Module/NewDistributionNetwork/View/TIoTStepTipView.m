//
//  TIoTStepTipView.m
//  LinkApp
//
//  Created by Sun on 2020/7/28.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTStepTipView.h"

@interface TIoTStepTipView()

@property (nonatomic, strong) NSArray *titlesArray;

@end

@implementation TIoTStepTipView

- (instancetype)initWithTitlesArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _titlesArray = array;
        _showAnimate = YES;
    }
    return self;
}

- (void)setupUI{
    for (int i = 0; i < _titlesArray.count; i++) {
        CGFloat kSelfWidth = kScreenWidth;
        
        CGFloat edgeSpace = 30.0f;
        CGFloat stepLabelWidth = 24.0f;
        CGFloat viewWidth = (kSelfWidth - 2*edgeSpace - _titlesArray.count*stepLabelWidth)/(_titlesArray.count - 1.0f);
        CGFloat viewHeight = 4.0f;
        
        UILabel *stepLabel = [[UILabel alloc] init];
        stepLabel.frame = CGRectMake(edgeSpace + (stepLabelWidth + viewWidth)*i, 0, stepLabelWidth, stepLabelWidth);
        stepLabel.text = [NSString stringWithFormat:@"%d", i+1];
        stepLabel.font = [UIFont wcPfMediumFontOfSize:12];
        stepLabel.textColor = [UIColor whiteColor];
        stepLabel.textAlignment = NSTextAlignmentCenter;
        stepLabel.layer.masksToBounds = YES;
        stepLabel.layer.cornerRadius = stepLabelWidth*0.5f;
        [self addSubview:stepLabel];
        
        if (_titlesArray.count != i+1) {
            UIView *view = [[UIView alloc] init];
            view.frame = CGRectMake(CGRectGetMaxX(stepLabel.frame), (stepLabelWidth - viewHeight)*0.5, viewWidth, viewHeight);
            [self addSubview:view];
            if (self.step < i+1) {
                view.backgroundColor = kRGBColor(219, 219, 219);
            } else if (self.step == i + 1) {
                view.backgroundColor = kRGBColor(219, 219, 219);
                
                if (_showAnimate) {
                    CAShapeLayer *layer = [CAShapeLayer layer];
                    layer.fillColor = kMainColor.CGColor;
                    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, view.frame.size.width*0.5, view.frame.size.height)];
                    layer.path = path.CGPath;
                    [view.layer addSublayer:layer];
                    
                    CABasicAnimation *pathAnima = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
                    pathAnima.duration = 2.0f;
                    pathAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    pathAnima.fromValue = [NSNumber numberWithFloat:0.0f];
                    pathAnima.toValue = [NSNumber numberWithFloat:1.0f];
                    pathAnima.fillMode = kCAFillModeForwards;
                    pathAnima.removedOnCompletion = NO;
                    [layer addAnimation:pathAnima forKey:@"strokeEndAnimation"];
                }

            } else {
                view.backgroundColor = kMainColor;
            }
        }
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.bounds = CGRectMake(0, 0, stepLabelWidth, stepLabelWidth);
        tipLabel.text = _titlesArray[i];
        tipLabel.font = [UIFont wcPfRegularFontOfSize:12];
        [tipLabel sizeToFit];
        tipLabel.center = CGPointMake(stepLabel.center.x, CGRectGetMaxY(stepLabel.frame) + 18.0f);
        [self addSubview:tipLabel];
        
        if (self.step < i+1) {
            stepLabel.backgroundColor = kRGBColor(219, 219, 219);
            tipLabel.textColor = kRGBColor(136, 136, 136);
        } else {
            stepLabel.backgroundColor = kMainColor;
            tipLabel.textColor = kMainColor;
        }
    }
}

#pragma mark setter or getter

- (void)setStep:(NSInteger)step {
    _step = step;
    [self setupUI];
}

@end
