//
//  TIoTCustomSheetView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTCustomSheetView.h"
#import "UIView+XDPExtension.h"

@interface TIoTCustomSheetView ()
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *actionBottomView;
@property (nonatomic, strong) UIView *upperPartContentView;
@property (nonatomic, strong) UIView *lowerPartContentView;
@end

@implementation TIoTCustomSheetView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    
    CGFloat kInterval = 15;
    CGFloat kHeightWidth = 50;
    CGFloat kActionBottonHeight = 175;
    if (@available(iOS 11.0, *))  {
        kActionBottonHeight = kActionBottonHeight + [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissView)];
    [self addGestureRecognizer:tapGesture];

    
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.right.bottom.equalTo(self);
    }];
    
    [self.bottomView addSubview:self.actionBottomView];
    [self.actionBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.left.equalTo(self);
        make.height.mas_equalTo(kActionBottonHeight);
    }];
    
    [self changeViewRectConnerWithView:self.actionBottomView withRect:CGRectMake(0, 0, kScreenWidth, kActionBottonHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    
}

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
}

#pragma mark - lazy load
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _bottomView;
}

- (UIView *)actionBottomView {
    if (!_actionBottomView) {
        _actionBottomView = [[UIView alloc]init];
        _actionBottomView.backgroundColor = [UIColor whiteColor];
    }
    return _actionBottomView;
}

- (UIView *)upperPartContentView {
    if (!_upperPartContentView) {
        _upperPartContentView = [[UIView alloc]init];
        _upperPartContentView.backgroundColor = [UIColor whiteColor];
    }
    return _upperPartContentView;
}

- (UIView *)lowerPartContentView {
    if (!_lowerPartContentView) {
        _lowerPartContentView = [[UIView alloc]init];
        _lowerPartContentView.backgroundColor = [UIColor whiteColor];
    }
    return _lowerPartContentView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
