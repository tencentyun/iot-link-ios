//
//  TIoTCustomTimeSlider.m
//  LinkApp
//
//

#import "TIoTCustomTimeSlider.h"

@implementation TIoTTimeSetmentModel

@end

static NSInteger secondsNumber = 86400;  //24*60*60

@interface TIoTCustomTimeSlider ()
@property (nonatomic, assign) BOOL isInRectFrame;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *responseView;
@end

@implementation TIoTCustomTimeSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.padding = 15;
        self.backgroundColor = [UIColor orangeColor];
        [self addSubview:self.lineView];
        [self addSubview:self.imageView];
    }
    return self;
}


- (void)setTimeSegmentArray:(NSArray *)timeSegmentArray {
    _timeSegmentArray = timeSegmentArray;
    [self setNeedsLayout];
}

- (void)setCurrentValue:(CGFloat)currentValue {
    _currentValue = currentValue;
    [self setNeedsLayout];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.frame, point)) {
        self.isInRectFrame = YES;
        point.y = self.frame.size.height/2;
        if (point.x<self.padding) {
            point.x = self.padding;
        }
        if (point.x>self.frame.size.width-self.padding) {
            point.x = self.frame.size.width-self.padding;
        }
        self.imageView.center = point;
        self.currentValue = secondsNumber*(point.x-self.padding)/(self.frame.size.width-2*self.padding);
    } else {
        self.isInRectFrame = NO;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    point.y = self.frame.size.height/2;
    if (point.x<self.padding) {
        point.x = self.padding;
    }
    if (point.x>self.frame.size.width-self.padding) {
        point.x = self.frame.size.width-self.padding;
    }
    if (self.isInRectFrame) {
        self.imageView.center = point;
        self.currentValue = secondsNumber*(point.x-self.padding)/(self.frame.size.width-2*self.padding);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.lineView.frame = CGRectMake(self.padding, (self.frame.size.height-4)/2, self.frame.size.width-2*self.padding, 4);
    self.lineView.layer.cornerRadius = 2;
    //移除重新添加
    for (UIView *view in [self.lineView subviews]) {
        [view removeFromSuperview];
    }
    for (UIView *view in [self subviews]) {
        if ([view isEqual:self.imageView] || [view isEqual:self.lineView]) {
            continue;
        } else {
            [view removeFromSuperview];
        }
    }
    
    for (TIoTTimeSetmentModel *timeSegment in self.timeSegmentArray) {
        CGFloat x1 = timeSegment.startTime/secondsNumber*(self.frame.size.width-2*self.padding)+self.padding;
        CGFloat x2 = timeSegment.endTime/secondsNumber*(self.frame.size.width-2*self.padding)+self.padding;
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor blueColor];
        view.frame = CGRectMake(x1, self.lineView.frame.origin.y, x2-x1, 4);
        [self addSubview:view];
    }
    self.imageView.frame = CGRectMake(0, 0, 30, 30);
    self.imageView.layer.cornerRadius = 15;
    self.imageView.center = CGPointMake(self.currentValue/secondsNumber*(self.frame.size.width-2*self.padding)+self.padding, self.frame.size.height/2);
    [self bringSubviewToFront:self.imageView];
    
    self.responseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.responseView.backgroundColor = [UIColor clearColor];
    self.responseView.center = self.imageView.center;
    [self bringSubviewToFront:self.responseView];
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor whiteColor];
    }
    return _lineView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.backgroundColor = [UIColor whiteColor];
    }
    return _imageView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
