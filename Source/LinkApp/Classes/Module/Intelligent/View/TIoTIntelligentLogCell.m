//
//  TIoTIntelligentLogCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/23.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentLogCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTIntelligentLogCell ()
@property (nonatomic, strong) UIImageView   *indicateImage;
@property (nonatomic, strong) UILabel       *sceneNameLabel;
@property (nonatomic, strong) UILabel       *timeLabel;
@property (nonatomic, strong) UILabel       *resultLabel;
@property (nonatomic, strong) UIButton      *errorDeltailButton;
@property (nonatomic, strong) UIView        *dividingLine;
@property (nonatomic, strong) UILabel       *errorDetailLabel;
@end

@implementation TIoTIntelligentLogCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString * kTIoTIntelligentLogCellID = @"kTIoTIntelligentLogCellID";
    TIoTIntelligentLogCell * cell = [tableView dequeueReusableCellWithIdentifier:kTIoTIntelligentLogCellID];
    if (!cell) {
        cell = [[TIoTIntelligentLogCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTIoTIntelligentLogCellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubiewUI];
    }
    return self;
}

- (void)setupSubiewUI {
    self.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *verticalBar = [[UIView alloc]init];
    verticalBar.backgroundColor = [UIColor colorWithHexString:@"#C2C5CC"];
    [self.contentView addSubview:verticalBar];
    [verticalBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(44);
        make.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(1);
    }];
    
    self.indicateImage = [[UIImageView alloc]init];
    self.indicateImage.image = [UIImage imageNamed:@"log_success"];
    [self.contentView addSubview:self.indicateImage];
    [self.indicateImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(verticalBar.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(16);
    }];
    
    self.sceneNameLabel = [[UILabel alloc]init];
    [self.sceneNameLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.sceneNameLabel];
    [self.sceneNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(verticalBar.mas_right).offset(32);
        make.right.equalTo(self.contentView.mas_right);
        make.top.equalTo(self.contentView.mas_top).offset(15);
    }];
    
    self.timeLabel = [[UILabel alloc]init];
    [self.timeLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#6C7078" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sceneNameLabel.mas_left);
        make.top.equalTo(self.sceneNameLabel.mas_bottom);
    }];
    
    self.resultLabel = [[UILabel alloc]init];
    [self.resultLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#6C7078" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.resultLabel];
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel.mas_right).offset(5);
        make.top.equalTo(self.timeLabel.mas_top);
//        make.right.equalTo(self.contentView.mas_right);
    }];
    
    self.errorDeltailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.errorDeltailButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
    [self.errorDeltailButton addTarget:self action:@selector(showErrorDetailMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.errorDeltailButton];
    [self.errorDeltailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(24);
        make.right.equalTo(self.contentView.mas_right).offset(-40);
    }];
    
    self.dividingLine = [[UIView alloc]init];
    self.dividingLine.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.contentView addSubview:self.dividingLine];
    [self.dividingLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sceneNameLabel.mas_left);
        make.right.equalTo(self.errorDeltailButton.mas_right);
        make.top.equalTo(self.errorDeltailButton.mas_bottom).offset(8);
        make.height.mas_equalTo(1);
    }];
    
    self.errorDetailLabel = [[UILabel alloc]init];
    self.errorDetailLabel.text = @"ddddd";
    [self.contentView addSubview:self.errorDetailLabel];
    [self.errorDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dividingLine.mas_left);
        make.top.equalTo(self.dividingLine.mas_bottom).offset(8);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    self.errorDeltailButton.hidden = YES;
    self.dividingLine.hidden = YES;
    self.errorDetailLabel.hidden = YES;

}

- (void)showErrorDetailMessage:(UIButton *)button {
    
//    button.selected = !button.selected;
//    NSLog(@"--!!!--%d",button.selected);
//    if (button.selected == YES) {
//        [self.errorDeltailButton setImage:[UIImage imageNamed:@"up_arrow"] forState:UIControlStateNormal];
//        self.dividingLine.hidden = NO;
//        self.errorDetailLabel.hidden = NO;
//    }else {
//        [self.errorDeltailButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
//        self.dividingLine.hidden = YES;
//        self.errorDetailLabel.hidden = YES;
//    }
//
//    if (self.logDetailBlock) {
//        self.logDetailBlock(button.selected,self.selectedIndex);
//    }
    
}

- (void)setMsgModel:(TIoTLogMsgsModel *)msgModel {
    _msgModel = msgModel;
    if (msgModel.ResultCode == 0) { //成功
        self.errorDeltailButton.hidden = YES;
        self.indicateImage.image = [UIImage imageNamed:@"log_success"];
        
        
    }else if (msgModel.ResultCode == -1) { //失败
        self.errorDeltailButton.hidden = NO;
        self.indicateImage.image = [UIImage imageNamed:@"log_error"];
        
    }
    
    self.sceneNameLabel.text = msgModel.AutomationName?:msgModel.SceneName;
    self.timeLabel.text = [NSString getTimeToStr:msgModel.CreateAt withFormat:@"HH:mm:ss" withTimeZone:[TIoTCoreUserManage shared].userRegion]; //userRegion
    self.resultLabel.text = msgModel.Result;
}

- (void)setIsCellOpen:(BOOL)isCellOpen {
    _isCellOpen = isCellOpen;
    if (isCellOpen == YES) {
        [self.errorDeltailButton setImage:[UIImage imageNamed:@"up_arrow"] forState:UIControlStateNormal];
        self.dividingLine.hidden = NO;
        self.errorDetailLabel.hidden = NO;
    }else {
        [self.errorDeltailButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateNormal];
        self.dividingLine.hidden = YES;
        self.errorDetailLabel.hidden = YES;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
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
