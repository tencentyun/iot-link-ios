//
//  TIoTChoseFamilyCell.m
//  TIoTLinkKit
//
//  Created by ccharlesren on 2020/12/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTChoseFamilyCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTChoseFamilyCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *chooiceImage;
@end

@implementation TIoTChoseFamilyCell

+ (instancetype)cellForTableView:(UITableView *)tableView {
    static NSString *const kTIoTChoseFamilyCellID = @"TIoTChoseFamilyCell";
    TIoTChoseFamilyCell *cell = [tableView dequeueReusableCellWithIdentifier:kTIoTChoseFamilyCellID];
    if (!cell) {
        cell = [[TIoTChoseFamilyCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kTIoTChoseFamilyCellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat kLeftRightPadding = 16;
    
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 8;
    [self.contentView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kLeftRightPadding);
        make.right.equalTo(self.contentView.mas_right).offset(-kLeftRightPadding);
        make.top.equalTo(self.contentView.mas_top).offset(4);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-4);
    }];
    
    self.chooiceImage = [[UIImageView alloc]init];
    self.chooiceImage.image = [UIImage imageNamed:@"single_unseleccted"];
    [backView addSubview:self.chooiceImage];
    [self.chooiceImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.right.equalTo(backView.mas_right).offset(-kLeftRightPadding);
        make.centerY.equalTo(backView.mas_centerY);
    }];
    
    self.titleLabel = [[UILabel alloc]init];
    [self.titleLabel setLabelFormateTitle:@"sss" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [backView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView.mas_left).offset(kLeftRightPadding);
        make.right.equalTo(self.chooiceImage.mas_left).offset(-10);
        make.centerY.equalTo(self.chooiceImage.mas_centerY);
    }];
}

- (void)setModel:(FamilyModel *)model {
    _model = model;
    self.titleLabel.text = model.FamilyName;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.chooiceImage.image = [UIImage imageNamed:@"single_seleccted"];
    }else {
        self.chooiceImage.image = [UIImage imageNamed:@"single_unseleccted"];
    }
    // Configure the view for the selected state
}

@end
