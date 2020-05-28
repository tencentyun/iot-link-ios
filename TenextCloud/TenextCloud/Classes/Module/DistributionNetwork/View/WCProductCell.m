//
//  WCProductCell.m
//  TenextCloud
//
//  Created by Sun on 2020/5/27.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCProductCell.h"

@interface WCProductCell ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation WCProductCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    
    self.imgView = [[UIImageView alloc] init];
    self.imgView.backgroundColor = [UIColor redColor];
    [self addSubview:_imgView];
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(65 * kScreenAllWidthScale);
        make.top.centerX.equalTo(self.contentView);
    }];
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.font = [UIFont wcPfRegularFontOfSize:12];
    self.titleLab.textColor = kRGBColor(68, 68, 68);
    self.titleLab.numberOfLines = 0;
    self.titleLab.text = @"客厅灯泡\n(其他）";
    [self.contentView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView.mas_bottom).offset(6.5);
        make.centerX.equalTo(self.contentView);
    }];
}

@end
