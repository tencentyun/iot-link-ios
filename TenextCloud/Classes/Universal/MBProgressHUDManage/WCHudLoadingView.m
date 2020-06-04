//
//  XDPHudLoadingView.m
//  SEEXiaodianpu
//
//  Created by houxingyu on 2019/2/21.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import "WCHudLoadingView.h"

@interface WCHudLoadingView ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
//@property (nonatomic, strong) UIImageView *loadingImageView;
//@property (nonatomic, assign) NSInteger angle;
@property (nonatomic, assign) BOOL isAnimationg;

@end

@implementation WCHudLoadingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 40, 40)];
    if (self) {
//        self.angle = 0;
//        self.loadingImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"loading"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//        [self addSubview:self.loadingImageView];
//        self.isStart = YES;
//        [self startAnimation];
        [self setUpUI];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(40, 40);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat height = width;
    self.shapeLayer.frame = CGRectMake(0, 0, width, height);

    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - self.shapeLayer.lineWidth / 2;
    CGFloat startAngle = (CGFloat)(0);
    CGFloat endAngle = (CGFloat)(2*M_PI);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.shapeLayer.path = path.CGPath;
}

- (void)dealloc{
    [self stopAnimation];
}

- (void)setUpUI{
    [self.layer addSublayer:self.shapeLayer];
    
    if (self.isAnimationg) return;
    self.isAnimationg = YES;
    CABasicAnimation *rotationAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnim.toValue = [NSNumber numberWithFloat:2 * M_PI];
    rotationAnim.duration = 1;
    rotationAnim.repeatCount = CGFLOAT_MAX;
    rotationAnim.removedOnCompletion = NO;
    [self.shapeLayer addAnimation:rotationAnim forKey:@"rotation"];
}

//- (void)startAnimation
//{
//    CGAffineTransform endAngle = CGAffineTransformMakeRotation(self.angle * (M_PI /180.0f));
//    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//        self.loadingImageView.transform = endAngle;
//    } completion:^(BOOL finished) {
//        self.angle += 6;
//        if (self.isStart) {
//            [self startAnimation];
//        }
//
//    }];
//}
//
- (void)stopAnimation{
    if (!self.isAnimationg) return;
    self.isAnimationg = NO;
    [self.shapeLayer removeAllAnimations];
}


- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.strokeStart = 0.1;
        _shapeLayer.strokeEnd = 1;
        _shapeLayer.lineCap = @"round";
        _shapeLayer.lineWidth = 2;
        _shapeLayer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    return _shapeLayer;
}


@end
