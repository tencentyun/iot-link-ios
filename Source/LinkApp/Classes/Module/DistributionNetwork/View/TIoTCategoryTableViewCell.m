//
//  WCCategoryTableViewCell.m
//  TenextCloud
//
//  Created by Sun on 2020/5/27.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTCategoryTableViewCell.h"

@interface TIoTCategoryTableViewCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation TIoTCategoryTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"TIoTCategoryTableViewCell";
    TIoTCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTCategoryTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
                ];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(3);
            make.height.mas_equalTo(20.85);
        }];
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.font = [UIFont wcPfRegularFontOfSize:16];
        self.titleLab.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    if (dic[@"CategoryName"] == nil) {
        self.titleLab.text = dic[@"RoomName"]?:@"";
    }else {
        self.titleLab.text = dic[@"CategoryName"]?:@"";
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.backgroundColor = [UIColor whiteColor];
        self.lineView.hidden = NO;
        self.titleLab.textColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    } else {
        self.backgroundColor = kRGBColor(242, 242, 242);
        self.lineView.hidden = YES;
        self.titleLab.textColor = [UIColor blackColor];
    }
}

@end
