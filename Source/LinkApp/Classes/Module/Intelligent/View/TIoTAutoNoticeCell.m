//
//  TIoTAutoNoticeCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoNoticeCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTAutoNoticeCell ()
@property (nonatomic, strong) UILabel *noticeTitleLabel;
@property (nonatomic, strong) UISwitch *noticeSwitch;
@end

@implementation TIoTAutoNoticeCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString * kTIoTAutoNoticeCellID = @"kTIoTAutoNoticeCellID";
    TIoTAutoNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:kTIoTAutoNoticeCellID];
    if (!cell) {
        cell = [[TIoTAutoNoticeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTIoTAutoNoticeCellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviewsUI];
    }
    return self;
}

- (void)setupSubviewsUI {
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat kPaddingLeft = 15;
    
    self.noticeTitleLabel = [[UILabel alloc]init];
    [self.noticeTitleLabel setLabelFormateTitle:NSLocalizedString(@"message_notification", @"消息通知") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.noticeTitleLabel];
    [self.noticeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kPaddingLeft);
        make.top.bottom.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    self.noticeSwitch = [[UISwitch alloc]init];
    self.noticeSwitch.onTintColor= [UIColor colorWithHexString:kIntelligentMainHexColor];
    [self.noticeSwitch addTarget:self action:@selector(switchChange:)forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.noticeSwitch];
    [self.noticeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-20);
    }];
}

- (void)switchChange:(UISwitch*)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchChange:)]) {
        [self.delegate switchChange:sender];
    }
    
}

- (void)setIsOn:(BOOL)isOn {
    _isOn = isOn;
    if (self.isOn == YES) {
        [self.noticeSwitch setOn:YES];
    }else {
        [self.noticeSwitch setOn:NO];
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
