//
//  WCChoseValueTableViewCell.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/23.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTChoseValueTableViewCell.h"

@interface TIoTChoseValueTableViewCell ()
@property (nonatomic, strong) UIView *backView;
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
        self.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backView = [[UIView alloc]init];
        self.backView.backgroundColor = kBgColor;
        self.backView.layer.cornerRadius = 8;
        [self.contentView addSubview:self.backView];
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(4);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-4);
            make.left.equalTo(self.contentView.mas_left).offset(16);
            make.right.equalTo(self.contentView.mas_right).offset(-16);
        }];
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.textColor = [UIColor blackColor];
        self.titleLab.font = [UIFont wcPfRegularFontOfSize:14];
        [self.backView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backView).offset(16);
            make.centerY.equalTo(self.backView);
        }];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = kRGBColor(242, 244, 245);
        [self.backView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.Lineleft = make.left.mas_equalTo(0);
            make.bottom.equalTo(self.backView);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
        
        self.choseImageView = [[UIImageView alloc] initWithImage:nil];
        [self.backView addSubview:self.choseImageView];
        [self.choseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLab);
            make.right.equalTo(self.backView).offset(-20);
            make.height.width.mas_equalTo(20);
        }];
        
    }
    return self;
}

- (void)setTitle:(NSString *)title andSelect:(BOOL)isSelect
{
    self.titleLab.text = title;
    
    if (isSelect) {
        self.choseImageView.image = [UIImage imageNamed:@"single_seleccted"];
    }
    else{
        self.choseImageView.image = [UIImage imageNamed:@"single_unseleccted"];
    }
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset
{
    [self.Lineleft setOffset:separatorInset.left];
}

@end
