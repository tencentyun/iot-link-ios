//
//  WCUserInfomationTableViewCell.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTUserInfomationTableViewCell.h"

@interface TIoTUserInfomationTableViewCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *valueLab;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) MASConstraint *rightValueConstraint;
@property (nonatomic, strong) MASConstraint *rightImageConstraint;
@end

@implementation TIoTUserInfomationTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
//    static NSString *ID = @"TIoTUserInfomationTableViewCell";
    TIoTUserInfomationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTUserInfomationTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
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
        self.titleLab.font = [UIFont wcPfRegularFontOfSize:14];
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(100);
        }];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = kRGBColor(242, 244, 245);
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLab);
            make.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(0);
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
        self.valueLab.font = [UIFont wcPfRegularFontOfSize:14];
        [self.contentView addSubview:self.valueLab];
        [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
            self.rightValueConstraint = make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.valueLab.mas_left);
        }];
        
        //国际化
        self.iconImageView = [[UIImageView alloc]init];
        self.iconImageView.layer.cornerRadius = 12;
        self.iconImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.rightImageConstraint = make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
            make.centerY.equalTo(self.contentView);
            make.height.width.mas_equalTo(24);
        }];
    }
    return self;
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    self.titleLab.text = dic[@"title"]?:@"";
    self.valueLab.text = dic[@"value"]?:@"";
    if ([dic[@"haveArrow"] isEqualToString:@"1"]) {
        self.arrowImageView.hidden = NO;
    }
    else{
        self.arrowImageView.hidden = YES;
        [self.rightImageConstraint setOffset:20];
        [self.rightValueConstraint setOffset:20];
    }
    
    //国际化
    if ([NSString isNullOrNilWithObject:dic[@"Avatar"]]) {
        self.iconImageView.hidden = YES;
        self.valueLab.hidden = NO;
    }else {
        [self.iconImageView setImageWithURLStr:[TIoTCoreUserManage shared].avatar placeHolder:@"icon-avatar_man"];
        self.iconImageView.hidden = NO;
        self.valueLab.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
