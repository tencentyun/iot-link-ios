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
@property (nonatomic, strong) UIButton *addConditionButton;
@property (nonatomic, strong) UIImageView *addConditionImage;
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
    
    CGFloat kPaddingWidth = 16; //距离左边距的宽度
    
    self.conditionTitleLabel = [[UILabel alloc]init];
    [self.conditionTitleLabel setLabelFormateTitle:@"" font:[UIFont wcPfMediumFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.conditionTitleLabel];
    [self.conditionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kPaddingWidth);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(22);
    }];
    
    self.choiceConditionImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"downArrow"]];
    [self.contentView addSubview:self.choiceConditionImage];
    [self.choiceConditionImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.conditionTitleLabel.mas_right).offset(10);
        make.height.width.mas_equalTo(20);
        make.centerY.equalTo(self.conditionTitleLabel.mas_centerY);
    }];
    
    self.addConditionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addConditionButton addTarget:self
                                action:@selector(addAutoItem) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.addConditionButton];
    [self.addConditionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    self.addConditionImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"addManual_Intelligent"]];
    [self.contentView addSubview:self.addConditionImage];
    [self.addConditionImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(22);
        make.centerY.equalTo(self.conditionTitleLabel.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-kPaddingWidth);
    }];
    
    UIButton *choiceConditionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [choiceConditionButton addTarget:self action:@selector(chooseCondition) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:choiceConditionButton];
    [choiceConditionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.addConditionButton.mas_left).offset(-10);
    }];
    
}

- (void)setConditionTitleString:(NSString *)conditionTitleString {
    _conditionTitleString = conditionTitleString;
    self.conditionTitleLabel.text = conditionTitleString;
}

- (void)chooseCondition {
    if (self.autoChooseConditionBlock) {
        self.autoChooseConditionBlock();
    }
}

- (void)setIsHideAddConditionButton:(BOOL)isHideAddConditionButton {
    _isHideAddConditionButton = isHideAddConditionButton;
    self.addConditionButton.hidden = isHideAddConditionButton;
    self.self.addConditionImage.hidden = isHideAddConditionButton;
}

- (void)setAutoIntelligentItemType:(AutoIntelligentItemType)autoIntelligentItemType {
    _autoIntelligentItemType = autoIntelligentItemType;
}

- (void)addAutoItem {
    if (self.autoIntelligentItemType == AutoIntelligentItemTypeConditoin) {
        if (self.autoInteAddConditionBlock) {
            self.autoInteAddConditionBlock();
        }
    }else if (self.autoIntelligentItemType == AutoIntelligentItemTypeAction) {
        if (self.autoInteAddTaskBlock) {
            self.autoInteAddTaskBlock();
        }
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
