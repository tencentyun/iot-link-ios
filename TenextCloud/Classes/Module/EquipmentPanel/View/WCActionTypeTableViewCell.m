//
//  WCActionTypeTableViewCell.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/19.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCActionTypeTableViewCell.h"

@interface WCActionTypeTableViewCell ()

@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation WCActionTypeTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"WCActionTypeTableViewCell";
    WCActionTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[WCActionTypeTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
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
        
        self.nameLab = [[UILabel alloc] init];
        [self.contentView addSubview:self.nameLab];
        [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(15);
        }];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNameStr:(NSString *)nameStr{
    _nameStr = nameStr;
    self.nameLab.text = nameStr;
}

@end
