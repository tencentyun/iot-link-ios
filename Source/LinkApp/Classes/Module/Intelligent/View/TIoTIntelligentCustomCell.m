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
@property (nonatomic, strong) UIButton *taskDeleteButton;

@property (nonatomic, strong) UIView    *blankAddView; //自动智能 条件和任务为空显示view
@property (nonatomic, strong) UILabel *addLabel;
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
    [self.taskTitleLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
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
    [self.taskSubtitleLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#A1A7B2" textAlignment:NSTextAlignmentLeft];
    [self.backView addSubview:self.taskSubtitleLabel];
    [self.taskSubtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.taskTitleLabel.mas_bottom).offset(4);
        make.left.equalTo(self.taskTitleLabel.mas_left);
        make.right.equalTo(self.backView.mas_right).offset(-30);
    }];
    
    self.taskDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.taskDeleteButton addTarget:self action:@selector(deleteItem) forControlEvents:UIControlEventTouchUpInside];
    [self.taskDeleteButton setImage:[UIImage imageNamed:@"task_delete"] forState:UIControlStateNormal];
    [self.backView addSubview:self.taskDeleteButton];
    [self.taskDeleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backView.mas_right).offset(-kPaddingWidth);
        make.width.height.mas_equalTo(24);
        make.centerY.equalTo(self.backView);
    }];
    
    self.blankAddView = [[UIView alloc]init];
    self.blankAddView.layer.cornerRadius = 8;
    self.blankAddView.backgroundColor = [UIColor whiteColor];
    [self.backView addSubview:self.blankAddView];
    [self.blankAddView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.equalTo(self.backView);
    }];

    UIImageView *addImage = [[UIImageView alloc]init];
    addImage.image = [UIImage imageNamed:@"intelligent_add"];
    [self.blankAddView addSubview:addImage];
    [addImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(24);
        make.top.equalTo(self.blankAddView.mas_top).offset(14);
        make.centerX.equalTo(self.blankAddView.mas_centerX);
    }];

    self.addLabel = [[UILabel alloc]init];
    [self.addLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#6C7078" textAlignment:NSTextAlignmentCenter];
    [self.blankAddView addSubview:self.addLabel];
    [self.addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(addImage.mas_centerX);
        make.top.equalTo(addImage.mas_bottom).offset(5);
    }];

    self.blankAddView.hidden = YES;
}

- (void)addContent {
    
}

- (void)setModel:(TIoTAutoIntelligentModel *)model {
    _model = model;
    self.taskTitleLabel.text = model.DeviceName?:@"";
    NSString *urlString = model.IconUrl?:@"";
    [self.taskTipImageView setImageWithURLStr:urlString placeHolder:@"new_add_product_placeholder"];
}
- (void)setSubTitleString:(NSString *)subTitleString {
    _subTitleString = subTitleString;
    NSString *secString = self.model.propertName?:@"";
    NSString *modifiedString = subTitleString ?: @"";
    self.taskSubtitleLabel.text = [NSString stringWithFormat:@"%@:%@",secString,modifiedString];
}

- (void)setDelayTimeString:(NSString *)delayTimeString {
    _delayTimeString = delayTimeString;
    self.taskTitleLabel.text = NSLocalizedString(@"manualIntelligent_delay", @"延时");
    self.taskSubtitleLabel.text = delayTimeString;
}

- (void)setBlankAddTipString:(NSString *)blankAddTipString {
    _blankAddTipString = blankAddTipString;
    self.addLabel.text = blankAddTipString;
}

- (void)setIsHideBlankAddView:(BOOL)isHideBlankAddView {
    _isHideBlankAddView = isHideBlankAddView;
    self.blankAddView.hidden = isHideBlankAddView;
}

- (void)setAutoIntellModel:(TIoTAutoIntelligentModel *)autoIntellModel {
    _autoIntellModel = autoIntellModel;
    //（ 0 设备状态变化 1 定时 2 设备控制，3 延时，4 选择手动，5 发送通知）
    if ([autoIntellModel.type isEqualToString:@"0"]) {
        
        NSString *nameStr = autoIntellModel.Property.conditionTitle?:@"";
        NSString *opStr = autoIntellModel.Property.Op?:@"";
        NSString *op = @"";
        if ([opStr isEqualToString:@"eq"]) { //条件操作符  eq 等于  ne 不等于  gt 大于  lt 小于  ge 大等于  le 小等于
            op = NSLocalizedString(@"auto_equal", @"等于");
        }else if ([opStr isEqualToString:@"ne"]) {
            op = NSLocalizedString(@"auto_ne", @"不等于");
        }else if ([opStr isEqualToString:@"gt"]) {
            op = NSLocalizedString(@"auto_gt", @"大于");
        }else if ([opStr isEqualToString:@"lt"]) {
            op = NSLocalizedString(@"auto_lt", @"小于");
        }else if ([opStr isEqualToString:@"ge"]) {
            op = NSLocalizedString(@"auto_ge", @"大等于");
        }else if ([opStr isEqualToString:@"le"]) {
            op = NSLocalizedString(@"auto_le", @"小等于");
        }
        self.taskTitleLabel.text = autoIntellModel.Property.DeviceName?:@"";
        NSString *contentStr = autoIntellModel.Property.conditionContentString?:@"";
        self.taskSubtitleLabel.text = [NSString stringWithFormat:@"%@:%@%@",nameStr,op,contentStr];
        NSString *urlString = autoIntellModel.Property.IconUrl?:@"";
        [self.taskTipImageView setImageWithURLStr:urlString placeHolder:@"new_add_product_placeholder"];
        
    }else if ([autoIntellModel.type isEqualToString:@"1"]) {
        self.taskTitleLabel.text = NSLocalizedString(@"auto_timer", @"定时");
        NSString *timePointStr = autoIntellModel.Timer.TimePoint?:@"";
        NSString *timeKindStr = autoIntellModel.Timer.timerKindSring?:@"";
        self.taskSubtitleLabel.text = [NSString stringWithFormat:@"%@,%@",timePointStr,timeKindStr];
        self.taskTipImageView.image = [UIImage imageNamed:@"intelligent_timing"];
        
    }else if ([autoIntellModel.type isEqualToString:@"2"]) {
        
        NSString *nameStr = autoIntellModel.propertName?:@"";
        NSString *op = @"";
        self.taskTitleLabel.text = autoIntellModel.DeviceName?:@"";;
        NSString *contentStr = autoIntellModel.dataValueString?:@"";
        self.taskSubtitleLabel.text = [NSString stringWithFormat:@"%@:%@%@",nameStr,op,contentStr];
        NSString *urlString = autoIntellModel.IconUrl?:@"";
        [self.taskTipImageView setImageWithURLStr:urlString placeHolder:@"new_add_product_placeholder"];
        
    }else if ([autoIntellModel.type isEqualToString:@"3"]) {
        self.taskTitleLabel.text = NSLocalizedString(@"manualIntelligent_delay", @"延时");
        self.taskSubtitleLabel.text = autoIntellModel.delayTime?:@"";
        self.taskTipImageView.image = [UIImage imageNamed:@"intelligent_delay"];
        
    }else if ([autoIntellModel.type isEqualToString:@"4"]) {
        self.taskTitleLabel.text = NSLocalizedString(@"auto_manual_choice", @"手动选择");
        self.taskSubtitleLabel.text = autoIntellModel.sceneName?:@"";
        self.taskTipImageView.image = [UIImage imageNamed:@"intelligent_manual"];
        
    }else if ([autoIntellModel.type isEqualToString:@"5"]) {
        self.taskTitleLabel.text = NSLocalizedString(@"post_notice", @"发送通知");
        self.taskSubtitleLabel.text = autoIntellModel.Data;
        self.taskTipImageView.image = [UIImage imageNamed:@"intelligent_notification"];
    }
}

- (void)deleteItem {
    if (self.deleteIntelligentItemBlock) {
        self.deleteIntelligentItemBlock();
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
