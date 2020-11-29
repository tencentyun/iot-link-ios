//
//  TIoTAutoAddManualIntellListCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoAddManualIntellListCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTAutoAddManualIntellListCell ()
@property (nonatomic, strong) UILabel *manualName;
@property (nonatomic, strong) UIImageView *selectedTipImage;

@end

@implementation TIoTAutoAddManualIntellListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString * kTIoTAutoAddManualIntellListCellID = @"kTIoTAutoAddManualIntellListCellID";
    TIoTAutoAddManualIntellListCell *cell = [tableView dequeueReusableCellWithIdentifier:kTIoTAutoAddManualIntellListCellID];
    if (!cell) {
        cell = [[TIoTAutoAddManualIntellListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTIoTAutoAddManualIntellListCellID];
    }
    return cell;

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviewsUI];
    }
    return self;
}

- (void)setupSubviewsUI {
    
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat kPaddingLeft = 15;
    
    self.selectedTipImage = [[UIImageView alloc]init];
    self.selectedTipImage.image = [UIImage imageNamed:@""];
    [self.contentView addSubview:self.selectedTipImage];
    [self.selectedTipImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-kPaddingLeft);
        make.width.mas_equalTo(19);
        make.height.mas_equalTo(13);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    self.manualName = [[UILabel alloc]init];
    [self.manualName setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.manualName];
    [self.manualName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kPaddingLeft);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.selectedTipImage.mas_left).offset(-30);
    }];
}

- (void)setManualNameString:(NSString *)manualNameString {
    _manualNameString = manualNameString;
    self.manualName.text = manualNameString?:@"";
}

- (void)setIsChoosed:(BOOL)isChoosed {
    _isChoosed = isChoosed;
    if (isChoosed) {
        self.selectedTipImage.image = [UIImage imageNamed:@"click_tick"];
    }else {
        self.selectedTipImage.image = [UIImage imageNamed:@""];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    if (self.isEditType == YES) {
        if (selected) {
            self.selectedTipImage.image = [UIImage imageNamed:@"click_tick"];
        }else {
            self.selectedTipImage.image = [UIImage imageNamed:@""];
        }
    }
}

@end
