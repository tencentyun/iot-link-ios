//
//  TIoTConfigResultViewController.m
//  LinkApp
//
//  Created by Sun on 2020/7/30.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTConfigResultViewController.h"
#import "TIoTStartConfigViewController.h"

@interface TIoTConfigResultViewController ()

/// 配网类型
@property (nonatomic, assign) TIoTConfigHardwareStyle configHardwareStyle;
/// 配网成功or失败
@property (nonatomic, assign) BOOL success;

@property (nonatomic, strong) NSDictionary *dataDic;

@end

@implementation TIoTConfigResultViewController

- (instancetype)initWithConfigHardwareStyle:(TIoTConfigHardwareStyle)configHardwareStyle success:(BOOL)success {
    if (self = [super init]) {
        _configHardwareStyle = configHardwareStyle;
        _success = success;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI{
    NSString *title = _configHardwareStyle == TIoTConfigHardwareStyleSoftAP ? @"热点配网" : @"一键配网";
    self.title = title;
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *imageName = _success ? @"new_distri_success" : @"new_distri_failure";
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:imageName];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(105.3*kScreenAllHeightScale + [TIoTUIProxy shareUIProxy].navigationBarHeight);
        make.width.height.mas_equalTo(53.3);
    }];
    
    NSString *topic = _success ? @"配网完成,设备添加成功" : @"配网失败";
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textColor = [UIColor blackColor];
    topicLabel.font = [UIFont wcPfMediumFontOfSize:17];
    topicLabel.text = topic;
    topicLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:topicLabel];
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(15.4);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(280);
        make.height.mas_equalTo(24);
    }];
    
    NSString *describe = _success ? [NSString stringWithFormat:@"设备名称:%@", @"客厅摄像头"] : @"请检查以下信息";
    UILabel *describeLabel = [[UILabel alloc] init];
    describeLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    describeLabel.font = [UIFont wcPfRegularFontOfSize:14];
    describeLabel.text = describe;
    describeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:describeLabel];
    [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topicLabel.mas_bottom).offset(8);
        make.left.right.equalTo(topicLabel);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *stepLabel = [[UILabel alloc] init];
    NSString *stepLabelText = _configHardwareStyle == TIoTConfigHardwareStyleSoftAP ? @"1. 确认设备处于热点模式（指示灯慢闪）\n2. 确认是否成功连接到设备热点\n3. 核对家庭WiFi密码是否正确\n4. 确认路由设备是否为2.4G WiFi频段" : @"1. 确认设备处于一键配网模式（指示灯快闪）\n2. 核对家庭WiFi密码是否正确\n3. 确认路由设备是否为2.4G WiFi频段";
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.lineSpacing = 6.0;
    // 字体: 大小 颜色 行间距
    NSAttributedString * attributedStr = [[NSAttributedString alloc]initWithString:stepLabelText attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:kRGBColor(136, 136, 136),NSParagraphStyleAttributeName:paragraph}];
    stepLabel.attributedText = attributedStr;
    stepLabel.numberOfLines = 0;
    [self.view addSubview:stepLabel];
    [stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(describeLabel.mas_bottom).offset(20);
        make.left.right.equalTo(topicLabel);
//        make.height.mas_equalTo(100);
    }];
    
    NSString *changeTitle = _success ? @"继续添加其他设备" : [NSString stringWithFormat:@"切换到%@", _configHardwareStyle == TIoTConfigHardwareStyleSoftAP ? @"一键配网" : @"热点配网"];
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeButton setTitle:changeTitle forState:UIControlStateNormal];
    [changeButton setTitleColor:kMainColor forState:UIControlStateNormal];
    changeButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [changeButton addTarget:self action:@selector(changeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
    [changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(describeLabel.mas_bottom).offset(141*kScreenAllHeightScale);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(124);
        make.height.mas_equalTo(72);
    }];
    
    NSString *nextTitle = _success ? @"完成" : @"重试";
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:nextTitle forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = kMainColor;
    nextBtn.layer.cornerRadius = 2;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(40);
        make.top.equalTo(changeButton.mas_bottom).offset(1);
        make.width.mas_equalTo(kScreenWidth - 80);
        make.height.mas_equalTo(45);
    }];
}

#pragma mark eventResponse

- (void)changeClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_configHardwareStyle == TIoTConfigHardwareStyleSoftAP) {
        [HXYNotice postChangeAddDeviceType:0];
    } else if (_configHardwareStyle == TIoTConfigHardwareStyleSmartConfig) {
        [HXYNotice postChangeAddDeviceType:1];
    }
}

- (void)nextClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (!_success) {
        if (_configHardwareStyle == TIoTConfigHardwareStyleSoftAP) {
            [HXYNotice postChangeAddDeviceType:1];
        } else if (_configHardwareStyle == TIoTConfigHardwareStyleSmartConfig) {
            [HXYNotice postChangeAddDeviceType:0];
        }
    }
}

@end
