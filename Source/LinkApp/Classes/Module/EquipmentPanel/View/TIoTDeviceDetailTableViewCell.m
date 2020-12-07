//
//  WCDeviceDetailTableViewCell.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/24.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTDeviceDetailTableViewCell.h"

@interface TIoTDeviceDetailTableViewCell ()
@property (nonatomic, strong) UIView *backContentView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *valueLab;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation TIoTDeviceDetailTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"TIoTDeviceDetailTableViewCell";
    TIoTDeviceDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTDeviceDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
                ];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backContentView = [[UIView alloc]init];
        [self.contentView addSubview:self.backContentView];
        [self.backContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.contentView);
        }];
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.textColor = [UIColor blackColor];
        self.titleLab.font = [UIFont wcPfRegularFontOfSize:16];
        [self.backContentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backContentView).offset(20);
            make.centerY.equalTo(self.backContentView);
            make.width.mas_equalTo(100);
        }];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = kRGBColor(242, 244, 245);
        [self.backContentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLab);
            make.bottom.equalTo(self.backContentView);
            make.right.equalTo(self.backContentView).offset(-kHorEdge);
            make.height.mas_equalTo(1);
        }];
        
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mineArrow"]];
        [self.backContentView addSubview:self.arrowImageView];
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLab);
            make.right.equalTo(self.backContentView).offset(-20);
            make.height.width.mas_equalTo(18);
        }];
        
        self.valueLab = [[UILabel alloc] init];
        self.valueLab.textColor = kRGBColor(136, 136, 136);
        self.valueLab.font = [UIFont wcPfRegularFontOfSize:16];
        self.valueLab.textAlignment = NSTextAlignmentRight;
        [self.backContentView addSubview:self.valueLab];
        [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
            make.centerY.equalTo(self.backContentView);
            make.left.equalTo(self.titleLab.mas_right).offset(10).priority(750);
        }];
    }
    return self;
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    self.titleLab.text = dic[@"title"];
    self.valueLab.text = dic[@"value"];
    
    if ([dic[@"needArrow"] isEqualToString:@"1"]) {
        self.arrowImageView.hidden = NO;
        [self.valueLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.arrowImageView.mas_left).offset(5);
        }];
    }
    else{
        self.arrowImageView.hidden = YES;
        [self.valueLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.arrowImageView.mas_left).offset(18);
        }];
    }
}

- (void)setIsAddTimePriod:(BOOL)isAddTimePriod {
    _isAddTimePriod = isAddTimePriod;
    if (self.isAddTimePriod == YES) {
        
        CGFloat kPaddingLeft = 16;

        self.backContentView.layer.cornerRadius = 8;
        self.backgroundColor = [UIColor clearColor];
        self.backContentView.backgroundColor = [UIColor whiteColor];
        [self.backContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(kPaddingLeft);
            make.right.equalTo(self.contentView.mas_right).offset(-kPaddingLeft);
            make.top.equalTo(self.contentView.mas_top).offset(8);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-8);
        }];
        
        [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backContentView.mas_left).offset(kPaddingLeft);
        }];
        
        [self.arrowImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.backContentView.mas_right).offset(-kPaddingLeft);
        }];
    }
    
}

- (void)setTimePriodNumFont:(UIFont *)timePriodNumFont {
    _timePriodNumFont = timePriodNumFont;
    [self.titleLab setFont:timePriodNumFont];
    [self.valueLab setFont:timePriodNumFont];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
