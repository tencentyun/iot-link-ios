//
//  WCMessageTextCell.m
//  TenextCloud
//
//  Created by Wp on 2019/11/6.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTMessageTextCell.h"

@interface TIoTMessageTextCell()
@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UILabel *timeLab;
@end

@implementation TIoTMessageTextCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"TIoTMessageTextCell";
    TIoTMessageTextCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTMessageTextCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
                ];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(0);
            make.bottom.equalTo(self.contentView);
            make.top.mas_equalTo(0);
        }];
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.numberOfLines = 2;
        self.titleLab.textColor = kRGBColor(51, 51, 51);
        self.titleLab.font = [UIFont wcPfRegularFontOfSize:16];
        [bgView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(20);
            make.trailing.mas_equalTo(-20);
            make.top.mas_equalTo(12);
        }];
        
        
        self.timeLab = [[UILabel alloc] init];
        self.timeLab.text = @"我是消息时间";
        self.timeLab.textColor = kRGBColor(51, 51, 51);
        self.timeLab.font = [UIFont wcPfRegularFontOfSize:12];
        [bgView addSubview:self.timeLab];
        [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLab.mas_bottom).offset(12);
            make.trailing.mas_equalTo(-15);
            make.bottom.mas_equalTo(-16);
        }];
    }
    return self;
}


- (void)setMsgData:(NSDictionary *)msgData
{
    _msgData = msgData;
    self.titleLab.text = msgData[@"MsgContent"];
    self.timeLab.text = [NSString convertTimestampToTime:msgData[@"MsgTimestamp"] byDateFormat:@"yyyy-MM-dd HH:mm"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
