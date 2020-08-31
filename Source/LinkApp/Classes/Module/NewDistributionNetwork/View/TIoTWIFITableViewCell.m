//
//  TIoTWIFITableViewCell.m
//  LinkApp
//
//  Created by Sun on 2020/7/29.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTWIFITableViewCell.h"

@interface TIoTWIFITableViewCell ()

@property (nonatomic, strong) UIImageView *selectedImageView;

@property (nonatomic, strong) UILabel *wifiNameLabel;
/// WIFI需要密码的图标
@property (nonatomic, strong) UIImageView *lockImageView;
/// WIFI强度的图标
@property (nonatomic, strong) UIImageView *strongImageView;

@end

@implementation TIoTWIFITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"TIoTWIFITableViewCell";
    TIoTWIFITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTWIFITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
                ];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.selectedImageView = [[UIImageView alloc] init];
    self.selectedImageView.image = [UIImage imageNamed:@"new_distri_selected"];
    self.selectedImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.selectedImageView];
    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(3.5);
        make.width.mas_equalTo(48.5);
    }];
    
    self.wifiNameLabel = [[UILabel alloc] init];
    self.wifiNameLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.9f];
    self.wifiNameLabel.font = [UIFont wcPfRegularFontOfSize:17];
    self.wifiNameLabel.text = @"tcloud1";
    [self.contentView addSubview:self.wifiNameLabel];
    [self.wifiNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.selectedImageView.mas_right);
        make.right.equalTo(self.contentView).offset(-100);
    }];
    
    self.strongImageView = [[UIImageView alloc] init];
    self.strongImageView.image = [UIImage imageNamed:@"new_distri_wifi"];
    self.strongImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.strongImageView];
    [self.strongImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.top.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-7.5);
        make.width.mas_equalTo(33.5);
    }];
    
    self.lockImageView = [[UIImageView alloc] init];
    self.lockImageView.image = [UIImage imageNamed:@"new_distri_lock"];
    self.lockImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.lockImageView];
    [self.lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.top.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-41);
        make.width.mas_equalTo(28);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:.0f alpha:0.1f];
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
}

@end
