//
//  TIoTDemoVideoDeviceCell.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/25.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoVideoDeviceCell.h"

@interface TIoTDemoVideoDeviceCell ()
@property (nonatomic, strong) UIImageView *deviceIcon;
@property (nonatomic, strong) UIButton *moreFuncBtn;
@property (nonatomic, strong) UILabel *deviceNameLabel;
@property (nonatomic, strong) UILabel *onlineTipLabel;
@end

@implementation TIoTDemoVideoDeviceCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCellView];
    }
    return self;
}

- (void)setupCellView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 8;
    
    CGFloat kPadding = 16;
    CGFloat kIconSize = 58;
    CGFloat kMoreFuncBtnSize = 24;
    
    self.deviceIcon = [[UIImageView alloc]init];
    self.deviceIcon.image = [UIImage imageNamed:@"camera_shooting"];
    [self.contentView addSubview:self.deviceIcon];
    [self.deviceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.top.equalTo(self.contentView.mas_top).offset(kPadding);
        make.width.height.mas_equalTo(kIconSize);
    }];

    self.moreFuncBtn = [[UIButton alloc]init];
    [self.moreFuncBtn setImage:[UIImage imageNamed:@"more_function"] forState:UIControlStateNormal];
    [self.moreFuncBtn addTarget:self action:@selector(showMoreFunction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.moreFuncBtn];
    [self.moreFuncBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-kPadding);
        make.top.equalTo(self.contentView.mas_top).offset(20);
        make.width.height.mas_equalTo(kMoreFuncBtnSize);
    }];
    
    self.deviceNameLabel = [[UILabel alloc]init];
    [self.deviceNameLabel setLabelFormateTitle:@"XXXX" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.deviceNameLabel];
    [self.deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kPadding);
        make.top.equalTo(self.deviceIcon.mas_bottom).offset(11);
        make.right.equalTo(self.contentView.mas_right).offset(-kPadding);
    }];
    
    self.onlineTipLabel = [[UILabel alloc]init];
    [self.onlineTipLabel setLabelFormateTitle:@"在线" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#29CC85" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.onlineTipLabel];
    [self.onlineTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceNameLabel.mas_bottom).offset(5);
        make.left.equalTo(self.deviceNameLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right).offset(-kPadding);
    }];
}

- (void)showMoreFunction {
    
}
@end
