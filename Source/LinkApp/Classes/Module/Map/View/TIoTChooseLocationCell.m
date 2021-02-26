//
//  TIoTChooseLocationCell.m
//  LinkApp
//
//  Created by ccharlesren on 2021/2/26.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTChooseLocationCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTChooseLocationCell ()
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *detailAddressLabel;
@property (nonatomic, strong) UILabel *rangeLabel;
@property (nonatomic, strong) UIImageView *choiceImageView;
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
    self.addressLabel = [[UILabel alloc]init];
    [self.addressLabel setLabelFormateTitle:self.cellString font:[UIFont systemFontOfSize:12] titleColorHexString:@"#15161A" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.addressLabel];
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.top.equalTo(self.contentView.mas_top).offset(36);
    }];
}

- (void)setCellString:(NSString *)cellString {
    _cellString = cellString;
    self.addressLabel.text = cellString;
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
