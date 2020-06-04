//
//  TrackView.m
//  SliderView
//
//  Created by Scott on 2018/4/11.
//  Copyright © 2018年 無解. All rights reserved.
//

#import "TrackView.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation TrackView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    self.layer.cornerRadius = rect.size.height/2;
    self.layer.masksToBounds = YES;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = rect;
    gradientLayer.startPoint = self.startPoint;
    gradientLayer.endPoint = self.endPoint;
    gradientLayer.colors = self.colors;
    [self.layer addSublayer:gradientLayer];
}

/*
 *** 设置起点
 */
- (CGPoint)startPoint{
    if (![NSValue valueWithCGPoint:_startPoint]) {
        _startPoint = CGPointMake(0, 0);
    }
    return _startPoint;
}

- (CGPoint)endPoint{
    if (![NSValue valueWithCGPoint:_endPoint]) {
        _endPoint = CGPointMake(0, 1);
    }
    return _endPoint;
}

- (NSArray *)colors{
    if (!_colors || _colors.count<2) {
        _colors = @[(__bridge id)[UIColor orangeColor].CGColor,(__bridge id)[UIColor purpleColor].CGColor];
    }
    return _colors;
}

@end
