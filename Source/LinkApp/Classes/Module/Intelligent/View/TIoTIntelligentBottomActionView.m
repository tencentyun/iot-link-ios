//
//  TIoTIntelligentBottomActionView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentBottomActionView.h"

@interface TIoTIntelligentBottomActionView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *confirmButton;

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
    [self.contentView addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.left.equalTo(self.contentView).offset(kPadding);
        make.right.equalTo(self.contentView).offset(-kPadding);
        make.height.mas_equalTo(40);
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

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:NSLocalizedString(@"confirm", @"确定") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [_confirmButton addTarget:self action:@selector(chooseDelayTime) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.layer.cornerRadius = 20;
        [_confirmButton setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
    }
    return _confirmButton;
}


#pragma mark - event
- (void)bottomViewType:(IntellignetBottomViewType)type withTitleArray:(NSArray *)titleArray {
    switch (type) {
        case IntellignetBottomViewTypeSingle:
        {
            NSString *titleString = titleArray.firstObject ? : NSLocalizedString(@"confirm", @"确定");
            [self.confirmButton setTitle:titleString forState:UIControlStateNormal];
            break;
        }
            
        case IntellignetBottomViewTypeDouble: {
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
