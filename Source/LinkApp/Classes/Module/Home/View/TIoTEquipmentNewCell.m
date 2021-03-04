//
//  TIoTEquipmentNewCell.m
//  LinkApp
//
//  Created by ccharlesren on 2021/3/4.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTEquipmentNewCell.h"
#import "UILabel+TIoTExtension.h"

typedef NS_ENUM(NSInteger,TIoTDeviceType) {
    TIoTDeviceTypeLeft,
    TIoTDeviceTypeRight,
};

static CGFloat kWidthHeightScale = 330/276;

@interface TIoTEquipmentNewCell ()
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIImageView *leftDeviceImage;
@property (nonatomic, strong) UILabel *leftDeviceNameLabel;
@property (nonatomic, strong) UIImageView *leftWhiteMaskView;

@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIImageView *rightDeviceImage;
@property (nonatomic, strong) UILabel *rightDeviceNameLabel;
@property (nonatomic, strong) UIImageView *rightWhiteMaskView;

@end

@implementation TIoTEquipmentNewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *kDevicesListNewCellID = @"kDevicesListNewCellID";
    TIoTEquipmentNewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDevicesListNewCellID];
    if (!cell) {
        cell = [[TIoTEquipmentNewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kDevicesListNewCellID
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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    
    CGFloat kWidthPadding = 16; //左右边距
    CGFloat kLineSpacing = 12;  //item中间间距
    CGFloat kItemWidth = (kScreenWidth - kWidthPadding*2 - kLineSpacing)/2;
//    CGFloat kItemHeiht = kItemWidth/(kWidthHeightScale);
//    CGFloat kItemHeight = 288;
    CGFloat kDeviceImageWidthOrHeight = 48;
    
    /// 左侧item
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftButton.layer.cornerRadius = 8;
    [self.leftButton addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kWidthPadding);
        make.top.equalTo(self.contentView.mas_top).offset(6);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-6);
        make.width.mas_equalTo(kItemWidth);
    }];
    
    self.leftDeviceImage = [[UIImageView alloc]init];
    self.leftDeviceImage.userInteractionEnabled = YES;
    self.leftDeviceImage.image = [UIImage imageNamed:@"deviceDefault"];
    self.leftDeviceImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.leftButton addSubview:self.leftDeviceImage];
    [self.leftDeviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kDeviceImageWidthOrHeight);
        make.top.equalTo(self.leftButton.mas_top).offset(16);
        make.left.equalTo(self.leftButton.mas_left).offset(16);
    }];
    
    self.leftDeviceNameLabel = [[UILabel alloc]init];
    [self.leftDeviceNameLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#15161A" textAlignment:NSTextAlignmentLeft];
    [self.leftButton addSubview:self.leftDeviceNameLabel];
    [self.leftDeviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftDeviceImage.mas_left);
        make.top.equalTo(self.leftDeviceImage.mas_bottom).offset(16);
        make.right.equalTo(self.leftButton.mas_right).offset(-16);
    }];
    
    //左侧item离线蒙版
    self.leftWhiteMaskView = [[UIImageView alloc]init];
    self.leftWhiteMaskView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.3];
    [self.leftButton addSubview:self.leftWhiteMaskView];
    [self.leftWhiteMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.leftWhiteMaskView);
    }];
    self.leftWhiteMaskView.hidden = YES;
    
    
    /// 右侧item
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton.layer.cornerRadius = 8;
    [self.rightButton addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-kWidthPadding);
        make.top.equalTo(self.contentView.mas_top).offset(6);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-6);
        make.width.mas_equalTo(kItemWidth);
    }];
    
    self.rightDeviceImage = [[UIImageView alloc]init];
    self.rightDeviceImage.userInteractionEnabled = YES;
    self.rightDeviceImage.image = [UIImage imageNamed:@"deviceDefault"];
    self.rightDeviceImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.rightButton addSubview:self.rightDeviceImage];
    [self.rightDeviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kDeviceImageWidthOrHeight);
        make.top.equalTo(self.rightButton.mas_top).offset(16);
        make.left.equalTo(self.rightButton.mas_left).offset(16);
    }];
    
    self.rightDeviceNameLabel = [[UILabel alloc]init];
    [self.rightDeviceNameLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#15161A" textAlignment:NSTextAlignmentLeft];
    [self.rightButton addSubview:self.rightDeviceNameLabel];
    [self.rightDeviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.rightDeviceImage.mas_left);
        make.top.equalTo(self.rightDeviceImage.mas_bottom).offset(16);
        make.right.equalTo(self.rightButton.mas_right).offset(-16);
    }];
    
    //右侧item蒙版
    self.rightWhiteMaskView = [[UIImageView alloc]init];
    self.rightWhiteMaskView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.7];
    [self.rightButton addSubview:self.rightWhiteMaskView];
    [self.rightWhiteMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.rightButton);
    }];
    self.rightWhiteMaskView.hidden = YES;
}

#pragma mark - setter or getter

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    /// 每个dataArray 只包含两个dictionary
    
    if (dataArray.count%2 == 0) { //双数
        self.rightButton.hidden = NO;
        
        NSDictionary *leftDic = dataArray[0];
        [self setCellConentWithDic:leftDic withDirection:TIoTDeviceTypeLeft];
        
        NSDictionary *rightDic = dataArray[1];
        [self setCellConentWithDic:rightDic withDirection:TIoTDeviceTypeRight];
        
    }else { //单数 只有左边的
        self.rightButton.hidden = YES;
        
        NSDictionary *leftDic = dataArray[0];
        [self setCellConentWithDic:leftDic withDirection:TIoTDeviceTypeLeft];
    }
    
}

- (void)setCellConentWithDic:(NSDictionary *)dataDic withDirection:(TIoTDeviceType)type {
    
    if (type == TIoTDeviceTypeLeft) {
        [self.leftDeviceImage setImageWithURLStr:dataDic[@"IconUrl"] placeHolder:@"deviceDefault"];
        
        NSString * alias = dataDic[@"AliasName"];
        
        if (alias && [alias isKindOfClass:[NSString class]] && alias.length > 0) {
            
            self.leftDeviceNameLabel.text = dataDic[@"AliasName"];
            
        } else {
            
            self.leftDeviceNameLabel.text = dataDic[@"DeviceName"];
        }
        
        if ([dataDic[@"Online"] integerValue] == 1) {  //离线
            self.leftWhiteMaskView.hidden = NO;
        } else { //在线
            self.leftWhiteMaskView.hidden = YES;
        }
    }else if (type == TIoTDeviceTypeRight) {
        [self.rightDeviceImage setImageWithURLStr:dataDic[@"IconUrl"] placeHolder:@"deviceDefault"];
        
        NSString * alias = dataDic[@"AliasName"];
        
        if (alias && [alias isKindOfClass:[NSString class]] && alias.length > 0) {
            
            self.rightDeviceNameLabel.text = dataDic[@"AliasName"];
            
        } else {
            
            self.rightDeviceNameLabel.text = dataDic[@"DeviceName"];
        }
        
        if ([dataDic[@"Online"] integerValue] == 1) {  //离线
            self.rightWhiteMaskView.hidden = NO;
        } else { //在线
            self.rightWhiteMaskView.hidden = YES;
        }
    }
    
}

#pragma mark - private method
- (void)setShadowEffectWithButton:(UIButton *)button {
    button.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08].CGColor;
    button.layer.shadowOffset = CGSizeMake(0,0);
    button.layer.shadowRadius = 16;
    button.layer.shadowOpacity = 1;
    button.layer.cornerRadius = 8;
}

- (void)clickLeftBtn {
    if (self.clickLeftDeviceBlock) {
        self.clickLeftDeviceBlock();
    }
}

- (void)clickRightBtn {
    if (self.clickRightDeviceBlock) {
        self.clickRightDeviceBlock();
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
