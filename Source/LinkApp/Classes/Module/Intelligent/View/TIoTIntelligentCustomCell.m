//
//  TIoTIntelligentCustomCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentCustomCell.h"

@interface TIoTIntelligentCustomCell ()
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *taskTipImageView;
@property (nonatomic, strong) UILabel   *taskTitleLabel;
@property (nonatomic, strong) UILabel   *taskSubtitleLabel;
@property (nonatomic, strong) UIImageView *arrowsImageView;
@property (nonatomic, strong) UIImageView *taskDeleteImageView;

@end

@implementation TIoTIntelligentCustomCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"TIoTIntelligentCustomTableViewCellID";
    TIoTIntelligentCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTIntelligentCustomCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
                ];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview {
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat kIntervalHeight = 8;
    CGFloat kPaddingWidth = 16;
    CGFloat kTaskImageWidthHeight = 48;
    CGFloat kSpaceWidth = 14;
    
    self.backView = [[UIView alloc]init];
    self.backView.backgroundColor = [UIColor whiteColor];
    self.backView.layer.cornerRadius = 8;
    [self.contentView addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kIntervalHeight);
        make.left.equalTo(self.contentView.mas_left).offset(kPaddingWidth);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-kIntervalHeight);
        make.right.equalTo(self.contentView.mas_right).offset(-kPaddingWidth);
    }];
    
    self.taskTipImageView = [[UIImageView alloc]init];
    self.taskTipImageView.image = [UIImage imageNamed:@"intelligent_delay"];
    [self.backView addSubview:self.taskTipImageView];
    [self.taskTipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backView.mas_centerY);
        make.left.equalTo(self.backView.mas_left).offset(kPaddingWidth);
        make.width.mas_equalTo(kTaskImageWidthHeight);
        make.height.mas_equalTo(kTaskImageWidthHeight);
    }];
    
    self.taskTitleLabel = [[UILabel alloc]init];
    [self setLabelFormate:self.taskTitleLabel title:@"titletest" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor];
    [self.backView addSubview:self.taskTitleLabel];
    [self.taskTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.taskTipImageView.mas_right).offset(kSpaceWidth);
        make.top.equalTo(self.backView.mas_top).offset(18);
    }];
    
    self.taskSubtitleLabel = [[UILabel alloc]init];
    [self setLabelFormate:self.taskSubtitleLabel title:@"subtitletest" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#A1A7B2"];
    [self.backView addSubview:self.taskSubtitleLabel];
    [self.taskSubtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.taskTitleLabel.mas_bottom).offset(4);
        make.left.right.equalTo(self.taskTitleLabel);
    }];
    
    self.arrowsImageView = [[UIImageView alloc]init];
    self.arrowsImageView.image = [UIImage imageNamed:@"mineArrow"];
    [self.backView addSubview:self.arrowsImageView];
    [self.arrowsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.taskTitleLabel.mas_right).offset(kSpaceWidth);
        make.top.equalTo(self.taskTitleLabel.mas_top);
    }];
    
    self.taskDeleteImageView = [[UIImageView alloc]init];
    self.taskDeleteImageView.image = [UIImage imageNamed:@"task_delete"];
    [self.backView addSubview:self.taskDeleteImageView];
    [self.taskDeleteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backView.mas_right).offset(-kPaddingWidth);
        make.width.height.mas_equalTo(24);
        make.centerY.equalTo(self.backView);
    }];
}

- (void)setLabelFormate:(UILabel *)label title:(NSString *)title font:(UIFont *)font titleColorHexString:(NSString *)titleColorString {
    label.text = title;
    label.textColor = [UIColor colorWithHexString:titleColorString];
    label.font = font;
    label.textAlignment = NSTextAlignmentLeft;
    
}

- (void)setDataDic:(NSDictionary *)dataDic {
    _dataDic = dataDic;
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
