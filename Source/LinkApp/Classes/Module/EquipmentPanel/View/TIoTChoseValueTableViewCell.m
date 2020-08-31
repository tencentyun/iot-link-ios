//
//  WCChoseValueTableViewCell.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/23.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTChoseValueTableViewCell.h"

@interface TIoTChoseValueTableViewCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImageView *choseImageView;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic,strong) MASConstraint *Lineleft;
@property (nonatomic,strong) MASConstraint *LineRight;

@end

@implementation TIoTChoseValueTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"TIoTChoseValueTableViewCell";
    TIoTChoseValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTChoseValueTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID
                ];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kBgColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.textColor = [UIColor blackColor];
        self.titleLab.font = [UIFont wcPfRegularFontOfSize:16];
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.centerY.equalTo(self.contentView);
        }];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = kRGBColor(242, 244, 245);
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.Lineleft = make.left.mas_equalTo(0);
            make.bottom.equalTo(self.contentView);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
        
        self.choseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"g_default"]];
        [self.contentView addSubview:self.choseImageView];
        [self.choseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLab);
            make.right.equalTo(self.contentView).offset(-20);
            make.height.width.mas_equalTo(20);
        }];
        
    }
    return self;
}

- (void)setTitle:(NSString *)title andSelect:(BOOL)isSelect
{
    self.titleLab.text = title;
    
    if (isSelect) {
        self.choseImageView.image = [UIImage imageNamed:@"g_select"];
    }
    else{
        self.choseImageView.image = [UIImage imageNamed:@"g_default"];
    }
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset
{
    [self.Lineleft setOffset:separatorInset.left];
}

@end
