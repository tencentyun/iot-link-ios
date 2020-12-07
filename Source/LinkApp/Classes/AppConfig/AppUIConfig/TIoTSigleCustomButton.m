//
//  TIoTSigleCustomButton.m
//  LinkApp
//
//  Created by ccharlesren on 2020/12/7.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTSigleCustomButton.h"
#import "UIButton+LQRelayout.h"

@interface TIoTSigleCustomButton ()
@property (nonatomic, strong) UIButton *singleButton;
@end

@implementation TIoTSigleCustomButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUIVies];
    }
    return self;
}

- (void)setUIVies {
    
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat kPadding = 15;
    
    self.singleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.singleButton.layer.cornerRadius = 20;
    [self.singleButton addTarget:self action:@selector(clickButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.singleButton];
    [self.singleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kPadding);
        make.top.bottom.equalTo(self);
        make.right.equalTo(self.mas_right).offset(-kPadding);
    }];
}

- (void)singleCustomButtonStyle:(SingleCustomButton)type withTitle:(NSString *)title {
    switch (type) {
        case SingleCustomButtonConfirm: {
            [self.singleButton setButtonFormateWithTitlt:title?:@"" titleColorHexString:@"ffffff" font:[UIFont wcPfRegularFontOfSize:16]];
            [self.singleButton setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
            break;
        }
        case SingleCustomButtonCenale: {
            [self.singleButton setBackgroundColor:[UIColor whiteColor]];
            [self.singleButton setButtonFormateWithTitlt:title?:@"" titleColorHexString:@"#E54545" font:[UIFont wcPfRegularFontOfSize:16]];
            break;
        }
        default:
            break;
    }
}

- (void)setKLeftRightPadding:(CGFloat)kLeftRightPadding {
    _kLeftRightPadding = kLeftRightPadding;
    [self.singleButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-kLeftRightPadding);
        make.left.equalTo(self.mas_left).offset(kLeftRightPadding);
    }];
}

- (void)clickButtonAction {
    if (self.singleAction) {
        self.singleAction();
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
