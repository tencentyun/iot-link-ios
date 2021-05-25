//
//  TIoTDemoDeviceHeaderView.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/25.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoDeviceHeaderView.h"

@interface TIoTDemoDeviceHeaderView ()
@property (nonatomic, strong) UILabel *headerTitle;
@property (nonatomic, strong) UIButton *editBtn; //编辑按钮
@property (nonatomic, strong) UIImageView *editImage; //编辑图标
@end

@implementation TIoTDemoDeviceHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupHeaderViews];
    }
    return self;
}

- (void)setupHeaderViews {
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat kWidthPadding = 16;
    
    self.headerTitle = [[UILabel alloc]init];
    [self.headerTitle setLabelFormateTitle:@"我的设备" font:[UIFont wcPfRegularFontOfSize:18] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self addSubview:_headerTitle];
    [self.headerTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kWidthPadding);
        make.centerY.equalTo(self);
    }];
    
    self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editBtn addTarget:self action:@selector(editDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.editBtn setButtonFormateWithTitlt:@"编辑" titleColorHexString:@"#0066FF" font:[UIFont wcPfRegularFontOfSize:15]];
    [self addSubview:self.editBtn];
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-kWidthPadding);
        make.centerY.equalTo(self);
    }];
    
    CGFloat kImageWidthHeight = 24;
    self.editImage = [[UIImageView alloc]init];
    self.editImage.image = [UIImage imageNamed:@"edit_image"];
    [self addSubview:self.editImage];
    [self.editImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.editBtn.mas_left).offset(-3);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(kImageWidthHeight);
    }];
}

- (void)editDevice:(UIButton *)button {
    
    if (!button.selected) {
        [self.editBtn setTitle:@"完成" forState:UIControlStateNormal];
        self.editImage.hidden = YES;
    }else {
        [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        self.editImage.hidden = NO;
    }
    button.selected = !button.selected;
    
    if (self.editBlock) {
        self.editBlock();
    }
}
@end
