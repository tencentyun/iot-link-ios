//
//  WCProductCell.m
//  TenextCloud
//
//  Created by Sun on 2020/5/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTProductCell.h"

@interface TIoTProductCell ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation TIoTProductCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    
    self.imgView = [[UIImageView alloc] init];
    self.imgView.image = [UIImage imageNamed:@"new_add_product_placeholder"];
    [self addSubview:_imgView];
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(65 * kScreenAllWidthScale);
        make.top.centerX.equalTo(self.contentView);
    }];
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.font = [UIFont wcPfRegularFontOfSize:12];
    self.titleLab.textColor = kRGBColor(68, 68, 68);
    self.titleLab.numberOfLines = 0;
    self.titleLab.text = @"客厅灯泡\n(其他）";
    [self.contentView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView.mas_bottom).offset(6.5);
        make.centerX.equalTo(self.contentView);
    }];
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    if ([dic objectForKey:@"CategoryName"]){
        self.titleLab.text = dic[@"CategoryName"]?:@"";
    }
    if ([dic objectForKey:@"ProductName"]){
        self.titleLab.text = dic[@"ProductName"]?:@"";
    }
    [self.imgView setImageWithURLStr:dic[@"IconUrl"] placeHolder:@"new_add_product_placeholder"];
}

@end
