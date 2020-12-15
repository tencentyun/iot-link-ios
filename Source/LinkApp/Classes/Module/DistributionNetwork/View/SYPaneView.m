//
//  SYPaneView.m
//  SYPanView
//
//  Created by Yunis on 2017/8/18.
//  Copyright © 2017年 Yunis. All rights reserved.
//

#import "SYPaneView.h"
#import <QuartzCore/QuartzCore.h>
@interface SYPaneView()
@property (nonatomic,strong) NSMutableArray <CAShapeLayer *>*layerViewsArray;/**<记录刻度视图*/
@property (nonatomic,strong) NSMutableArray <CAShapeLayer *>*layerHeightViewsArray;/**<记录高亮刻度视图*/
@property (nonatomic,strong) UILabel      *toTaskNumLabel;
@property (nonatomic,strong) UILabel      *desLabel;
@property (nonatomic,strong) NSTimer      *animationTimer;
@property (nonatomic       ) int          index;
@property (nonatomic,strong) CAShapeLayer *perLayer;

@end
@implementation SYPaneView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self assignDate];
        [self loadSubViews];
    }
    return self;
}
- (void)dealloc
{
    
}
#pragma mark - Intial Methods
//初始化数据
- (void)assignDate
{
    self.radius         = 92;
    self.index          = 0;
    self.startAngle     = -2.1*M_PI/4;
    self.endAngle       = M_PI * 1.48;
    self.scaleLineWidth = 10;
    self.scaleLineCount = 100;
    self.normalColor    = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    self.hightColor     = [UIColor whiteColor];
}

- (void)loadSubViews
{
    [self drawBaseView];
    [self addSubview:self.toTaskNumLabel];
    [self addSubview:self.desLabel];
}

#pragma mark - Public Method
//外部方法
- (void)faild{
    self.perLayer.strokeColor = kRGBColor(235, 61, 61).CGColor;
    self.toTaskNumLabel.textColor     = kRGBColor(235, 61, 61);
}

- (void)sucess{
    self.perLayer.strokeColor = self.hightColor.CGColor;
    self.toTaskNumLabel.textColor     = [UIColor colorWithHexString:kIntelligentMainHexColor];
    [self showHightColor];
}

#pragma mark - Private Method
- (void)drawBaseView
{
    [self drawBaseScaleWithStartAngle:self.startAngle
                             endAngle:self.endAngle
                       scaleLineWidth:self.scaleLineWidth
                       scaleLineCount:self.scaleLineCount];
}
- (void)drawBaseScaleWithStartAngle:(CGFloat)startAngle
                           endAngle:(CGFloat)endAngle
                     scaleLineWidth:(CGFloat)scaleLineWidth
                     scaleLineCount:(CGFloat)scaleLineCount
{
    CGRect rect = self.frame;
    CGPoint tmpcneter = self.center;
    CGPoint cneter = CGPointMake(tmpcneter.x, rect.origin.y + 40);
    CGFloat radius = self.radius;
    CGFloat perAngle = (endAngle - startAngle)/scaleLineCount;
    UIColor *strokeColor = self.normalColor;
    //绘制最外围刻度列表
    for (NSInteger i = 0; i< scaleLineCount; i++) {
        CGFloat startAngel = (startAngle+ perAngle * i);
        CGFloat endAngel   = startAngel + perAngle/5;
        UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:cneter radius:radius startAngle:startAngel endAngle:endAngel clockwise:YES];
        CAShapeLayer *perLayer = [CAShapeLayer layer];
        perLayer.strokeColor = strokeColor.CGColor;;
        perLayer.allowsEdgeAntialiasing=YES;
        perLayer.contentsScale = [UIScreen mainScreen].scale;
        perLayer.lineWidth   = scaleLineWidth;
        perLayer.path = tickPath.CGPath;
        [self.layer addSublayer:perLayer];
        [self.layerViewsArray addObject:perLayer];
    }
    //绘制内圈原
    UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:cneter radius:radius - 20 startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.perLayer = [CAShapeLayer layer];
    self.perLayer.strokeColor = strokeColor.CGColor;
    self.perLayer.fillColor = [UIColor clearColor].CGColor;
    self.perLayer.allowsEdgeAntialiasing=YES;
    self.perLayer.contentsScale = [UIScreen mainScreen].scale;
    self.perLayer.lineWidth   = 10;
    self.perLayer.path = tickPath.CGPath;
    [self.layer addSublayer:self.perLayer];
}

-(void)showHightColor:(NSTimer *)time{
    if (self.todoTask == 0 || self.allTaskCount == 0) {
        [self resetDate];
        return;
    }
//    float percentage = (self.todoTask * 1.0)/self.allTaskCount;
//    if (percentage > 1) {
//        percentage = 1;
//    }
//    int count =(int)(self.layerViewsArray.count * percentage);
//    if (self.index >= count) {
//        [self resetDate];
//        return;
//    }
    
    if (self.index < self.layerViewsArray.count)
    {
        CAShapeLayer *perLayer = self.layerViewsArray[self.index];
        perLayer.strokeColor = self.hightColor.CGColor;;
        [self.layerHeightViewsArray addObject:perLayer];
    }
    self.index++;
}

- (void)resetDate {
    self.index = 0;
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}
#pragma mark - Delegate
//代理方法
- (void)showNormalColor{
    [self.layerHeightViewsArray enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull perLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        perLayer.strokeColor = self.normalColor.CGColor;;
    }];
    [self.layerHeightViewsArray removeAllObjects];
}

- (void)showHightColor{
    [self.layerViewsArray enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull perLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        perLayer.strokeColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;;
    }];
}

#pragma mark - Lazy Loads
//懒加载 Getter方法
- (NSMutableArray <CAShapeLayer *>*)layerViewsArray{
    if (_layerViewsArray == nil) {
        _layerViewsArray = ({
            NSMutableArray <CAShapeLayer *>*marray = [NSMutableArray new];
            marray;
        });
    }
    return _layerViewsArray;
}

- (NSMutableArray <CAShapeLayer *>*)layerHeightViewsArray{
    if (_layerHeightViewsArray == nil) {
        _layerHeightViewsArray = ({
            NSMutableArray <CAShapeLayer *>*marray = [NSMutableArray new];
            marray;
        });
    }
    return _layerHeightViewsArray;
}

- (UILabel *)toTaskNumLabel{
    if (_toTaskNumLabel == nil) {
        _toTaskNumLabel = ({
            UILabel *speedLabel      = [[UILabel alloc] initWithFrame:(CGRect){self.center.x - 40, self.frame.origin.y, 80, 80}];
            //speedLabel.center        = self.center;
            speedLabel.font          = [UIFont boldSystemFontOfSize:30.0f];
            speedLabel.textAlignment = NSTextAlignmentCenter;
            speedLabel.textColor     = [UIColor colorWithHexString:kIntelligentMainHexColor];
            speedLabel.text          = @"0";
            speedLabel;
        });
    }
    
    return _toTaskNumLabel;
}

- (UILabel *)desLabel{
    if (_desLabel == nil) {
        _desLabel = ({
            UILabel * label                 = [[UILabel alloc]initWithFrame:CGRectMake(self.center.x- 60,self.center.y + 15, 120, 30)];
            label.text                      = @"";
            label.font                      = [UIFont systemFontOfSize:14];
            label.textAlignment             = NSTextAlignmentCenter;
            label.textColor                 = [UIColor whiteColor];
            label.adjustsFontSizeToFitWidth = YES;
            label;
        });
    }
    
    return _desLabel;
}

- (NSTimer *)animationTimer{
    if (_animationTimer == nil) {
        _animationTimer = ({
            NSTimer *animationTimer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(showHightColor:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];
            animationTimer;
        });
    }
    
    return _animationTimer;
}
#pragma mark - set
//Setter方法
- (void)setTodoTask:(NSInteger)todoTask
{
    if (_todoTask != todoTask) {

        _todoTask = todoTask;
        self.toTaskNumLabel.text = [NSString stringWithFormat:@"%ld%%",(long)_todoTask];
        if (_todoTask != 0) {
            [self showHightColor:nil];
            //[self.animationTimer fire];
        }
        else{
            [self showNormalColor];
        }
    }
}
@end
