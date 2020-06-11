//
//  WCHelpCell.m
//  TenextCloud
//
//  Created by Wp on 2019/10/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTHelpCell.h"

@interface TIoTHelpCell()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIView *lineView;

@end
@implementation TIoTHelpCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"TIoTHelpCell";
    TIoTHelpCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTHelpCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
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
        self.titleLab.font = [UIFont systemFontOfSize:18];
        self.titleLab.textColor = kFontColor;
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView.mas_leading).offset(24);
            make.centerY.equalTo(self.contentView);
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
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mineArrow"]];
        [self.contentView addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.greaterThanOrEqualTo(self.titleLab.mas_trailing).offset(10);
            make.centerY.equalTo(self.titleLab);
            make.trailing.equalTo(self.contentView).offset(-20);
            make.height.width.mas_equalTo(18);
        }];
    }
    return self;
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    self.titleLab.text = dic[@"title"]?:@"";
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.titleLab.text = name;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
