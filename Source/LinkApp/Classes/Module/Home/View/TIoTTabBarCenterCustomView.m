//
//  TIoTTabBarCenterCustomView.m
//  LinkApp
//
//  Created by ccharlesren on 2021/2/19.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTTabBarCenterCustomView.h"
#import "UIView+XDPExtension.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTTabBarCenterCustomView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong, readwrite) UIView *blackMaskView;
@property (nonatomic, strong, readwrite) UIButton *addDevice;
@property (nonatomic, strong, readwrite) UIButton *scanDevice;
@property (nonatomic, strong, readwrite) UIButton *addIntelligentDevice;

@end

@implementation TIoTTabBarCenterCustomView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    CGFloat kContentViewHeight = 180;
    __block CGFloat kHeight = kContentViewHeight+59;
    if (@available(iOS 11.0, *)) {
        kHeight = kHeight+[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    }
    
    CGRect screenBound = [UIScreen mainScreen].bounds;
    self.blackMaskView = [[UIView alloc]initWithFrame:CGRectMake(screenBound.origin.x, screenBound.origin.y, screenBound.size.width, screenBound.size.height-kHeight+10)];
    self.blackMaskView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [self addSubview:self.blackMaskView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideView)];
    [self.blackMaskView addGestureRecognizer:tap];
    
    
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.blackMaskView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.blackMaskView);
        make.height.mas_equalTo(kContentViewHeight+10);
        make.top.equalTo(self.blackMaskView.mas_bottom).offset(-10);
    }];
    
    [self changeViewRectConnerWithView:self.contentView withRect:CGRectMake(0, 0, kScreenWidth, kHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    
    CGFloat kWidthOrHeight = 55;
    CGFloat kImageWidthOrHeight = 20;
    self.scanDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.scanDevice addTarget:self action:@selector(clickScanDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.scanDevice setBackgroundColor:[UIColor colorWithHexString:kAddDeviceEntrance]];
    [self.contentView addSubview:self.scanDevice];
    [self.scanDevice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kWidthOrHeight);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.contentView.mas_top).offset(45);
    }];
    UIImageView *scanImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan_device"]];
    scanImage.userInteractionEnabled = YES;
    [self.scanDevice addSubview:scanImage];
    [scanImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kImageWidthOrHeight);
        make.center.equalTo(self.scanDevice);
    }];
    UILabel *scanLabel = [[UILabel alloc]init];
    [scanLabel setLabelFormateTitle:NSLocalizedString(@"scan_device", @"扫描设备") font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:scanLabel];
    [scanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scanDevice);
        make.top.equalTo(self.scanDevice.mas_bottom).offset(10);
    }];
    
    self.addDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addDevice addTarget:self action:@selector(clickAddDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.addDevice setBackgroundColor:[UIColor colorWithHexString:kAddDeviceEntrance]];
    [self.contentView addSubview:self.addDevice];
    [self.addDevice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kWidthOrHeight);
        make.right.equalTo(self.scanDevice.mas_left).offset(-50);
        make.top.equalTo(self.scanDevice.mas_top);
    }];
    UIImageView *addDeviceImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add_device"]];
    addDeviceImage.userInteractionEnabled = YES;
    [self.addDevice addSubview:addDeviceImage];
    [addDeviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kImageWidthOrHeight);
        make.center.equalTo(self.addDevice);
    }];
    UILabel *addDeiveLabel = [[UILabel alloc]init];
    [addDeiveLabel setLabelFormateTitle:NSLocalizedString(@"add_device", @"添加设备") font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:addDeiveLabel];
    [addDeiveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addDevice);
        make.top.equalTo(self.addDevice.mas_bottom).offset(10);
    }];
    
    self.addIntelligentDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addIntelligentDevice addTarget:self action:@selector(clickIntelligentDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.addIntelligentDevice setBackgroundColor:[UIColor colorWithHexString:kAddDeviceEntrance]];
    [self.contentView addSubview:self.addIntelligentDevice];
    [self.addIntelligentDevice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kWidthOrHeight);
        make.top.equalTo(self.scanDevice.mas_top);
        make.left.equalTo(self.scanDevice.mas_right).offset(50);
    }];
    UIImageView *addIntelligentImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add_intelligent_device"]];
    addIntelligentImage.userInteractionEnabled = YES;
    [self.addIntelligentDevice addSubview:addIntelligentImage];
    [addIntelligentImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kImageWidthOrHeight);
        make.center.equalTo(self.addIntelligentDevice);
    }];
    UILabel *intellientDeviceLabel = [[UILabel alloc]init];
    [intellientDeviceLabel setLabelFormateTitle:NSLocalizedString(@"intelligent_addDevice", @"智能添加") font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:intellientDeviceLabel];
    [intellientDeviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addIntelligentDevice);
        make.top.equalTo(self.addIntelligentDevice.mas_bottom).offset(10);
    }];
    
}

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

- (void)clickScanDevice {
    [self hideView];
}

- (void)clickAddDevice {
    [self hideView];
}

- (void)clickIntelligentDevice {
    [self hideView];
}

- (void)hideView {
    [self.blackMaskView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)drawRect:(CGRect)rect {
    CGFloat kWidthOrHeight = 55;
    self.scanDevice.layer.cornerRadius = kWidthOrHeight/2;
    self.addDevice.layer.cornerRadius = kWidthOrHeight/2;
    self.addIntelligentDevice.layer.cornerRadius = kWidthOrHeight/2;
}

@end
