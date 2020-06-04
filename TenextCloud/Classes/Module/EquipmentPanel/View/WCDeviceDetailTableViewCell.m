//
//  WCDeviceDetailTableViewCell.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/24.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCDeviceDetailTableViewCell.h"

@interface WCDeviceDetailTableViewCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *valueLab;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation WCDeviceDetailTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"WCDeviceDetailTableViewCell";
    WCDeviceDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[WCDeviceDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
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
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.textColor = [UIColor blackColor];
        self.titleLab.font = [UIFont wcPfRegularFontOfSize:16];
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.centerY.equalTo(self.contentView);
            make.width.mas_greaterThanOrEqualTo(50);
        }];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = kRGBColor(242, 244, 245);
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLab);
            make.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-kHorEdge);
            make.height.mas_equalTo(1);
        }];
        
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mineArrow"]];
        [self.contentView addSubview:self.arrowImageView];
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLab);
            make.right.equalTo(self.contentView).offset(-20);
            make.height.width.mas_equalTo(18);
        }];
        
        self.valueLab = [[UILabel alloc] init];
        self.valueLab.textColor = kRGBColor(136, 136, 136);
        self.valueLab.font = [UIFont wcPfRegularFontOfSize:16];
        [self.contentView addSubview:self.valueLab];
        [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
            make.centerY.equalTo(self.contentView);
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
            make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
        }];
    }
    else{
        self.arrowImageView.hidden = YES;
        [self.valueLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.arrowImageView.mas_left).offset(18);
        }];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
