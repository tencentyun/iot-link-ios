//
//  TIoTPlayListCell.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/13.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTPlayListCell.h"

@interface TIoTPlayListCell ()
@property (nonatomic, strong) UILabel *deviceName;
@property (nonatomic, strong) UIButton *playLeft;
@property (nonatomic, strong) UIButton *playMidd;
@property (nonatomic, strong) UIButton *playRight;
@end

@implementation TIoTPlayListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"TIoTPlayListCellID";
    TIoTPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTPlayListCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
                ];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUIViews];
    }
    return self;
}

- (void)setupUIViews {
    
    CGFloat kWidth = 100;
    CGFloat kHeight = 60;
    CGFloat kSpace = (kScreenWidth-3*kWidth)/4;
    
    self.deviceName = [[UILabel alloc]initWithFrame:CGRectMake(kSpace, 2, kScreenWidth-kHeight, 20)];
    self.deviceName.textColor = [UIColor blackColor];
    self.deviceName.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.deviceName];
    
    self.playLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playLeft.frame = CGRectMake(kSpace, CGRectGetMaxY(self.deviceName.frame)+5, kWidth, kHeight);
    [self.playLeft setTitle:@"实时监控" forState:UIControlStateNormal];
    [self setPlayButtonFormat:self.playLeft];
    [self.playLeft addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.playLeft];
    
    self.playMidd = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playMidd.frame = CGRectMake(CGRectGetMaxX(self.playLeft.frame)+kSpace, CGRectGetMaxY(self.deviceName.frame)+5, kWidth, kHeight);
    [self.playMidd setTitle:@"本地回放" forState:UIControlStateNormal];
    [self setPlayButtonFormat:self.playMidd];
    [self.playMidd addTarget:self action:@selector(clickMiddBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.playMidd];
    
    self.playRight = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playRight.frame = CGRectMake(CGRectGetMaxX(self.playMidd.frame)+kSpace, CGRectGetMaxY(self.deviceName.frame)+5, kWidth, kHeight);
    [self.playRight setTitle:@"云端存储" forState:UIControlStateNormal];
    [self setPlayButtonFormat:self.playRight];
    [self.playRight addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.playRight];
}

- (void)setPlayButtonFormat:(UIButton *)button {
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor lightGrayColor]];
}

- (void)clickLeftBtn {
    if (self.playRealTimeMonitoringBlock) {
        self.playRealTimeMonitoringBlock();
    }
}

- (void)clickMiddBtn {
    if (self.playLocalPlaybackBlock) {
        self.playLocalPlaybackBlock();
    }
}

- (void)clickRightBtn {
    if (self.playCloudStorageBlock) {
        self.playCloudStorageBlock();
    }
}

- (void)setDeviceNameString:(NSString *)deviceNameString {
    _deviceNameString = deviceNameString;
    self.deviceName.text = deviceNameString;
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
