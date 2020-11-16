//
//  TIoTAutoConditionsView.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/15.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoConditionsView.h"
#import "UILabel+TIoTExtension.h"
#import "UIView+XDPExtension.h"

@interface TIoTAutoConditionsView ()
@property (nonatomic, strong) UIView *backMaskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *allConditionsButton;
@property (nonatomic, strong) UILabel *allConditionLabel;
@property (nonatomic, strong) UIImageView *allConditionImage;

@property (nonatomic, strong) UIButton *anyConditionButton;
@property (nonatomic, strong) UILabel *anyConditionLabel;
@property (nonatomic, strong) UIImageView *anyConditionImage;

@end

@implementation TIoTAutoConditionsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUISubviews];
    }
    return  self;
}

- (void)setupUISubviews {
    
    CGFloat KItemHeight = 40;
    CGFloat kHeight = KItemHeight * 2;
    CGFloat kPaddingWidth = 16;
    
    self.backMaskView = [[UIView alloc]init];
    self.backMaskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [self addSubview:self.backMaskView];
    [self.backMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.backMaskView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.backMaskView);
        make.height.mas_equalTo(kHeight);
    }];
    
    //MARK:所有条件
    self.allConditionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.allConditionsButton addTarget:self action:@selector(chooseConditionType:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.allConditionsButton];
    [self.allConditionsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(KItemHeight);
    }];
    
    self.allConditionLabel = [[UILabel alloc]init];
    [self.allConditionLabel setLabelFormateTitle:NSLocalizedString(@"autoIntelligent_meet_condition", @"满足以下所有条件") font:[UIFont wcPfMediumFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.allConditionsButton addSubview:self.allConditionLabel];
    [self.allConditionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.allConditionsButton.mas_left).offset(kPaddingWidth);
        make.top.equalTo(self.allConditionsButton.mas_top);
        make.height.mas_equalTo(KItemHeight);
        make.centerY.equalTo(self.allConditionsButton.mas_centerY);
    }];
    
    self.allConditionImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"procolSelect"]];
    [self.allConditionsButton addSubview:self.allConditionImage];
    [self.allConditionImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.allConditionsButton.mas_right).offset(-kPaddingWidth);
        make.height.width.mas_equalTo(22);
        make.centerY.equalTo(self.allConditionsButton);
    }];

    //MARK:任一条件
    self.anyConditionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.anyConditionButton addTarget:self action:@selector(chooseConditionType:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.anyConditionButton];
    [self.anyConditionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.allConditionsButton.mas_bottom);
        make.height.mas_equalTo(KItemHeight);
    }];
    
    self.anyConditionLabel = [[UILabel alloc]init];
    [self.anyConditionLabel setLabelFormateTitle:NSLocalizedString(@"auto_anyCondition", @"满足以下任一条件") font:[UIFont wcPfMediumFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.anyConditionButton addSubview:self.anyConditionLabel];
    [self.anyConditionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.anyConditionButton.mas_left).offset(kPaddingWidth);
        make.top.equalTo(self.anyConditionButton.mas_top);
        make.bottom.equalTo(self.anyConditionButton.mas_bottom);
        make.centerY.equalTo(self.anyConditionButton.mas_centerY);
    }];
    
    self.anyConditionImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"procolDefault"]];
    [self.anyConditionButton addSubview:self.anyConditionImage];
    [self.anyConditionImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.allConditionImage.mas_right);
        make.height.width.mas_equalTo(22);
        make.centerY.equalTo(self.anyConditionButton);
    }];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.backMaskView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView.mas_bottom);
        make.bottom.equalTo(self.backMaskView.mas_bottom);
    }];
    
}

#pragma mark - event
- (void)chooseConditionType:(UIButton *)button {
    if (button == self.allConditionsButton) {
        self.allConditionImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"procolSelect"]];
        self.anyConditionImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"procolDefault"]];
        
        if (self.chooseConditionBlock) {
            self.chooseConditionBlock(self.allConditionLabel.text);
        }
        [self dismissView];
    }else if (button == self.anyConditionButton) {
        self.allConditionImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"procolDefault"]];
        self.anyConditionImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"procolSelect"]];
        
        if (self.chooseConditionBlock) {
            self.chooseConditionBlock(self.self.anyConditionLabel.text);
        }
        [self dismissView];
    }
}

#pragma mark - lazy loading

- (void)dismissView {
    [self dismissSharedView];
}

- (void)dismissSharedView {
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
