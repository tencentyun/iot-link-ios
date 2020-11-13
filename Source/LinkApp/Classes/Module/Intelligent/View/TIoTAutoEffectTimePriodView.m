//
//  TIoTAutoEffectTimePriodView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/13.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoEffectTimePriodView.h"

@interface TIoTAutoEffectTimePriodView ()
@property (nonatomic, strong) UIView *backMaskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation TIoTAutoEffectTimePriodView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViewsUI];
    }
    return self;
}

- (void)setupSubViewsUI {
    self.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    self.backMaskView = [[UIView alloc]init];
    [self addSubview:self.backMaskView];
    [self.backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            
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
