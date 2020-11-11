//
//  TIoTAutoIntelligentSectionTitleCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/11.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoIntelligentSectionTitleCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTAutoIntelligentSectionTitleCell ()
@property (nonatomic, strong) UILabel *conditionTitleLabel;
@property (nonatomic, strong) UIButton *choiceConditionButton;
@property (nonatomic, strong) UIButton *addConditionButton;
@end

@implementation TIoTAutoIntelligentSectionTitleCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"kTIoTAutoIntelligentSectionTitleCellID";
    TIoTAutoIntelligentSectionTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTAutoIntelligentSectionTitleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUISunViews];
    }
    return self;
}

- (void)setupUISunViews {
    
    self.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat kPaddingWidth = 16;
    
    self.conditionTitleLabel = [[UILabel alloc]init];
    [self.conditionTitleLabel setLabelFormateTitle:@"" font:[UIFont wcPfMediumFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.conditionTitleLabel];
    [self.conditionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kPaddingWidth);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(22);
    }];
    
    self.choiceConditionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.choiceConditionButton setImage:[UIImage imageNamed:@"downArrow"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.choiceConditionButton];
    [self.choiceConditionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.conditionTitleLabel.mas_right).offset(10);
        make.height.width.mas_equalTo(20);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    self.addConditionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addConditionButton setImage:[UIImage imageNamed:@"addManual_Intelligent"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.addConditionButton];
    [self.addConditionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(22);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-kPaddingWidth);
    }];
    
}

- (void)setConditionTitleString:(NSString *)conditionTitleString {
    _conditionTitleString = conditionTitleString;
    self.conditionTitleLabel.text = conditionTitleString;
}

- (void)setIsHideChoiceConditionButton:(BOOL)isHideChoiceConditionButton {
    _isHideChoiceConditionButton = isHideChoiceConditionButton;
    self.choiceConditionButton.hidden = isHideChoiceConditionButton;
}

- (void)setIsHideAddConditionButton:(BOOL)isHideAddConditionButton {
    _isHideAddConditionButton = isHideAddConditionButton;
    self.addConditionButton.hidden = isHideAddConditionButton;
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
