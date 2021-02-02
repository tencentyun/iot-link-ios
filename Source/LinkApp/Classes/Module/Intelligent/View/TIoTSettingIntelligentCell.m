//
//  TIoTSettingIntelligentCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTSettingIntelligentCell.h"
#import "UIImageView+TIoTWebImageView.h"

@interface TIoTSettingIntelligentCell ()
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *valueLab;
@property (nonatomic, strong) UIImageView *intelligentImage;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *arrowImageView;
@end

@implementation TIoTSettingIntelligentCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"TIoTSettingIntelligentCell";
    TIoTSettingIntelligentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTSettingIntelligentCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
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
        
        self.intelligentImage = [[UIImageView alloc]init];
        self.intelligentImage.layer.cornerRadius = 8.0;
        self.intelligentImage.layer.masksToBounds = YES;
        [self.contentView addSubview:self.intelligentImage];
        [self.intelligentImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(64);
            make.height.mas_equalTo(32);
            make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    self.titleLab.text = dic[@"title"];
    self.valueLab.text = dic[@"value"];
    if ([NSString isNullOrNilWithObject:dic[@"image"]]) {
        self.valueLab.hidden = NO;
        self.intelligentImage.hidden = YES;
    }else {
        self.valueLab.hidden = YES;
        self.intelligentImage.hidden = NO;
        [self.intelligentImage setImageWithURLStr:dic[@"image"] placeHolder:@""];
    }
    
    
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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
