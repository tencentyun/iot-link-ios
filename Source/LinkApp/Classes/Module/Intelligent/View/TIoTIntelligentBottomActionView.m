//
//  TIoTIntelligentBottomActionView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentBottomActionView.h"
#import "UIButton+LQRelayout.h"

@interface TIoTIntelligentBottomActionView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *bottomContentView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation TIoTIntelligentBottomActionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
    }];
    
    CGFloat kPadding = 15;
    CGFloat kBottomViewHeight = 56;
    
    [self.contentView addSubview:self.bottomContentView];
    [self.bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(kBottomViewHeight);
    }];
    
    
    [self.bottomContentView addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(8);
        make.left.equalTo(self.contentView).offset(kPadding);
        make.right.equalTo(self.contentView).offset(-kPadding);
        make.height.mas_equalTo(40);
    }];
    
    CGFloat kButtonWidth = 146;
    [self.bottomContentView addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kButtonWidth);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(self.bottomContentView);
        make.right.equalTo(self.bottomContentView.mas_left).offset(kScreenWidth/2-15);
    }];
    
    [self.bottomContentView addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kButtonWidth);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(self.bottomContentView);
        make.left.equalTo(self.bottomContentView.mas_left).offset(kScreenWidth/2+15);
    }];
    
    
}

#pragma mark - lazy loading

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIView *)bottomContentView {
    if (!_bottomContentView) {
        _bottomContentView = [[UIView alloc]init];
        _bottomContentView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomContentView;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setButtonFormateWithTitlt:NSLocalizedString(@"confirm", @"确定") titleColorHexString:@"ffffff" font:[UIFont wcPfRegularFontOfSize:16]];
        [_confirmButton addTarget:self action:@selector(chooseDelayTime) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.layer.cornerRadius = 20;
        [_confirmButton setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
    }
    return _confirmButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setButtonFormateWithTitlt:NSLocalizedString(@"cancel", @"取消") titleColorHexString:kIntelligentMainHexColor font:[UIFont wcPfRegularFontOfSize:16]];
        _cancelButton.layer.cornerRadius = 20;
        [_cancelButton addTarget:self action:@selector(cancelChoiceDelayTime) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setBackgroundColor:[UIColor colorWithHexString:@"#F3F3F5"]];
    }
    return _cancelButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setButtonFormateWithTitlt:NSLocalizedString(@"save", @"保存") titleColorHexString:@"ffffff" font:[UIFont wcPfRegularFontOfSize:16]];
        _saveButton.layer.cornerRadius = 20;
        [_saveButton addTarget:self action:@selector(saveChoiceDelayTime) forControlEvents:UIControlEventTouchUpInside];
        [_saveButton setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
    }
    return _saveButton;
}

#pragma mark - event
- (void)bottomViewType:(IntelligentBottomViewType)type withTitleArray:(NSArray *)titleArray {
    switch (type) {
        case IntelligentBottomViewTypeSingle:
        {
            NSString *titleString = titleArray.firstObject ? : NSLocalizedString(@"confirm", @"确定");
            [self.confirmButton setTitle:titleString forState:UIControlStateNormal];
            self.confirmButton.hidden = NO;
            self.cancelButton.hidden = YES;
            self.saveButton.hidden = YES;
            break;
        }
            
        case IntelligentBottomViewTypeDouble: {
            
            NSString *cancelTitle = titleArray.firstObject ?:NSLocalizedString(@"cancel", @"取消");
            NSString *saveTitle = titleArray[1] ?:NSLocalizedString(@"save", @"保存");
            [self.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
            [self.saveButton setTitle:saveTitle forState:UIControlStateNormal];
            self.confirmButton.hidden = YES;
            self.cancelButton.hidden = NO;
            self.saveButton.hidden = NO;
            break;
        }
        default:
            break;
    }
}

- (void)chooseDelayTime {
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}

- (void)cancelChoiceDelayTime {
    if (self.firstBlock) {
        self.firstBlock();
    }
}

- (void)saveChoiceDelayTime {
    if (self.secondBlock) {
        self.secondBlock();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
