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

static CGFloat kInterval = 7;
static CGFloat kItemHeight = 50;

@interface TIoTCustomSheetView ()
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *actionBottomView;

@property (nonatomic, strong) UIView *contentView;       //
@property (nonatomic, strong) UIButton *deviceControlButton;
@property (nonatomic, strong) UIButton *delayButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *placeHoldDownView; //贴底补齐白色view
@property (nonatomic, assign) CGFloat kActionBottonHeight;
@property (nonatomic, strong) NSArray *blcokArray;
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
    
    self.kActionBottonHeight = kInterval + kItemHeight * 3;
    if (@available(iOS 11.0, *))  {
        self.kActionBottonHeight = self.kActionBottonHeight + [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
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
        make.height.mas_equalTo(self.kActionBottonHeight);
    }];
    
    [self changeViewRectConnerWithView:self.actionBottomView withRect:CGRectMake(0, 0, kScreenWidth, self.kActionBottonHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    
    [self.actionBottomView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.actionBottomView);
        make.bottom.mas_equalTo(self.kActionBottonHeight);
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
    
    self.placeHoldDownView = [[UIView alloc]init];
    self.placeHoldDownView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.placeHoldDownView];
    [self.placeHoldDownView mas_makeConstraints:^(MASConstraintMaker *make) {
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

- (void)sheetViewTopTitleArray:(NSArray <NSString*>*)titleArray withMatchBlocks:(NSArray<ChooseFunctionBlock>*)blockArray {
    if (!titleArray) {
        return;
    }
    
    self.blcokArray = [NSArray arrayWithArray:blockArray];
    
    self.kActionBottonHeight = kInterval + (kItemHeight+1) * titleArray.count;
    if (@available(iOS 11.0, *))  {
        self.kActionBottonHeight = self.kActionBottonHeight + [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
    [self.actionBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.kActionBottonHeight);
    }];
    [self changeViewRectConnerWithView:self.actionBottomView withRect:CGRectMake(0, 0, kScreenWidth, self.kActionBottonHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.kActionBottonHeight);
    }];
    
    for (int i = 0; i<titleArray.count; i++) {
        
        NSString *titleString = @"";
        if (![NSString isNullOrNilWithObject:titleArray[i]]) {
            titleString = titleArray[i];
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setButtonFormateWithTitlt:titleString titleColorHexString:@"#15161A" font:[UIFont wcPfRegularFontOfSize:16]];
        button.tag = 100+i;
        [button addTarget:self action:@selector(clickFunction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == titleArray.count -1) {
                make.top.equalTo(self.contentView.mas_top).offset(i*(kItemHeight+1) + kInterval);
            }else {
                make.top.equalTo(self.contentView.mas_top).offset(i*(kItemHeight+1));
            }
            
            make.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(kItemHeight);
        }];
        
        
        UIView *spliteView = [[UIView alloc]init];
        spliteView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        [self.contentView addSubview:spliteView];
        [spliteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(button.mas_bottom);
            make.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
        
        if (i == titleArray.count-1) {
            if (self.delayButton) {
                self.delayButton.hidden = YES;
            }
            if (self.cancelButton) {
                self.cancelButton.hidden = YES;
            }
            if (self.placeHoldDownView) {
                self.placeHoldDownView.hidden = YES;
            }
            
            UIView *placeHoldDownView = [[UIView alloc]init];
            placeHoldDownView.backgroundColor = [UIColor whiteColor];
            [self.contentView addSubview:placeHoldDownView];
            [placeHoldDownView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(button.mas_bottom);
                make.left.right.bottom.equalTo(self.contentView);
            }];
        }
    }
    
}

- (void)clickFunction:(UIButton *)sender {
    NSInteger blockIndex = sender.tag -100;
    ChooseFunctionBlock responseBlock = self.blcokArray[blockIndex];
    if (responseBlock !=nil) {
        responseBlock(self);
    }
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
