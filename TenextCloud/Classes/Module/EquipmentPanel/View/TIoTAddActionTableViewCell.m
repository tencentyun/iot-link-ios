//
//  WCAddActionTableViewCell.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/19.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTAddActionTableViewCell.h"

@interface TIoTAddActionTableViewCell ()

@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *statusLab;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation TIoTAddActionTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"TIoTAddActionTableViewCell";
    TIoTAddActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTAddActionTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
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
        self.nameLab.text = @"我是动作";
        [self.contentView addSubview:self.nameLab];
        [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(15);
        }];
        
        
        self.statusLab = [[UILabel alloc] init];
        self.statusLab.text = @"我是状态";
        [self.contentView addSubview:self.statusLab];
        [self.statusLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-15);
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

@end
