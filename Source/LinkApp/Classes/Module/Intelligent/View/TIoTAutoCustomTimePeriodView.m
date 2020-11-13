//
//  TIoTAutoCustomTimePeriodView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/15.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoCustomTimePeriodView.h"

@interface TIoTAutoCustomTimePeriodView ()
@property (nonatomic, strong) UIView *backMaskView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *topView;

@end

@implementation TIoTAutoCustomTimePeriodView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUISubview];
    }
    return self;
}

- (void)setupUISubview {
    
    
    self.backMaskView = [[UIView alloc]init];
    self.backMaskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [self addSubview:self.backMaskView];
    [self.backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
