//
//  TIoTChooseLocationCell.m
//  LinkApp
//
//  Created by ccharlesren on 2021/2/26.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTChooseLocationCell.h"
#import "UILabel+TIoTExtension.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTChooseLocationCell ()
@property (nonatomic, strong) UIImageView *locationIcon;
@property (nonatomic, strong) UILabel *addressTitleLabel;
@property (nonatomic, strong) UILabel *addressDetailLabel;
@property (nonatomic, strong) UIImageView *choiceIcon;

@end

@implementation TIoTChooseLocationCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *const cellID = @"ChooseLocationCellID";
    TIoTChooseLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[TIoTChooseLocationCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    CGFloat kWidthPadding = 16;
    CGFloat kImageWidthOrHeight = 18;
    self.locationIcon = [[UIImageView alloc]init];
    self.locationIcon.image = [UIImage imageNamed:@"location_icon"];
    [self.contentView addSubview:self.locationIcon];
    [self.locationIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kWidthPadding);
        make.top.equalTo(self.contentView.mas_top).offset(14);
        make.height.width.mas_equalTo(kImageWidthOrHeight);
    }];
    
    self.choiceIcon = [[UIImageView alloc]init];
    self.choiceIcon.image = [UIImage imageNamed:@""];
    [self.contentView addSubview:self.choiceIcon];
    [self.choiceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-kWidthPadding);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(22);
    }];
    
    self.addressTitleLabel = [[UILabel alloc]init];
    [self.addressTitleLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.addressTitleLabel];
    [self.addressTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.locationIcon.mas_right).offset(12);
        make.centerY.equalTo(self.locationIcon);
        make.right.equalTo(self.choiceIcon.mas_left).offset(-kWidthPadding);
    }];
    
    self.addressDetailLabel = [[UILabel alloc]init];
    [self.addressDetailLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#6C7078" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.addressDetailLabel];
    [self.addressDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addressTitleLabel.mas_bottom).offset(6);
        make.left.equalTo(self.addressTitleLabel.mas_left);
        make.right.equalTo(self.choiceIcon.mas_left).offset(-kWidthPadding);
    }];
    
}

- (void)setLocationModel:(TIoTPoisModel *)locationModel {
    _locationModel = locationModel;
    self.addressTitleLabel.text = locationModel.title;
    self.addressDetailLabel.text =  [NSString stringWithFormat:@"%@%@%@%@",locationModel.ad_info.province,locationModel.ad_info.city,locationModel.ad_info.district,locationModel.address];
}

- (void)setIsChoosed:(BOOL)isChoosed {
    _isChoosed = isChoosed;
    if (isChoosed) {
        self.choiceIcon.image = [UIImage imageNamed:@"choose_icon"];
    }else {
        self.choiceIcon.image = [UIImage imageNamed:@""];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
