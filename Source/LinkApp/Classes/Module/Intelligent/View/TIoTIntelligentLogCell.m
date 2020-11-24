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
@end

@implementation TIoTIntelligentLogCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *const kTIoTIntelligentLogCellID = @"kTIoTIntelligentLogCellID";
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
    self.backgroundColor = [UIColor whiteColor];
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
    self.sceneNameLabel.text = @"";
    [self.contentView addSubview:self.sceneNameLabel];
    [self.sceneNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(verticalBar.mas_right).offset(32);
        make.right.equalTo(self.contentView.mas_right);
        make.top.equalTo(self.contentView.mas_top).offset(15);
    }];
    
    self.timeLabel = [[UILabel alloc]init];
    self.timeLabel.text = @"";
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sceneNameLabel.mas_left);
        make.top.equalTo(self.sceneNameLabel.mas_bottom);
    }];
    
    self.resultLabel = [[UILabel alloc]init];
    self.resultLabel.text = @"";
    [self.contentView addSubview:self.resultLabel];
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel.mas_right).offset(5);
        make.top.equalTo(self.timeLabel.mas_top);
    }];
    
    self.errorDeltailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.errorDeltailButton setBackgroundColor:[UIColor redColor]];
    [self.errorDeltailButton addTarget:self action:@selector(showErrorDetailMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.errorDeltailButton];
    [self.errorDeltailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(24);
        make.right.equalTo(self.contentView.mas_right).offset(-40);
    }];
    
}

- (void)setExecutedResult:(BOOL)executedResult {
    _executedResult = executedResult;
    if (executedResult == YES) { //成功
        
    }else { //失败
        
    }
}

- (void)showErrorDetailMessage:(UIButton *)button {
    
    button.selected = !button.selected;
    NSLog(@"---%d",button.selected);
    if (self.logDetailBlock) {
        self.logDetailBlock(button.selected,self.selectedIndex);
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
