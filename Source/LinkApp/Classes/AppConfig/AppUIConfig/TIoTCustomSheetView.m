//
//  TIoTCustomSheetView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTCustomSheetView.h"
#import "UIView+XDPExtension.h"
#import "UIButton+LQRelayout.h"

@interface TIoTCustomSheetView ()
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *actionBottomView;

@property (nonatomic, strong) UIView *contentView;       //
@property (nonatomic, strong) UIButton *deviceControlButton;
@property (nonatomic, strong) UIButton *delayButton;
@property (nonatomic, strong) UIButton *cancelButton;

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
    CGFloat kItemHeight = 50;
    CGFloat kActionBottonHeight = 175;
    if (@available(iOS 11.0, *))  {
        kActionBottonHeight = kActionBottonHeight + [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissView)];
//    [self addGestureRecognizer:tapGesture];

    
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
    
    [self.actionBottomView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.actionBottomView);
        make.bottom.mas_equalTo(kActionBottonHeight);
    }];
    
    [self.contentView addSubview:self.deviceControlButton];
    [self.deviceControlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    UIView *spliteView = [[UIView alloc]init];
    spliteView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.contentView addSubview:spliteView];
    [spliteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceControlButton.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    [self.contentView addSubview:self.delayButton];
    [self.delayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(spliteView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    [self.contentView addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.delayButton.mas_bottom).offset(kInterval);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(kItemHeight);
    }];
    
    UIView *placeHoldDownView = [[UIView alloc]init];
    placeHoldDownView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:placeHoldDownView];
    [placeHoldDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cancelButton.mas_bottom);
        make.left.right.bottom.equalTo(self.contentView);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.bottomView);
        make.bottom.equalTo(self.actionBottomView.mas_top);
    }];
}

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
}

- (void)addDeviceControl {
    if (self.chooseIntelligentFirstBlock) {
        self.chooseIntelligentFirstBlock();
    }
}

- (void)addDelayTask {
    if (self.chooseIntelligentSecondBlock) {
        self.chooseIntelligentSecondBlock();
    }
}

- (void)sheetViewTopTitleFirstTitle:(NSString *)firstString secondTitle:(NSString *)secondString {
    NSString *firstTitle = firstString ?:@"";
    NSString *secondTitle = secondString ?:@"";
    [self.deviceControlButton setTitle:firstTitle forState:UIControlStateNormal];
    [self.delayButton setTitle:secondTitle forState:UIControlStateNormal];
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

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    }
    return _contentView;
}

- (UIButton *)deviceControlButton {
    if (!_deviceControlButton) {
        _deviceControlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deviceControlButton setButtonFormateWithTitlt:@"" titleColorHexString:@"#15161A" font:[UIFont wcPfRegularFontOfSize:16]];
        [_deviceControlButton addTarget:self action:@selector(addDeviceControl) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deviceControlButton;
}

- (UIButton *)delayButton {
    if (!_delayButton) {
        _delayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delayButton setButtonFormateWithTitlt:@"" titleColorHexString:@"#15161A" font:[UIFont wcPfRegularFontOfSize:16]];
        [_delayButton addTarget:self action:@selector(addDelayTask) forControlEvents:UIControlEventTouchUpInside];
    }
    return _delayButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setButtonFormateWithTitlt:NSLocalizedString(@"cancel", @"取消") titleColorHexString:@"#15161A" font:[UIFont wcPfRegularFontOfSize:16]];
    }
    return _cancelButton;
}

//- (void)setButtonFormateWithButton:(UIButton *)button titlt:(NSString *)titlt titleColorHexString:(NSString *)titleColorString font:(UIFont *)font {
//    [button setBackgroundColor:[UIColor whiteColor]];
//    [button setTitle:titlt forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor colorWithHexString:titleColorString] forState:UIControlStateNormal];
//    button.titleLabel.font = font;
//}

@end
