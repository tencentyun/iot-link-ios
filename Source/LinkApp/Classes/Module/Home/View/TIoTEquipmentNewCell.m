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
@property (nonatomic, strong) UIButton *leftSwitchBtn;
@property (nonatomic, strong) UIImageView *leftSwitchIcon;
@property (nonatomic, strong) UIButton *leftQuickBtn;
@property (nonatomic, strong) UIImageView *leftQuickIcon;
@property (nonatomic, strong) UIImageView *leftBluetoothIcon;
@property (nonatomic, strong) NSDictionary *leftConfigData;     //设备dic
@property (nonatomic, strong) NSArray *leftShortcutArray;
@property (nonatomic, strong) NSDictionary *leftProductDataDic; //产品dic

@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIImageView *rightDeviceImage;
@property (nonatomic, strong) UILabel *rightDeviceNameLabel;
@property (nonatomic, strong) UIImageView *rightWhiteMaskView;
@property (nonatomic, strong) UIButton *rightSwitchBtn;
@property (nonatomic, strong) UIImageView *rightSwitchIcon;
@property (nonatomic, strong) UIButton *rightQuickBtn;
@property (nonatomic, strong) UIImageView *rightQuickIcon;
@property (nonatomic, strong) UIImageView *rightBluetoothIcon;
@property (nonatomic, strong) NSDictionary *rightConfigData;     //设备dic
@property (nonatomic, strong) NSArray *rightShortcutArray;
@property (nonatomic, strong) NSDictionary *rightProductDataDic; //产品dic

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
//    self.leftDeviceImage.userInteractionEnabled = YES;
    self.leftDeviceImage.image = [UIImage imageNamed:@"deviceDefault"];
    self.leftDeviceImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.leftButton addSubview:self.leftDeviceImage];
    [self.leftDeviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kDeviceImageWidthOrHeight);
        make.top.equalTo(self.leftButton.mas_top).offset(16);
        make.left.equalTo(self.leftButton.mas_left).offset(16);
    }];
    
    CGFloat kSwitchBtnSize = 29;
    CGFloat kSwitchBtnRightPadding = 18;
    
    self.leftDeviceNameLabel = [[UILabel alloc]init];
    [self.leftDeviceNameLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#15161A" textAlignment:NSTextAlignmentLeft];
    [self.leftButton addSubview:self.leftDeviceNameLabel];
    [self.leftDeviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftDeviceImage.mas_left);
        make.top.equalTo(self.leftDeviceImage.mas_bottom).offset(16);
        make.right.equalTo(self.leftButton.mas_right).offset(-kSwitchBtnRightPadding - kSwitchBtnSize);
    }];
    
    self.leftSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftSwitchBtn.layer.cornerRadius = kSwitchBtnSize/2;
    self.leftSwitchBtn.backgroundColor = [UIColor colorWithHexString:@"#F3F3F5"];
    [self.leftSwitchBtn addTarget:self action:@selector(clickLeftSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton addSubview:self.leftSwitchBtn];
    [self.leftSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftDeviceImage.mas_top);
        make.right.equalTo(self.leftButton.mas_right).offset(-kSwitchBtnRightPadding);
        make.height.width.mas_equalTo(kSwitchBtnSize);
    }];
    
    CGFloat kswitchIconSize = 12;
    self.leftSwitchIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"device_turnoff"]];//device_turnon
    [self.leftSwitchBtn addSubview:self.leftSwitchIcon];
    [self.leftSwitchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.leftSwitchBtn);
        make.height.width.mas_equalTo(kswitchIconSize);
    }];
    
    CGFloat kQuickBtnSize = 29;
    self.leftQuickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftQuickBtn.layer.cornerRadius = kQuickBtnSize/2;
    [self.leftQuickBtn addTarget:self action:@selector(clickLeftQuickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton addSubview:self.leftQuickBtn];
    [self.leftQuickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kQuickBtnSize);
        make.centerY.equalTo(self.leftDeviceNameLabel);
        make.right.equalTo(self.leftButton.mas_right).offset(-kSwitchBtnRightPadding);
    }];
    
    CGFloat kQuickIconSize = 12;
    self.leftQuickIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"quict_icon"]];
    [self.leftQuickBtn addSubview:self.leftQuickIcon];
    [self.leftQuickIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kQuickIconSize);
        make.center.equalTo(self.leftQuickBtn);
    }];
    
    CGFloat kBleIconSize = 20;
    self.leftBluetoothIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    [self.leftButton addSubview:self.leftBluetoothIcon];
    [self.leftBluetoothIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kBleIconSize);
        make.left.top.equalTo(self.leftButton);
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
        make.right.equalTo(self.rightButton.mas_right).offset(-kSwitchBtnRightPadding - kSwitchBtnSize);
    }];
    
    self.rightSwitchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightSwitchBtn.layer.cornerRadius = kSwitchBtnSize/2;
    self.rightSwitchBtn.backgroundColor = [UIColor colorWithHexString:@"#F3F3F5"];
    [self.rightSwitchBtn addTarget:self action:@selector(clickRightSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addSubview:self.rightSwitchBtn];
    [self.rightSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rightDeviceImage.mas_top);
        make.right.equalTo(self.rightButton.mas_right).offset(-kSwitchBtnRightPadding);
        make.height.width.mas_equalTo(kSwitchBtnSize);
    }];
    
    self.rightSwitchIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"device_turnoff"]];//device_turnon
    [self.rightSwitchBtn addSubview:self.rightSwitchIcon];
    [self.rightSwitchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.rightSwitchBtn);
        make.height.width.mas_equalTo(kswitchIconSize);
    }];
    
    self.rightQuickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightQuickBtn.layer.cornerRadius = kQuickBtnSize/2;
    [self.rightQuickBtn addTarget:self action:@selector(clickRightQuickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addSubview:self.rightQuickBtn];
    [self.rightQuickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kQuickBtnSize);
        make.centerY.equalTo(self.rightDeviceNameLabel);
        make.right.equalTo(self.rightButton.mas_right).offset(-kSwitchBtnRightPadding);
    }];
    
    self.rightQuickIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"quict_icon"]];
    [self.rightQuickBtn addSubview:self.rightQuickIcon];
    [self.rightQuickIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kQuickIconSize);
        make.center.equalTo(self.rightQuickBtn);
    }];
    
    
    self.rightBluetoothIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    [self.rightButton addSubview:self.rightBluetoothIcon];
    [self.rightBluetoothIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kBleIconSize);
        make.left.top.equalTo(self.rightButton);
    }];
    
    //右侧item蒙版
    self.rightWhiteMaskView = [[UIImageView alloc]init];
    self.rightWhiteMaskView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.7];
    [self.rightButton addSubview:self.rightWhiteMaskView];
    [self.rightWhiteMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.rightButton);
    }];
    self.rightWhiteMaskView.hidden = YES;
    
    
    self.leftSwitchBtn.hidden = YES;
    self.rightSwitchBtn.hidden = YES;
    
    self.leftQuickBtn.hidden = YES;
    self.rightQuickBtn.hidden = YES;
    
    self.leftBluetoothIcon.hidden = YES;
    self.rightBluetoothIcon.hidden = YES;
}

#pragma mark - Public method

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

- (void)setDeviceConfigDataArray:(NSArray<NSDictionary *> *)deviceConfigDataArray {
    _deviceConfigDataArray = deviceConfigDataArray;
    
    /// 每个dataArray 只包含两个dictionary

    if (deviceConfigDataArray.count%2 == 0) { //双数
        self.rightButton.hidden = NO;

        NSDictionary *leftDic = deviceConfigDataArray[0]?:@{};
        [self setConfigDataWithDic:leftDic withDirection:TIoTDeviceTypeLeft];
        
        NSDictionary *rightDic = deviceConfigDataArray[1]?:@{};
        [self setConfigDataWithDic:rightDic withDirection:TIoTDeviceTypeRight];
    }else { //单数 只有左边的
        self.rightButton.hidden = YES;
        
        NSDictionary *leftDic = deviceConfigDataArray[0]?:@{};
        [self setConfigDataWithDic:leftDic withDirection:TIoTDeviceTypeLeft];
    }
}

///MARK: 设置每个产品差异性显示内容(快捷功能、蓝牙)
- (void)setConfigDataWithDic:(NSDictionary *)configData withDirection:(TIoTDeviceType)type {
    
    //标准面板
    if (type == TIoTDeviceTypeLeft) {
        
        self.leftConfigData = [NSDictionary dictionaryWithDictionary:configData?:@{}];
        NSDictionary *configDataDic = configData[@"ShortCut"]?:@{};
        self.leftShortcutArray = [NSArray arrayWithArray:configDataDic[@"shortcut"]?:@[]];
        
        [self productConfigData:configData?:@{} switchBtn:self.leftSwitchBtn queckBtn:self.leftQuickBtn bleImageView:self.leftBluetoothIcon];
        
    }else if (type == TIoTDeviceTypeRight) {
        
        self.rightConfigData = [NSDictionary dictionaryWithDictionary:configData?:@{}];
        NSDictionary *configDataDic = configData[@"ShortCut"]?:@{};
        self.rightShortcutArray = [NSArray arrayWithArray:configDataDic[@"shortcut"]?:@[]];
        
        [self productConfigData:configData?:@{} switchBtn:self.rightSwitchBtn queckBtn:self.rightQuickBtn bleImageView:self.rightBluetoothIcon];
    }
}

///MARK: 设置每个产品通用显示内容
- (void)setCellConentWithDic:(NSDictionary *)dataDic withDirection:(TIoTDeviceType)type {
    
    if (type == TIoTDeviceTypeLeft) {
        
        self.leftProductDataDic = [dataDic mutableCopy];
        
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
        
        self.rightProductDataDic = [dataDic mutableCopy];
        
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

- (void)clickLeftQuickBtn {
    if (self.clickQuickBtnBlock) {
        self.clickQuickBtnBlock(self.leftProductDataDic, self.leftConfigData, self.leftShortcutArray);
    }
}

- (void)clickRightQuickBtn {
    if (self.clickQuickBtnBlock) {
        self.clickQuickBtnBlock(self.rightProductDataDic,self.rightConfigData, self.rightShortcutArray);
    }
}

- (void)clickLeftSwitch:(UIButton *)leftSwitch {
    
    if (!leftSwitch.selected) {
        self.leftSwitchIcon.image = [UIImage imageNamed:@"device_turnon"];
    }else {
        self.leftSwitchIcon.image = [UIImage imageNamed:@"device_turnoff"];
    }
    leftSwitch.selected = !leftSwitch.selected;
    
    if (self.clickDeviceSwitchBlock) {
        self.clickDeviceSwitchBlock();
    }
}

- (void)clickRightSwitch:(UIButton *)rightSwitch {
    
    if (!rightSwitch.selected) {
        self.rightSwitchIcon.image = [UIImage imageNamed:@"device_turnon"];
    }else {
        self.rightSwitchIcon.image = [UIImage imageNamed:@"device_turnoff"];
    }
    rightSwitch.selected = !rightSwitch.selected;
    
    if (self.clickDeviceSwitchBlock) {
        self.clickDeviceSwitchBlock();
    }
}

- (void)productConfigData:(NSDictionary *)configData switchBtn:(UIButton *)switchBtn queckBtn:(UIButton *)quickBtn bleImageView:(UIImageView *)bleIcon{

    [self controlSwtichBtnHide:switchBtn withShortcutDic:configData?:@{}];
    
    [self controlQuickBtnHide:quickBtn withShortcutDic:configData?:@{}];
    
    [self controlBleIconHide:bleIcon withShortcutDic:configData?:@{}];
}

///MARK:用户判断是否显示快捷入口开关
- (void)controlSwtichBtnHide:(UIButton *)switchBtn withShortcutDic:(NSDictionary *)configData {
    
    NSDictionary *shortcutDic = configData[@"ShortCut"]?:@{};
    
    if (![NSString isNullOrNilWithObject:shortcutDic[@"powerSwitch"]]) {
        switchBtn.hidden = NO;
    }else {
        switchBtn.hidden = YES;
    }
    
}

///MARK:用户判断是否显示快捷入口
- (void)controlQuickBtnHide:(UIButton *)quickBtn withShortcutDic:(NSDictionary *)configData{
    
    NSDictionary *shortcutDic = configData[@"ShortCut"]?:@{};
    
    NSArray *configArray = shortcutDic[@"shortcut"]?:@[];
    if (configArray.count == 0) {
        quickBtn.hidden = YES;
    }else {
        quickBtn.hidden = NO;
    }
}

///MARK:用户判断是否是蓝牙设备，显示蓝牙标识icon
- (void)controlBleIconHide:(UIImageView *)bleIcon withShortcutDic:(NSDictionary *)configData {
    NSDictionary *bleCondigDataDic = configData[@"BleConfig"]?:@{};
    if (bleCondigDataDic.allKeys.count == 0) {
        bleIcon.hidden = YES;
    }else {
        bleIcon.hidden = NO;
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
