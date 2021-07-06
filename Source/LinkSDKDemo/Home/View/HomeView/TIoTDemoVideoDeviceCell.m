//
//  TIoTDemoVideoDeviceCell.m
//  LinkApp
//
//

#import "TIoTDemoVideoDeviceCell.h"

static NSInteger const maxLimitDeviceNumber = 4;

@interface TIoTDemoVideoDeviceCell ()
@property (nonatomic, strong) UIImageView *deviceIcon;   //设备icon
@property (nonatomic, strong) UIButton *moreFuncBtn;     //更多按钮
@property (nonatomic, strong) UILabel *deviceNameLabel;  //设备名称
@property (nonatomic, strong) UILabel *onlineTipLabel;   //离线/在线  显示
@property (nonatomic, strong) UIImageView *maskView;     //离线遮罩
@end

@implementation TIoTDemoVideoDeviceCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCellView];
    }
    return self;
}

- (void)setupCellView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 8;
    
    CGFloat kPadding = 16;
    CGFloat kIconSize = 58;
    CGFloat kMoreFuncBtnSize = 24;
    
    self.deviceIcon = [[UIImageView alloc]init];
    self.deviceIcon.image = [UIImage imageNamed:@"camera_shooting"];
    [self.contentView addSubview:self.deviceIcon];
    [self.deviceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.top.equalTo(self.contentView.mas_top).offset(kPadding);
        make.width.height.mas_equalTo(kIconSize);
    }];

    self.moreFuncBtn = [[UIButton alloc]init];
    [self.moreFuncBtn setImage:[UIImage imageNamed:@"more_function"] forState:UIControlStateNormal];
    [self.moreFuncBtn addTarget:self action:@selector(showMoreFunction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.moreFuncBtn];
    [self.moreFuncBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-kPadding);
        make.top.equalTo(self.contentView.mas_top).offset(20);
        make.width.height.mas_equalTo(kMoreFuncBtnSize);
    }];
    
    self.deviceNameLabel = [[UILabel alloc]init];
    [self.deviceNameLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.deviceNameLabel];
    [self.deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(kPadding);
        make.top.equalTo(self.deviceIcon.mas_bottom).offset(11);
        make.right.equalTo(self.contentView.mas_right).offset(-kPadding);
    }];
    
    self.onlineTipLabel = [[UILabel alloc]init];
    [self.onlineTipLabel setLabelFormateTitle:@"在线" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#29CC85" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.onlineTipLabel];
    [self.onlineTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceNameLabel.mas_bottom).offset(5);
        make.left.equalTo(self.deviceNameLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right).offset(-kPadding);
    }];
    
    self.chooseDeviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.chooseDeviceBtn setImage:[UIImage imageNamed:@"device_unselect"] forState:UIControlStateNormal];
    [self.chooseDeviceBtn addTarget:self action:@selector(chooseDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.chooseDeviceBtn];
    [self.chooseDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-kPadding);
        make.bottom.equalTo(self.onlineTipLabel.mas_bottom);
        make.width.height.mas_equalTo(kMoreFuncBtnSize);
    }];
    
    self.chooseDeviceBtn.hidden = YES;
    
    self.maskView = [[UIImageView alloc]init];
    self.maskView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.7];
    [self.contentView addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.contentView);
    }];
    
    self.maskView.hidden = YES;
}

- (void)setModel:(TIoTExploreOrVideoDeviceModel *)model {
    _model = model;
    self.deviceNameLabel.text = model.DeviceName?:@"";
    if ([model.Online isEqualToString:@"1"]) { //在线
        self.onlineTipLabel.text = @"在线";
        self.onlineTipLabel.textColor = [UIColor colorWithHexString:@"#29CC85"];
        self.maskView.hidden = YES;
    }else { //离线
        self.onlineTipLabel.text = @"离线";
        self.onlineTipLabel.textColor = [UIColor colorWithHexString:@"#000000"];
        self.maskView.hidden = NO;
    }
    
    if ([model.isSelected isEqualToString:@"1"]) { //选中
        [self.chooseDeviceBtn setImage:[UIImage imageNamed:@"device_select"] forState:UIControlStateNormal];
    }else if ([model.isSelected isEqualToString:@"0"]) { //没选中
        [self.chooseDeviceBtn setImage:[UIImage imageNamed:@"device_unselect"] forState:UIControlStateNormal];
    }
    
}

- (void)setIsNVRDevice:(BOOL)isNVRDevice {
    _isNVRDevice = isNVRDevice;
    if (isNVRDevice == YES) {
        self.moreFuncBtn.hidden = YES;
    }else {
        self.moreFuncBtn.hidden = NO;
    }
}

- (void)showMoreFunction {
    if (self.moreActionBlock) {
        self.moreActionBlock();
    }
    
}

- (void)chooseDevice:(UIButton *)button {
    if (self.chooseDeviceBlock) {
        self.chooseDeviceBlock(button);
    }
}

- (void)setIsShowChoiceDeviceIcon:(BOOL)isShowChoiceDeviceIcon {
    _isShowChoiceDeviceIcon = isShowChoiceDeviceIcon;
    if (isShowChoiceDeviceIcon) {
        self.chooseDeviceBtn.hidden = NO;
        [self.chooseDeviceBtn setImage:[UIImage imageNamed:@"device_unselect"] forState:UIControlStateNormal];
    }else {
        [self.chooseDeviceBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        self.chooseDeviceBtn.hidden = YES;
    }
}
@end
