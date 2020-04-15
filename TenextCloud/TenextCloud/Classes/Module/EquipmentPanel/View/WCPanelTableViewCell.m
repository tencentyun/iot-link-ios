//
//  WCPanelTableViewCell.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCPanelTableViewCell.h"

@interface WCPanelTableViewCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *valueLab;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UISwitch *switchOn;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation WCPanelTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"WCPanelTableViewCell";
    WCPanelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[WCPanelTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
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
        self.titleLab.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(kScreenWidth/5*2);
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
        
        self.switchOn = [[UISwitch alloc] init];
        [self.switchOn addTarget:self action:@selector(valueChanged:) forControlEvents:(UIControlEventValueChanged)];
        [self.contentView addSubview:self.switchOn];
        [self.switchOn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLab);
            make.right.equalTo(self.contentView).offset(-20);
        }];
        
        
        self.valueLab = [[UILabel alloc] init];
        self.valueLab.textColor = kRGBColor(136, 136, 136);
        self.valueLab.font = [UIFont wcPfRegularFontOfSize:16];
        self.valueLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.valueLab];
        [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(kScreenWidth/5*2);
        }];
    }
    return self;
}

- (void)valueChanged:(UISwitch *)sender{
    if (self.update) {
        self.update(@{self.dic[@"id"]:@(sender.on)});
    }
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    self.titleLab.text = dic[@"name"]?:@"";
    
    if ([dic[@"define"][@"type"] isEqualToString:@"bool"]) {
        //self.valueLab.text = [dic[@"status"][@"Value"] integerValue] == 0 ? @"关" : @"开";
        self.switchOn.hidden = NO;
        self.switchOn.on = [dic[@"status"][@"Value"] integerValue] == 0 ? NO : YES;
        self.arrowImageView.hidden = YES;
    }
    else if ([dic[@"define"][@"type"] isEqualToString:@"enum"]){
        NSString *value = [NSString stringWithFormat:@"%@",dic[@"status"][@"Value"]];
        self.valueLab.text = dic[@"define"][@"mapping"][value];
        
        self.switchOn.hidden = YES;
        self.arrowImageView.hidden = NO;
    }
    else if ([dic[@"define"][@"type"] isEqualToString:@"int"]){
        if ([NSObject isNullOrNilWithObject:dic[@"status"]]) {
            self.valueLab.text = [NSString stringWithFormat:@"%@%@",dic[@"define"][@"start"]?:@"",dic[@"define"][@"unit"]?:@""];
        }
        else{
            self.valueLab.text = [NSString stringWithFormat:@"%@%@",dic[@"status"][@"Value"]?:@"",dic[@"define"][@"unit"]?:@""];
        }
        
        self.switchOn.hidden = YES;
        self.arrowImageView.hidden = NO;
    }
    else if ([dic[@"define"][@"type"] isEqualToString:@"string"]){
        self.valueLab.text = dic[@"status"][@"Value"];
        self.switchOn.hidden = YES;
        self.arrowImageView.hidden = NO;
    }
    else if ([dic[@"define"][@"type"] isEqualToString:@"float"]){
        self.valueLab.text = [NSString stringWithFormat:@"%@%@",dic[@"status"][@"Value"]?:dic[@"define"][@"start"],dic[@"define"][@"unit"]?:@""];
        self.switchOn.hidden = YES;
        self.arrowImageView.hidden = NO;
    }
    else if ([dic[@"define"][@"type"] isEqualToString:@"timestamp"]){
        
        self.valueLab.text = [NSString convertTimestampToTime:[NSString stringWithFormat:@"%@",dic[@"status"][@"Value"]] byDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.switchOn.hidden = YES;
        self.arrowImageView.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
