//
//  TIoTChooseClickValueCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTChooseClickValueCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTChooseClickValueCell ()
@property (nonatomic, strong) UIView        *backView;

@property (nonatomic, strong) UILabel       *eventTitle;

@end

@implementation TIoTChooseClickValueCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString * const kTIoTChooseClickValueCellID = @"TIoTChooseClickValueCell";
    TIoTChooseClickValueCell *cell = [tableView dequeueReusableCellWithIdentifier:kTIoTChooseClickValueCellID];
    if (!cell) {
        cell = [[TIoTChooseClickValueCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTIoTChooseClickValueCellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviewUI];
    }
    return self;
}

- (void)setupSubviewUI {
    
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    CGFloat kPadding = 30;
    CGFloat kImageHeithWidth = 19;
    
    
    self.backView = [[UIView alloc]init];
    self.backView.backgroundColor = [UIColor colorWithHexString:@"#F3F3F5"];
    self.backView.layer.cornerRadius = 8;
    [self.contentView addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left).offset(kPadding);
        make.right.equalTo(self.contentView.mas_right).offset(-kPadding);
        make.height.mas_equalTo(48);
    }];
    
    self.choiceImageView = [[UIImageView alloc]init];
    self.choiceImageView.image = [UIImage imageNamed:@"single_unseleccted"];
    [self.backView addSubview:self.choiceImageView];
    [self.choiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kImageHeithWidth);
        make.centerY.equalTo(self.backView);
        make.left.equalTo(self.backView.mas_left).offset(22);
    }];
    
    self.eventTitle = [[UILabel alloc]init];
    [self.eventTitle setLabelFormateTitle:self.titleString font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentRight];
    [self.backView addSubview:self.eventTitle];
    [self.eventTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backView.mas_right).offset(-20);
        make.left.equalTo(self.choiceImageView.mas_right);
        make.centerY.equalTo(self.backView);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.choiceImageView.image = [UIImage imageNamed:@"single_seleccted"];
    }else {
        self.choiceImageView.image = [UIImage imageNamed:@"single_unseleccted"];
    }
    
    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    self.eventTitle.text = self.titleString;
}

@end
