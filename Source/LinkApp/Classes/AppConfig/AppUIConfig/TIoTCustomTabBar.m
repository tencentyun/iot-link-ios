//
//  TIoTCustomTabBar.m
//  LinkApp
//
//  Created by ccharlesren on 2021/2/18.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCustomTabBar.h"
#import "TIoTTabBarCenterCustomView.h"

#define kBottomSafeAreaSpace ([TIoTUIProxy shareUIProxy].iPhoneX ? [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom : 0.0)

@interface TIoTCustomTabBar ()
@property (nonatomic, strong) UIButton *centerButton;
@property (nonatomic, strong) UIImageView *centerImageView;
@property (nonatomic, strong) UIView *leftPlaceHoldView;
@property (nonatomic, strong) UIView *rightPlaceHoldView;
@property (nonatomic, assign) NSInteger kBottomSpace;
@property (nonatomic, strong) TIoTTabBarCenterCustomView *addDeviceView;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@end

@implementation TIoTCustomTabBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    CGFloat kBottomPaddind = 9+10+40;
    
    UIView *backView = [[UIView alloc]init];
    if (@available(iOS 11.0, *)) {
        self.kBottomSpace = kBottomSafeAreaSpace+kBottomPaddind;
    } else {
        // Fallback on earlier versions
        self.kBottomSpace = kBottomPaddind;
    }
    backView.frame = CGRectMake(0, -5, kScreenWidth, self.kBottomSpace);
    backView.backgroundColor = [UIColor whiteColor];
    
    [self insertSubview:backView atIndex:0];
    [self setBackgroundImage:[UIImage new]];
    [self setShadowImage:[UIImage new]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat tabBarButtonW = kScreenWidth / 5;
    CGFloat kBtnwidth = tabBarButtonW;
    CGFloat kTabBarButtonHeight = 49;
    self.centerButton.frame = CGRectMake((kScreenWidth-kBtnwidth)/2, -15, kBtnwidth, kTabBarButtonHeight);
    
    CGFloat tabBarButtonIndex = 0;
    for (UIView *child in self.subviews) {

        Class class = NSClassFromString(@"UITabBarButton");
        if ([child isKindOfClass:class]) {

            // 重新设置frame
            CGRect frame = CGRectMake(tabBarButtonIndex * tabBarButtonW, 0, tabBarButtonW, kTabBarButtonHeight);
            child.frame = frame;

            // 增加索引
            if (tabBarButtonIndex == 1) {
                tabBarButtonIndex++;
            }
            tabBarButtonIndex++;
        }
    }
    
    if (self.leftPlaceHoldView == nil &&  self.rightPlaceHoldView == nil) {
        self.leftPlaceHoldView = [[UIView alloc]initWithFrame:CGRectMake(0, -5, tabBarButtonW*2, self.kBottomSpace)];
        self.leftPlaceHoldView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.leftPlaceHoldView];
        self.rightPlaceHoldView = [[UIView alloc]initWithFrame:CGRectMake(tabBarButtonW*3, -5, tabBarButtonW*2, self.kBottomSpace)];
        self.rightPlaceHoldView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.rightPlaceHoldView];
        self.leftPlaceHoldView.hidden = YES;
        self.rightPlaceHoldView.hidden = YES;
    }
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    if (event.timestamp == self.timeInterval) {
        self.timeInterval = event.timestamp;
        
        if (self.leftPlaceHoldView.hidden){
            return [super hitTest:point withEvent:event];
        }else {
            //转换坐标
            CGPoint tempPoint = [self.centerButton convertPoint:point fromView:self];
            //判断点击的点是否在按钮区域内
            if (CGRectContainsPoint(self.centerButton.bounds, tempPoint)){
                //返回按钮
                return self.centerButton;
            }else {
                //判断是否在TabBar内
                CGPoint tempPoint = [self.addDeviceView convertPoint:point fromView:self];
                if (CGRectContainsPoint(self.addDeviceView.bounds, tempPoint)) {

                    CGPoint blackMaskPoint = [self.addDeviceView.blackMaskView convertPoint:point fromView:self];
                    
                    CGPoint addDevicePoint = [self.addDeviceView.addDevice convertPoint:point fromView:self];
                    CGPoint scanPoint = [self.addDeviceView.scanDevice convertPoint:point fromView:self];
                    CGPoint intelligentPoint = [self.addDeviceView.addIntelligentDevice convertPoint:point fromView:self];
                    //判断是否在背景遮罩内
                    if (CGRectContainsPoint(self.addDeviceView.blackMaskView.bounds, blackMaskPoint)) {
                        
                        //恢复TabBar
                        [self customTabBarCenterBtnEvent];
                        return self.addDeviceView.blackMaskView;
                        
                    }else {
                        
                        //判断是否在三个按钮范围内，响应按钮
                        if (CGRectContainsPoint(self.addDeviceView.addDevice.bounds, addDevicePoint)) {
                            
                            [self addDeviceEntrance];
                            return  self.addDeviceView.addDevice;
                            
                        }else if (CGRectContainsPoint(self.addDeviceView.scanDevice.bounds, scanPoint)){
                            
                            [self scanDeviceEntrance];
                            return  self.addDeviceView.scanDevice;
                            
                        }else if (CGRectContainsPoint(self.addDeviceView.addIntelligentDevice.bounds, intelligentPoint)) {
                            
                            [self addIntelliEntrance];
                            return  self.addDeviceView.addIntelligentDevice;
                            
                        }else {
                            return self.addDeviceView;
                        }
                        
                    }
                    
                }else {
                    return [super hitTest:point withEvent:event];
                }
            }
        }
    }else {
        self.timeInterval = event.timestamp;
        return [super hitTest:point withEvent:event];
    }
    
}

- (void)customTabBarCenterBtnEvent {
    
    CGAffineTransform imageTrans = self.centerImageView.transform;
    CGFloat rotateValue = acosf(imageTrans.a);
    if (imageTrans.b<0) {
        rotateValue = M_PI - rotateValue;
    }
    CGFloat degree = rotateValue/M_PI * 180;
    
    if (degree == 0 ) {
        [UIView animateWithDuration:0.2 animations:^{
            [self clickCenterTabBarAction];
            
            [self displayCustomView];
        }];
    }else if (degree<46 && degree>0){
        [UIView animateWithDuration:0.2 animations:^{
            [self resetTabBarAction];
            
            [self disappearCustomView];
        }];
        
    }
}

- (void)clickCenterTabBarAction {
    self.centerImageView.layer.transform = CATransform3DMakeRotation(M_PI / 4, 0.0, .0, 1.0);
    self.leftPlaceHoldView.hidden = NO;
    self.rightPlaceHoldView.hidden = NO;
}

- (void)resetTabBarAction {
    self.centerImageView.layer.transform = CATransform3DMakeRotation(0, 0.0, 0.0, 1.0);
    self.leftPlaceHoldView.hidden = YES;
    self.rightPlaceHoldView.hidden = YES;
}

- (void)displayCustomView {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    self.addDeviceView = [[TIoTTabBarCenterCustomView alloc]initWithFrame:CGRectMake(0, -(screenFrame.size.height-self.kBottomSpace+10), kScreenWidth, screenFrame.size.height)];
    [self addSubview:self.addDeviceView];
    [self insertSubview:self.addDeviceView atIndex:1];
}

- (void)disappearCustomView {
    [self.addDeviceView hideView];
}

- (void)resetTabBarStatusWithAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        [self resetTabBarAction];
    }];
}

- (void)addDeviceEntrance {
    [self customTabBarCenterBtnEvent];
    [self disappearCustomView];
    if (self.addDeviceBlock) {
        self.addDeviceBlock();
    }
}

- (void)scanDeviceEntrance {
    [self customTabBarCenterBtnEvent];
    [self disappearCustomView];
    if (self.scanDeviceBlock) {
        self.scanDeviceBlock();
    }
}

- (void)addIntelliEntrance {
    [self customTabBarCenterBtnEvent];
    if (self.intelliDeviceBlock) {
        self.intelliDeviceBlock();
    }
    
}

- (UIButton *)centerButton {
    
    if (!_centerButton) {
        _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_centerButton];
        CGFloat kImageWidthOrHeight = 60;
        CGFloat kImageLeftPadding = (kScreenWidth / 5 - kImageWidthOrHeight) * 0.5;
        self.centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(kImageLeftPadding, 0, kImageWidthOrHeight, kImageWidthOrHeight)];
        self.centerImageView.image = [UIImage imageNamed:@"addIntelligent_Device"];
        [_centerButton addSubview:self.centerImageView];
        _centerButton.adjustsImageWhenHighlighted = false;
        [_centerButton addTarget:self action:@selector(customTabBarCenterBtnEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _centerButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
