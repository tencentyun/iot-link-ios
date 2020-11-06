//
//  TIoTIntelligentCustomCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentCustomCell.h"
#import "UILabel+TIoTExtension.h"
#import "UIImageView+TIoTWebImageView.h"
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
    [self.taskTitleLabel setLabelFormateTitle:@"titletest" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.backView addSubview:self.taskTitleLabel];
    [self.taskTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.taskTipImageView.mas_right).offset(kSpaceWidth);
        make.top.equalTo(self.backView.mas_top).offset(18);
    }];

    self.arrowsImageView = [[UIImageView alloc]init];
    self.arrowsImageView.image = [UIImage imageNamed:@"mineArrow"];
    [self.backView addSubview:self.arrowsImageView];
    [self.arrowsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.taskTitleLabel.mas_right).offset(kSpaceWidth);
        make.top.equalTo(self.taskTitleLabel.mas_top);
    }];

    self.taskSubtitleLabel = [[UILabel alloc]init];
    [self.taskSubtitleLabel setLabelFormateTitle:@"subtitletest" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#A1A7B2" textAlignment:NSTextAlignmentLeft];
    [self.backView addSubview:self.taskSubtitleLabel];
    [self.taskSubtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.taskTitleLabel.mas_bottom).offset(4);
        make.left.equalTo(self.taskTitleLabel.mas_left);
        make.right.equalTo(self.arrowsImageView.mas_left).offset(-10);
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

- (void)setModel:(TIoTPropertiesModel *)model {
    _model = model;
    self.taskTitleLabel.text = model.name?:@"";
}
- (void)setSubTitleString:(NSString *)subTitleString {
    _subTitleString = subTitleString;
    NSString *secString = self.model.desc?:@"";
    NSString *modifiedString = subTitleString ?: @"";
    self.taskSubtitleLabel.text = [NSString stringWithFormat:@"%@:%@",secString,modifiedString];
}

- (void)setProductModel:(TIoTIntelligentProductConfigModel *)productModel {
    _productModel = productModel;
    NSString *urlString = self.productModel.IconUrl?:@"";
    [self.taskTipImageView setImageWithURLStr:urlString placeHolder:@"intelligent_manual"];
}

- (void)setDelayTimeString:(NSString *)delayTimeString {
    _delayTimeString = delayTimeString;
    self.taskTitleLabel.text = NSLocalizedString(@"manualIntelligent_delay", @"延时");
    self.taskSubtitleLabel.text = delayTimeString;
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
