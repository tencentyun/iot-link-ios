//
//  WCEquipmentTableViewCell.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/17.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCEquipmentTableViewCell.h"


@interface WCEquipmentTableViewCell ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *desLab;
@property (nonatomic, strong) UIButton *switchBtn;

@end

@implementation WCEquipmentTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kRGBColor(247, 249, 250);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backView = [[UIView alloc] init];
        self.backView.backgroundColor = [UIColor whiteColor];
        self.backView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08].CGColor;
        self.backView.layer.shadowOffset = CGSizeMake(0,0);
        self.backView.layer.shadowRadius = 16;
        self.backView.layer.shadowOpacity = 1;
        self.backView.layer.cornerRadius = 4;
        [self.contentView addSubview:self.backView];
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(15, 15, 0, 15));
        }];
        
        self.iconImageView = [[UIImageView alloc] init];
        self.iconImageView.image = [UIImage imageNamed:@"messageWarn"];
        [self.backView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.backView);
            make.left.equalTo(self.backView).offset(5);
            make.width.height.mas_equalTo(80);
        }];
        
        self.titleLab = [[UILabel alloc] init];
        
        self.titleLab.textColor = kRGBColor(51, 51, 51);
        self.titleLab.font = [UIFont systemFontOfSize:18];
        [self.backView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(5);
            make.centerY.equalTo(self.backView).offset(-15);
            make.right.equalTo(self.backView).offset(-15);
        }];
        
        self.desLab = [[UILabel alloc] init];
        
        self.desLab.textColor = kRGBColor(204, 204, 204);
        self.desLab.font = [UIFont systemFontOfSize:12];
        [self.backView addSubview:self.desLab];
        [self.desLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImageView.mas_right).offset(5);
            make.centerY.equalTo(self.backView).offset(15);
        }];
        
//        UIView *btnBackView = [[UIView alloc] init];
//        btnBackView.backgroundColor = kRGBColor(230, 230, 230);
//        btnBackView.layer.cornerRadius = 30;
//        btnBackView.layer.masksToBounds = YES;
//        [self.backView addSubview:btnBackView];
//        [btnBackView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(self.backView);
//            make.right.equalTo(self.backView).offset(-20);
//            make.width.height.mas_equalTo(60);
//        }];
        
//        self.switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"switchOn"] forState:UIControlStateNormal];
//        [self.switchBtn addTarget:self action:@selector(openOff:) forControlEvents:UIControlEventTouchUpInside];
//        [btnBackView addSubview:self.switchBtn];
//        [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(btnBackView);
//            make.width.height.mas_equalTo(60);
//        }];
    }
    return self;
}

- (void)setDataDic:(NSDictionary *)dataDic{
    _dataDic = dataDic;
    
    self.titleLab.text = dataDic[@"DeviceName"];
    if ([dataDic[@"Online"] integerValue] == 1) {
        self.desLab.text = @"设备在线";
        self.desLab.textColor = kMainColor;
    }
    else{
        self.desLab.text = @"设备离线";
        self.desLab.textColor = kRGBColor(204, 204, 204);
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)openOff:(id)sender{
    
}

@end
