//
//  TIoTShareDeviceMessageCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/12/7.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTShareDeviceMessageCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTShareDeviceMessageCell ()
@property (nonatomic, strong) UIImageView *avatarImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation TIoTShareDeviceMessageCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *kTIoTShareDeviceMessageCellID = @"kTIoTShareDeviceMessageCellID";
    TIoTShareDeviceMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kTIoTShareDeviceMessageCellID];
    if (!cell) {
        cell = [[TIoTShareDeviceMessageCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kTIoTShareDeviceMessageCellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUIViews];
    }
    return self;
}

- (void)setUIViews {
    
    CGFloat kAvatarHeightWidth = 51;
    CGFloat kLeftRightPadding = 16;
    CGFloat kTopBottomPadding = 4;
    
    self.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *backGroundView = [[UIView alloc]init];
    backGroundView.backgroundColor = [UIColor whiteColor];
    backGroundView.layer.cornerRadius = 8;
    [self.contentView addSubview:backGroundView];
    [backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kLeftRightPadding);
        make.right.equalTo(self.contentView.mas_right).offset(-kLeftRightPadding);
        make.top.equalTo(self.contentView.mas_top).offset(kTopBottomPadding);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-kTopBottomPadding);
    }];
    
    self.avatarImage = [[UIImageView alloc]init];
    self.avatarImage.image = [UIImage imageNamed:@"userDefalut"];
    self.avatarImage.layer.cornerRadius = kAvatarHeightWidth/2;
    [backGroundView addSubview:self.avatarImage];
    [self.avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backGroundView.mas_left).offset(13);
        make.centerY.equalTo(backGroundView.mas_centerY);
        make.width.height.mas_equalTo(kAvatarHeightWidth);
    }];
    
    self.nameLabel = [[UILabel alloc]init];
    [self.nameLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [backGroundView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImage.mas_right).offset(14);
        make.top.equalTo(self.avatarImage.mas_top);
    }];
    
    self.phoneLabel = [[UILabel alloc]init];
    [self.phoneLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#A1A7B2" textAlignment:NSTextAlignmentLeft];
    [backGroundView addSubview:self.phoneLabel];
    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(7);
        make.left.equalTo(self.nameLabel.mas_left);
        make.width.mas_equalTo(100);
    }];
    
    self.timeLabel = [[UILabel alloc]init];
    [self.timeLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#A1A7B2" textAlignment:NSTextAlignmentRight];
    [backGroundView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(backGroundView.mas_right).offset(-kLeftRightPadding);
        make.top.equalTo(self.phoneLabel.mas_top);
    }];
    
}

- (void)setInfo:(NSDictionary *)info {
    _info = info;
    [self.avatarImage setImageWithURLStr:info[@"Avatar"]?:@"" placeHolder:@"userDefalut"];
    self.phoneLabel.text = [NSString stringWithFormat:@"%@-%@",info[@"CountryCode"]?:@"",info[@"PhoneNumber"]?:@""];
    self.nameLabel.text = info[@"NickName"]?:@"";
    self.timeLabel.text = [NSString convertTimestampToTime:info[@"BindTime"]?:@"" byDateFormat:@"yyyy-MM-dd HH:mm"];
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
