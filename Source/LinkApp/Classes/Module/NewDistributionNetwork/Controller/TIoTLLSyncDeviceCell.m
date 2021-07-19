//
//  TIoTLLSyncDeviceCell.m
//  LinkApp
//
//  Created by eagleychen on 2021/7/20.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTLLSyncDeviceCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTLLSyncDeviceCell ()
@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, strong) UILabel *weekLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation TIoTLLSyncDeviceCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupItemUI];
    }
    return self;
}

- (void)setupItemUI {
//    self.contentView.backgroundColor = [UIColor yellowColor];
    
    UIView *maskView = [[UIView alloc] init];
    maskView.layer.cornerRadius = 40;
    maskView.layer.borderWidth = 0.5f;
    maskView.layer.borderColor = [UIColor colorWithHexString:COLOR_016EFF].CGColor;
    maskView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.height.width.height.mas_equalTo(80);
        make.top.equalTo(self.contentView.mas_top);
    }];
    
    UIView *maskView1 = [[UIView alloc] init];
    maskView1.layer.cornerRadius = 36;
//    maskView1.layer.borderWidth = 0.5f;
//    maskView1.layer.borderColor = [UIColor colorWithHexString:COLOR_016EFF].CGColor;
    maskView1.backgroundColor = [UIColor colorWithHexString:COLOR_F2F2F2];
    [maskView addSubview:maskView1];
    [maskView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(maskView);
        make.height.width.height.mas_equalTo(72);
    }];
    
    self.imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_config_scan"]];
    [self.imageV setContentMode:UIViewContentModeScaleAspectFit];
//    self.imageV.backgroundColor = [UIColor colorWithHexString:COLOR_F2F2F2];//kBackgroundHexColor
    [maskView addSubview:self.imageV];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(maskView).offset(15);
        make.bottom.right.equalTo(maskView).offset(-15);
    }];
    
    
    self.weekLabel = [[UILabel alloc]init];
    [self.weekLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:13] titleColorHexString:COLOR_A1A7B2 textAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.weekLabel];
    [self.weekLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
    }];
    
    self.detailLabel = [[UILabel alloc]init];
    [self.detailLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:15] titleColorHexString:COLOR_000000 textAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-20);
    }];
    
}

- (void)setItemString:(NSString *)itemString {
    _itemString = itemString?:@"";
    self.weekLabel.text = itemString?:@"";
    self.detailLabel.text = itemString?:@"";
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
//        self.weekLabel.layer.borderColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
//        self.weekLabel.textColor = [UIColor colorWithHexString:COLOR_A1A7B2];
    }else {
//        self.weekLabel.layer.borderColor = [UIColor colorWithHexString:@"#E7E8EB"].CGColor;
//        self.weekLabel.textColor = [UIColor colorWithHexString:COLOR_A1A7B2];
    }
}

- (void)setSelected:(BOOL)selected {
    if (selected == YES) {
//        self.weekLabel.layer.borderColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
//        self.weekLabel.textColor = [UIColor colorWithHexString:COLOR_A1A7B2];
    }else {
//        self.weekLabel.layer.borderColor = [UIColor colorWithHexString:@"#E7E8EB"].CGColor;
//        self.weekLabel.textColor = [UIColor colorWithHexString:COLOR_A1A7B2];
    }    
}

@end
