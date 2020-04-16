//
//  WCMineTableViewCell.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCMineTableViewCell.h"
//#import "UIImage+Ex.h"

@interface WCMineTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation WCMineTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"WCMineTableViewCell";
    WCMineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[WCMineTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
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
        
        self.iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(24);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(25);
        }];
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.font = [UIFont wcPfRegularFontOfSize:16];
        self.titleLab.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(24);
            make.centerY.equalTo(self.iconImageView);
        }];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = kLineColor;
        self.lineView.hidden = YES;
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-16);
            make.height.mas_equalTo(1);
        }];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mineArrow"]];
        [self.contentView addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLab);
            make.right.equalTo(self.contentView).offset(-20);
            make.height.width.mas_equalTo(18);
        }];
    }
    return self;
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    self.iconImageView.image = [UIImage imageNamed:dic[@"image"]];
    self.titleLab.text = dic[@"title"]?:@"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsShowLine:(BOOL)isShowLine
{
    _isShowLine = isShowLine;
    self.lineView.hidden = !isShowLine;
}

@end
