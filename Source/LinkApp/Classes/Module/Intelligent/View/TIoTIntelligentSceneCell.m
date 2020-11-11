//
//  TIoTIntelligentSceneCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentSceneCell.h"
#import "UIImageView+TIoTWebImageView.h"
#import "UILabel+TIoTExtension.h"
#import "UIButton+LQRelayout.h"

@interface TIoTIntelligentSceneCell ()
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UILabel *sceneName;
@property (nonatomic, strong) UILabel *sceneDeviceNum;
@property (nonatomic, strong) UIButton *sceneButton;
@end

@implementation TIoTIntelligentSceneCell


+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"TIoTIntelligentSceneCellID";
    TIoTIntelligentSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTIntelligentSceneCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
                ];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview {
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat kPadding = 16; //左右间距
    
    self.backImageView = [[UIImageView alloc]init];
    [self.backImageView setImageWithURLStr:@"" placeHolder:@""];
    [self.contentView addSubview:self.backImageView];
    [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kPadding);
        make.right.equalTo(self.contentView.mas_right).offset(-kPadding);
        make.top.equalTo(self.contentView.mas_top).offset(8);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-8);
    }];

    self.sceneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sceneButton setImage:[UIImage imageNamed:@"intelligent_manual_switch"] forState:UIControlStateNormal];
    [self.backImageView addSubview:self.sceneButton];
    [self.sceneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backImageView.mas_right).offset(-25);
        make.width.height.mas_equalTo(32);
        make.centerY.equalTo(self.backImageView);
    }];

    self.sceneName = [[UILabel alloc]init];
    [self.sceneName setLabelFormateTitle:@"" font:[UIFont wcPfMediumFontOfSize:16] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentLeft];
    [self.backImageView addSubview:self.sceneName];
    [self.sceneName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backImageView.mas_left).offset(16);
        make.right.equalTo(self.sceneButton.mas_left).offset(-20);
        make.top.equalTo(self.backImageView.mas_top).offset(12);
    }];

    self.sceneDeviceNum = [[UILabel alloc]init];
    [self.sceneDeviceNum setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentLeft];
    [self.backImageView addSubview:self.sceneDeviceNum];
    [self.sceneDeviceNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sceneName.mas_left);
        make.right.equalTo(self.sceneName.mas_right);
        make.bottom.equalTo(self.backImageView.mas_bottom).offset(-13);
    }];
    
    
}

- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
    [self.backImageView setImageWithURLStr:dic[@"SceneIcon"]?:@"" placeHolder:@""];
    self.sceneName.text = dic[@"SceneName"]?:@"";
}

- (void)setDeviceNum:(NSString *)deviceNum {
    _deviceNum = deviceNum;
    self.sceneDeviceNum.text = [NSString stringWithFormat:@"%@个设备",deviceNum?:@""];
}

- (void)drawRect:(CGRect)rect {
    self.backImageView.layer.cornerRadius = 10;
    self.backImageView.layer.masksToBounds = YES;
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
