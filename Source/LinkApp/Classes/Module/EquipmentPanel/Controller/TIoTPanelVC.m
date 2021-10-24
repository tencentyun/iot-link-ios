//
//  WCPanelVC.m
//  TenextCloud
//
//

#import "TIoTPanelVC.h"
#import "TIoTWaterFlowLayout.h"
#import "TIoTCoreDeviceSet.h"
#import "TIoTBoolView.h"
#import "TIoTEnumView.h"
#import "TIoTNumberView.h"
#import "TIoTLongCell.h"
#import "TIoTMediumCell.h"
#import "TIoTPanelMoreViewController.h"
#import "TIoTBaseBigBtnView.h"

#import "TIoTSlideView.h"
#import "TIoTChoseValueView.h"
#import "TIoTTimeView.h"
#import "TIoTStringView.h"

#import "TIoTTipView.h"

#import "TIoTTimerListVC.h"
#import "WRNavigationBar.h"

#import "UIImage+Ex.h"
#import "TIoTUserConfigModel.h"
#import "YYModel.h"

#import "TIoTCoreDeviceSet.h"
#import "TIoTWebVC.h"
#import "TIoTAppEnvironment.h"
#import "TIoTCoreUtil.h"
#import "TIOTTRTCModel.h"
#import "TIoTTRTCUIManage.h"
#import "TIoTAlertView.h"
#import "UIButton+LQRelayout.h"
#import <QCloudNetEnv.h>
#import "UILabel+TIoTExtension.h"
#import "UIButton+TIoTButtonFormatter.h"

#import "TIoTLLSyncDeviceConfigModel.h"
#import "TIoTFirmwareModel.h"
#include <zlib.h>

static CGFloat itemSpace = 9;
static CGFloat lineSpace = 9;
#define kSectionInset UIEdgeInsetsMake(10, 16, 10, 16)

static NSString *itemId2 = @"i_ooo223";
static NSString *itemId3 = @"i_ooo454";

#define FFE2UUIDString @"0000FFE2"
#define FFE3UUIDString @"0000FFE3"
#define FFE4UUIDString @"0000FFE4"

typedef NS_ENUM(NSInteger,TIoTBlueDeviceConnectStatus) {
    TIoTBlueDeviceDisconnected,
    TIoTBlueDeviceConnected,
    TIoTBlueDeviceConnectedFail,
};

typedef NS_ENUM(NSInteger, TIoTDataTemplatePropertyType) {
    TIoTDataTemplatePropertyTypeBool, //布尔
    TIoTDataTemplatePropertyTypeInt, //整数
    TIoTDataTemplatePropertyTypeString, //字符串
    TIoTDataTemplatePropertyTypeFloat, //浮点
    TIoTDataTemplatePropertyTypeEnumerate, //枚举
    TIoTDataTemplatePropertyTypeTimestamp, //时间
    TIoTDataTemplatePropertyTypeStruct, //结构体
    TIoTDataTemplatePropertyTypeStringenum //字符串枚举
};

//数据模板类型
typedef NS_ENUM(NSInteger, TIoTDataTemplateType) {
    TIoTDataTemplateTypeProperty,
    TIoTDataTemplateTypeEvent,
    TIoTDataTemplateTypeAction,
};

//设备主动上报类型 属性 事件 最新数据
typedef NS_ENUM(NSInteger, TIoTDeviceReportType) {
    TIoTDeviceReportTypeNone,
    TIoTDeviceReportTypeProperty,
    TIoTDeviceReportTypeEvent,
    TIoTDeviceReportTypeNewData,
};

//LLData Fixed Header
typedef NS_ENUM(NSInteger, TIoTLLDataFixedHeaderDataTemplateType) {
    TIoTLLDataFixedHeaderDataTemplateTypeProperty, //属性
    TIoTLLDataFixedHeaderDataTemplateTypeEvent, //事件
    TIoTLLDataFixedHeaderDataTemplateTypeAction, //行为
};

@implementation TIoTCollectionView

//- (BOOL)touchesShouldCancelInContentView:(UIView *)view
//{
//    return YES;
//}

@end


@interface TIoTPanelVC ()<UICollectionViewDelegate,UICollectionViewDataSource,WCWaterFlowLayoutDelegate,BluetoothCentralManagerDelegate>
@property  (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *noIntelligentLogTipLabel;
@property (nonatomic,strong) UIImageView *bgView;//背景
@property (nonatomic,strong) TIoTCollectionView *coll;
@property (nonatomic,strong) UIView *bottomBar;//底部导航栏
@property (nonatomic,strong) CAGradientLayer *bottomLayer;
@property (nonatomic,strong) UIStackView *stackView;
@property (nonatomic,strong) TIoTBaseBigBtnView *bigBtnView;


@property (nonatomic,strong) NSDictionary *userConfigDic;
@property (nonatomic,strong) DeviceInfo *deviceInfo;

@property (nonatomic) WCThemeStyle themeStyle;
@property (nonatomic,strong) MASConstraint *bottomBarHeight;

@property (nonatomic,copy) NSString *templateId;//底部左边对应的属性id

@property (nonatomic, strong) TIoTAlertView *tipAlertView;
@property (nonatomic, strong) UIView *backMaskView;
@property (nonatomic, strong) NSDictionary *reportData;
@property (nonatomic, strong) TIOTtrtcPayloadModel *reportModel;

@property (nonatomic, strong) UIView *blueConnectView; //蓝牙设备是否连接控制view
@property (nonatomic, strong) UILabel *blueTipLabel;
@property (nonatomic, strong) UIButton *controlBlueDeviceButton;
@property (nonatomic, weak)BluetoothCentralManager *blueManager;
//原始蓝牙扫描数据包含广播报文
@property (nonatomic, copy) NSDictionary<CBPeripheral *,NSDictionary<NSString *,id> *> *originBlueDevices;
@property (nonatomic, copy) NSArray<CBPeripheral *> *blueDevices;
@property (nonatomic, strong) CBPeripheral *currentConnectedPerpheral; //当前连接的设备
@property (nonatomic, assign) TIoTBlueDeviceConnectStatus deviceConnectStatus;
@property (nonatomic, strong) NSString *currentProductId; //通过设备广播获取的
@property (nonatomic, strong) CBCharacteristic *characteristicFFE1; //子设备绑定 写入设备时的特征值
@property (nonatomic, strong) NSString *timeStampString;
@property (nonatomic, strong) NSString *psk;
@property (nonatomic, strong) NSString *bleNewType; //判断是否是蓝牙设备
@property (nonatomic, strong) NSDictionary *DataTemplateDic; //控制台模板数据 （event action property）
@property (nonatomic, strong) NSDictionary *deviceReportData; //控制台下发的原始数据 Key:id value:value
@property (nonatomic, strong) NSDictionary *deviceReportPayload;//控制台下发解密后的payload
@property (nonatomic, strong) TIoTFirmwareModel *firmwareModel;
@property (nonatomic, strong) TIoTAlertView *firmwareView;
@property (nonatomic, assign) BOOL isDeviceReporting; //设备主动上报成功 （属性，事件，最新数据）

@end

@implementation TIoTPanelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [HXYNotice addReportDeviceListener:self reaction:@selector(deviceReport:)];
    self.deviceInfo.deviceId = self.deviceDic[@"DeviceId"];
    
    
    [self setupUI];
    
    [self getProductsConfig];
    
    [self configBlueManager];
    
    [self checkfirmwarVersion];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *aliasName = self.deviceDic[@"AliasName"];
    if (aliasName && aliasName.length > 0) {
        self.title = self.deviceDic[@"AliasName"];
    }
    else
    {
        self.title = NSLocalizedString(@"control_panel", @"控制面板");
    }
}

- (void)nav_customBack {
    [self.blueManager stopScan];
    [self.blueManager disconnectPeripheral];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [TIoTCoreUserManage shared].sys_call_status = @"-1";
}

- (void)configBlueManager {
    self.blueManager = [BluetoothCentralManager shareBluetooth];
    self.blueManager.delegate = self;
    [self.blueManager disconnectPeripheral];
    [self.blueManager scanNearLLSyncService];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.originBlueDevices) {
            //发现设备,连接
            if (self.blueDevices.count > 0) {
//                CBPeripheral *device = self.blueDevices[0];
                
                for (CBPeripheral *device in self.blueDevices) {
                    NSDictionary<NSString *,id> *advertisementData = self.originBlueDevices[device];
                    if ([advertisementData.allKeys containsObject:@"kCBAdvDataManufacturerData"]) {
                        NSData *manufacturerData = advertisementData[@"kCBAdvDataManufacturerData"];
                        NSString *hexstr = [NSString transformStringWithData:manufacturerData];
                        NSString *producthex = [hexstr substringWithRange:NSMakeRange(18, hexstr.length-18)];
                        NSString *productstr = [NSString stringFromHexString:producthex];
                        self.currentProductId = productstr;
                        
                        if ([advertisementData.allKeys containsObject:@"kCBAdvDataServiceUUIDs"]) {
                            NSNumber *connectHexstr = advertisementData[@"kCBAdvDataIsConnectable"];
                            NSArray *uuidArray = advertisementData[@"kCBAdvDataServiceUUIDs"];
                            if (![productstr isEqualToString:self.productId] && [uuidArray containsObject:[CBUUID UUIDWithString:@"FFE0"]] && [connectHexstr isEqual: @(1)]) {
                                [self.blueManager connectBluetoothPeripheral:device];
                                break;
                            }else if([productstr isEqualToString:self.productId]) {
                                [self.blueManager connectBluetoothPeripheral:device];
                                break;
                            }
                        }
                    }
                }
            }
        }else {
            //需要判断是已经连接设备还是未发现设备
            [self connectedFailBlueDeviceUI];
        }
    });
}

#pragma mark - UI

- (void)showOfflineTip
{
    
//        TIoTTipView *vc = [[TIoTTipView alloc] init];
        __weak typeof(self)WeakSelf = self;
    self.tipAlertView = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds withTopImage:nil];
        [self.tipAlertView alertWithTitle:NSLocalizedString(@"device_offline", @"设备已离线") message:NSLocalizedString(@"device_offline_check", @"请检查：\n1.设备是否有电；\n\n2.设备连接的路由器是否正常工作,网络通畅；\n\n3.是否修改了路由器的名称或密码，可以尝试重新连接；\n\n4.设备是否与路由器距离过远、隔墙或有其他遮挡物。") cancleTitlt:NSLocalizedString(@"q_feedback", @"问题反馈") doneTitle:NSLocalizedString(@"back_home", @"返回首页")];
        self.tipAlertView.cancelAction = ^{
            UIViewController *vc = [NSClassFromString(@"TIoTFeedBackViewController") new];
            [WeakSelf.navigationController pushViewController:vc animated:YES];
        };
        [self.tipAlertView setAlertViewContentAlignment:TextAlignmentStyleLeft];
        self.tipAlertView.doneAction = ^(NSString * _Nonnull text) {
            [WeakSelf.navigationController popViewControllerAnimated:YES];
        };
        
        self.backMaskView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].delegate.window.frame];
        [[UIApplication sharedApplication].delegate.window addSubview:self.backMaskView];
        [self.tipAlertView showInView:self.backMaskView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAlertView)];
        [self.backMaskView addGestureRecognizer:tap];
     
}

- (void)hideAlertView {
    if (self.tipAlertView != nil) {
        [self.tipAlertView removeFromSuperview];
    }
    if (self.firmwareView != nil) {
        [self.firmwareView removeFromSuperview];
    }
    [self.backMaskView removeFromSuperview];
}

- (void)setupUI
{
    
    if (_isOwner) {
        UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreIcon"] style:UIBarButtonItemStyleDone target:self action:@selector(moreClick:)];
        self.navigationItem.rightBarButtonItem  = moreItem;
    }
    
    [self wr_setNavBarBackgroundAlpha:0];
    
    [self.view addSubview:self.bgView];
    
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self.view addSubview:self.coll];
    [self.coll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(0);
    }];
    
    
    [self.coll registerNib:[UINib nibWithNibName:@"TIoTLongCell" bundle:nil] forCellWithReuseIdentifier:itemId2];
    [self.coll registerNib:[UINib nibWithNibName:@"TIoTMediumCell" bundle:nil] forCellWithReuseIdentifier:itemId3];
    
    [self.view addSubview:self.bottomBar];
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coll.mas_bottom).offset(0);
        make.leading.trailing.mas_equalTo(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        self.bottomBarHeight = make.height.mas_equalTo(0);
    }];
    
    if (![self.deviceDic[@"Online"] boolValue]) {
        if (self.tipAlertView == nil) {
            [self showOfflineTip];
        }
    }
}

- (void)layoutHeader
{
    
    if (self.deviceInfo.navBar) {
        BOOL isBottomBarShow = [self.deviceInfo.navBar[@"visible"] boolValue];
        if (isBottomBarShow) {
            [self.bottomBarHeight setOffset:76 + [TIoTUIProxy shareUIProxy].tabbarAddHeight];
            
            NSString *templateId = self.deviceInfo.navBar[@"templateId"];
            BOOL timingProject = [self.deviceInfo.navBar[@"timingProject"] boolValue];
            
            if (templateId && templateId.length > 0) {
                UIView *vv = [UIView new];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomBarLeftTap)];
                [vv addGestureRecognizer:tap];
                [self.stackView addArrangedSubview:vv];
                
                
                
                UILabel *barLab = [[UILabel alloc] init];
                barLab.font = [UIFont systemFontOfSize:10];
                barLab.textColor = kFontColor;
                [vv addSubview:barLab];
                [barLab mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(vv.mas_centerX);
                    make.bottom.mas_equalTo(-[TIoTUIProxy shareUIProxy].tabbarAddHeight - 4);
                }];
                
                UIImageView *imgV = [[UIImageView alloc] init];
                [vv addSubview:imgV];
                [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.mas_equalTo(50);
                    make.bottom.equalTo(barLab.mas_top).offset(-4);
                    make.centerX.equalTo(vv.mas_centerX);
                }];
                
                if (self.themeStyle == WCThemeStandard) {
                    barLab.textColor = [UIColor whiteColor];
                    imgV.image = [UIImage imageNamed:@"conNavLeft_standard"];
                }
                else if (self.themeStyle == WCThemeSimple)
                {
                    imgV.image = [UIImage imageNamed:@"conNavLeft_simple"];
                }
                else if (self.themeStyle == WCThemeDark)
                {
                    barLab.textColor = [UIColor whiteColor];
                    imgV.image = [UIImage imageNamed:@"conNavLeft_dark"];
                }
                
                
                
                NSDictionary *info;
                if ([templateId isEqualToString:self.deviceInfo.bigProp[@"id"]]) {
                    info = self.deviceInfo.bigProp;
                }
                else
                {
                    for (NSDictionary *pro in self.deviceInfo.properties) {
                        if ([templateId isEqualToString:pro[@"id"]]) {
                            info = pro;
                            break;
                        }
                    }
                }
                
                
                self.templateId = templateId;
                barLab.text = info[@"name"];
                
                
                if (![self.deviceDic[@"Online"] boolValue]) {
                    vv.userInteractionEnabled = NO;
                    vv.tintColor = [UIColor grayColor];
                    vv.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
                    imgV.image = [imgV.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                }
                
            }
            if (timingProject) {
                UIView *vv = [UIView new];
                UITapGestureRecognizer *tapT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomBarRightTap)];
                [vv addGestureRecognizer:tapT];
                [self.stackView addArrangedSubview:vv];
                
                UILabel *barLab = [[UILabel alloc] init];
                barLab.text = NSLocalizedString(@"timer", @"定时");
                barLab.font = [UIFont systemFontOfSize:10];
                barLab.textColor = kFontColor;
                [vv addSubview:barLab];
                
                [barLab mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(vv.mas_centerX);
                    make.bottom.mas_equalTo(-[TIoTUIProxy shareUIProxy].tabbarAddHeight - 4);
                }];
                
                UIImageView *imgV = [[UIImageView alloc] init];
                [vv addSubview:imgV];
                [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.mas_equalTo(50);
                    make.bottom.equalTo(barLab.mas_top).offset(-4);
                    make.centerX.equalTo(vv.mas_centerX);
                }];
                
                if (self.themeStyle == WCThemeStandard) {
                    barLab.textColor = [UIColor whiteColor];
                    imgV.image = [UIImage imageNamed:@"conNavRight_standard"];
                }
                else if (self.themeStyle == WCThemeSimple)
                {
                    imgV.image = [UIImage imageNamed:@"conNavRight_simple"];
                }
                else if (self.themeStyle == WCThemeDark)
                {
                    barLab.textColor = [UIColor whiteColor];
                    imgV.image = [UIImage imageNamed:@"conNavRight_dark"];
                }
            }
        }
        else
        {
            [self.bottomBarHeight setOffset:0];
        }
    }
    
    if (self.deviceInfo.bigProp) {
        NSString *type = self.deviceInfo.bigProp[@"define"][@"type"];
        if ([type isEqualToString:@"bool"]) {
            _coll.contentInset = UIEdgeInsetsMake(400, 0, 0, 0);
        }
        else if ([type isEqualToString:@"enum"])
        {
            _coll.contentInset = UIEdgeInsetsMake(357 + [TIoTUIProxy shareUIProxy].navigationBarHeight, 0, 0, 0);
        }
        else if ([type isEqualToString:@"int"])
        {
            _coll.contentInset = UIEdgeInsetsMake(350 + [TIoTUIProxy shareUIProxy].navigationBarHeight, 0, 0, 0);
        }
        else if ([type isEqualToString:@"float"])
        {
            _coll.contentInset = UIEdgeInsetsMake(350 + [TIoTUIProxy shareUIProxy].navigationBarHeight, 0, 0, 0);
        }
        
        if ([type isEqualToString:@"bool"]) {
            TIoTBoolView *ev = [[TIoTBoolView alloc] init];
            CGSize size = [ev systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            ev.frame = CGRectMake(0, -size.height, kScreenWidth, size.height);
            [ev setStyle:self.themeStyle];
            [ev setInfo:self.deviceInfo.bigProp];
            ev.userInteractionEnabled = [self.deviceDic[@"Online"] boolValue];
            ev.update = ^(NSDictionary * _Nonnull uploadInfo) {
                [self reportDeviceData:uploadInfo];
            };
            self.bigBtnView = ev;
            [self.coll addSubview:ev];
            [self wr_setNavBarBackgroundAlpha:1];
        }
        else if ([type isEqualToString:@"enum"])
        {
            NSDictionary *map = self.deviceInfo.bigProp[@"define"][@"mapping"];
            NSMutableArray *source = [NSMutableArray arrayWithCapacity:map.count];
            for (int i = 0; i < map.count; i ++) {
                if (map[[NSString stringWithFormat:@"%i",i]]) {
                    [source addObject:map[[NSString stringWithFormat:@"%i",i]]];
                }
            }
            TIoTEnumView *ev = [[TIoTEnumView alloc] init];
            ev.userInteractionEnabled = [self.deviceDic[@"Online"] boolValue];
            [ev setStyle:self.themeStyle];
            ev.info = self.deviceInfo.bigProp;
            ev.update = ^(NSDictionary * _Nonnull uploadInfo) {
                [self reportDeviceData:uploadInfo];
            };
            
            CGSize size = [ev systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            ev.frame = CGRectMake(0, -size.height, kScreenWidth, size.height);
            self.bigBtnView = ev;
            [self.coll addSubview:ev];
        }
        else if ([type isEqualToString:@"int"])
        {
            TIoTNumberView *nv = [[TIoTNumberView alloc] initWithFrame:CGRectMake(0, -350, kScreenWidth, 350)];
            nv.userInteractionEnabled = [self.deviceDic[@"Online"] boolValue];
            [nv setStyle:self.themeStyle];
            nv.info = self.deviceInfo.bigProp;
            nv.update = ^(NSDictionary * _Nonnull uploadInfo) {
                [self reportDeviceData:uploadInfo];
            };
            
            self.bigBtnView = nv;
            [self.coll addSubview:nv];
        }
        else if ([type isEqualToString:@"float"])
        {
            TIoTNumberView *nv = [[TIoTNumberView alloc] initWithFrame:CGRectMake(0, -350, kScreenWidth, 350)];
            nv.userInteractionEnabled = [self.deviceDic[@"Online"] boolValue];
            nv.info = self.deviceInfo.bigProp;
            nv.update = ^(NSDictionary * _Nonnull uploadInfo) {
                [self reportDeviceData:uploadInfo];
            };
            [nv setStyle:self.themeStyle];
            self.bigBtnView = nv;
            [self.coll addSubview:nv];
        }
    }
    
    if (self.themeStyle == WCThemeStandard) {
        _bgView.image = [UIImage imageNamed:@"controlBg_standard"];
        self.bottomLayer.colors = @[(id)kRGBColor(99, 118, 140).CGColor,(id)kRGBColor(99, 118, 140).CGColor];
        self.bottomBar.alpha = 0.75;
        [self wr_setNavBarTitleColor:[UIColor whiteColor]];
        [self wr_setNavBarTintColor:[UIColor whiteColor]];
    }
    else if (self.themeStyle == WCThemeSimple)
    {
        _bgView.backgroundColor = [UIColor whiteColor];
        self.bottomLayer.colors = @[(id)[UIColor whiteColor].CGColor,(id)[UIColor whiteColor].CGColor];
    }
    else if (self.themeStyle == WCThemeDark)
    {
        _bgView.image = [UIImage imageNamed:@"controlBg_dark"];
        self.bottomLayer.colors = @[(id)kRGBColor(106, 255, 255).CGColor,(id)[UIColor colorWithHexString:kIntelligentMainHexColor].CGColor];
        [self wr_setNavBarTitleColor:[UIColor whiteColor]];
        [self wr_setNavBarTintColor:[UIColor whiteColor]];
    }
    
}

//刷新大按钮
- (void)reloadForBig
{
    self.bigBtnView.info = self.deviceInfo.bigProp;
}

#pragma mark - request

- (void)getProductsConfig
{
    //先获取用户配置信息
    [[TIoTRequestObject shared] post:AppGetUserSetting Param:@{} success:^(id responseObject) {
        self.userConfigDic = [[NSDictionary alloc]initWithDictionary:responseObject[@"UserSetting"]];
        [self loadData:self.configData];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {

    }];
    
    
}

- (void)loadData:(NSDictionary *)dic {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];

    [[TIoTRequestObject shared] post:AppGetProducts Param:@{@"ProductIds":@[self.productId]} success:^(id responseObject) {
        NSArray *tmpArr = responseObject[@"Products"];
        if (tmpArr.count > 0) {
            //判断是否是纯蓝牙设备 llsync
            self.bleNewType = tmpArr.firstObject[@"NetType"]?:@"";
            if ([self.bleNewType isEqualToString:@"ble"]) {
                //降低collection高度 顶部显示蓝牙连接view
                [self.coll mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(46);
                }];
                
                [self.view addSubview:self.blueConnectView];
                [self.blueConnectView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.equalTo(self.view);
                    if (@available(iOS 11.0, *)) {
                        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                    }else {
                        make.top.equalTo(self.view.mas_top).offset(64);
                    }
                    make.height.mas_equalTo(46);
                }];
                
                [self.blueConnectView addSubview:self.blueTipLabel];
                [self.blueTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.blueConnectView);
                    make.left.equalTo(self.blueConnectView.mas_left).offset(15);
                }];
                
                [self.blueConnectView addSubview:self.controlBlueDeviceButton];
                [self.controlBlueDeviceButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.blueConnectView);
                    make.width.mas_equalTo(80);
                    make.top.equalTo(self.blueConnectView.mas_top).offset(10);
                    make.bottom.equalTo(self.blueConnectView.mas_bottom).offset(-10);
                    make.right.equalTo(self.blueConnectView.mas_right).offset(-15);
                }];
            }
            NSString *DataTemplate = tmpArr.firstObject[@"DataTemplate"];
            self.DataTemplateDic = [NSString jsonToObject:DataTemplate];

//            TIoTDataTemplateModel *product = [TIoTDataTemplateModel yy_modelWithJSON:DataTemplate];
            TIoTProductConfigModel *config = [TIoTProductConfigModel yy_modelWithJSON:dic];
            if ([config.Panel.type isEqualToString:@"h5"]) {

            }else {
                [self getDeviceData:dic andBaseInfo:self.DataTemplateDic];
            }

        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

    }];
}

- (void)getDeviceData:(NSDictionary *)uiInfo andBaseInfo:(NSDictionary *)baseInfo {

    [[TIoTRequestObject shared] post:AppGetDeviceData Param:@{@"ProductId":self.productId,@"DeviceName":self.deviceName} success:^(id responseObject) {
        NSString *tmpStr = (NSString *)responseObject[@"Data"];
        NSDictionary *tmpDic = [NSString jsonToObject:tmpStr];
        
//        TIoTDeviceDataModel *product = [TIoTDeviceDataModel yy_modelWithJSON:tmpStr];
        NSArray *propertiesArray = baseInfo[@"properties"];
        if (propertiesArray.count == 0) {
            [self addEmptyCandidateModelTipView];
        }
        [self.deviceInfo zipData:uiInfo baseInfo:baseInfo deviceData:tmpDic];
        [self layoutHeader];
        [self.coll reloadData];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

    }];
}

//下发数据
- (void)reportDeviceData:(NSDictionary *)deviceReport {
    
    //在这里都是主动呼叫，不存在被动
    NSString *key = self.reportData[@"id"];
//    NSNumber *statusValue = self.reportData[@"status"][@"Value"];
    
    if (![[TIoTCoreUserManage shared].sys_call_status isEqualToString:@"-1"]) {
        DDLogInfo(@"--!!-%@---",[TIoTCoreUserManage shared].sys_call_status);
        if ([key isEqualToString:@"_sys_audio_call_status"]) {
            if (![[TIoTCoreUserManage shared].sys_call_status isEqualToString:@"0"]) {
                [MBProgressHUD showError:NSLocalizedString(@"other_part_busy", @"对方正忙...") toView:self.view];
                return;
            }
        }else if ([key isEqualToString:@"_sys_video_call_status"]) {
            if (![[TIoTCoreUserManage shared].sys_call_status isEqualToString:@"0"]) {
                [MBProgressHUD showError:NSLocalizedString(@"other_part_busy", @"对方正忙...") toView:self.view];
                return;
            }
        }
    }
    
    NSMutableDictionary *trtcReport = [deviceReport mutableCopy];
    NSString *userId = [TIoTCoreUserManage shared].userId;
    if (userId) {
        [trtcReport setValue:userId forKey:@"_sys_userid"];
    }
    NSString *username = [TIoTCoreUserManage shared].nickName;
    if (username) {
        [trtcReport setValue:username forKey:@"username"];
    }
    
    NSDictionary *tmpDic = @{
                                @"ProductId":self.productId,
                                @"DeviceName":self.deviceName,
//                                @"Data":[NSString objectToJson:deviceReport],
                                @"Data":[NSString objectToJson:trtcReport]
                            };
    
    [[TIoTRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
    
    //主动呼叫，开始拨打
    TIoTTRTCSessionCallType audioORvideo = TIoTTRTCSessionCallType_audio;//audio
    BOOL isTRTCDevice = NO;
    for (NSString *prototype in deviceReport.allKeys) {
        
        NSString *protoValue = deviceReport[prototype];
        if ([prototype isEqualToString:TIoTTRTCaudio_call_status] || [prototype isEqualToString:TIoTTRTCvideo_call_status]) {
         
            if (protoValue.intValue == 1) {
                isTRTCDevice = YES;
                
                if ([prototype isEqualToString:TIoTTRTCaudio_call_status]) {
                    audioORvideo = TIoTTRTCSessionCallType_audio;
                }else {
                    audioORvideo = TIoTTRTCSessionCallType_video;
                }
                break;
            }
        }
    }
    if (isTRTCDevice) {
        
        [[TIoTTRTCUIManage sharedManager] callDeviceFromPanel:audioORvideo withDevideId:[NSString stringWithFormat:@"%@/%@",self.productId?:@"",self.deviceName?:@""]];
    }
}

//收到上报
- (void)deviceReport:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    [self.deviceInfo handleReportDevice:dic];
    
    [self reloadForBig];
    [self.coll reloadData];
    
    
    NSDictionary *payloadDic = [NSString base64Decode:dic[@"Payload"]];
    DDLogInfo(@"----8888---%@",payloadDic);
    DDLogInfo(@"----9999---%@",[TIoTCoreUserManage shared].userId);
    
    self.deviceReportPayload = [NSDictionary dictionaryWithDictionary:payloadDic]?:@{};
    
    if ([payloadDic.allKeys containsObject:@"params"]) {
        NSDictionary *paramsDic = payloadDic[@"params"];
        self.reportModel = [TIOTtrtcPayloadModel yy_modelWithJSON:payloadDic];
        if (paramsDic[@"_sys_audio_call_status"]) {
            [TIoTCoreUserManage shared].sys_call_status = self.reportModel.params._sys_audio_call_status;
        }else if (paramsDic[@"_sys_video_call_status"]) {
            [TIoTCoreUserManage shared].sys_call_status = self.reportModel.params._sys_video_call_status;
        }
    }
    
    
    if ([dic.allKeys containsObject:@"SubType"] && [dic.allKeys containsObject:@"DeviceId"]) {
        
        NSString *device_Id = dic[@"DeviceId"];
        if (![[NSString stringWithFormat:@"%@/%@",self.productId , self.deviceName] isEqualToString:device_Id]) {
            return;
        }
        
        NSString *line_status = dic[@"SubType"];
        if ([line_status isEqualToString:@"Offline"]) {
            //下线
//            [MBProgressHUD showError:@"设备已下线"];
            if (self.tipAlertView == nil) {
                [self showOfflineTip];
            }
            
            [[TIoTTRTCUIManage sharedManager] setDeviceDisConnectDic:@{@"DeviceId":device_Id?:@"",@"Offline":@(YES)}];
            
        }else if ([line_status isEqualToString:@"Online"]) {
            
//            self.coll.allowsSelection = YES;
        }else if ([line_status isEqualToString:@"Push"]) {
            if ([payloadDic[@"method"] isEqualToString:@"control"] ) {
                NSMutableDictionary *deviceReportDic = [NSMutableDictionary new];
                self.deviceReportData = [NSDictionary dictionaryWithDictionary:payloadDic[@"params"]];
                
                if ([payloadDic.allKeys containsObject:@"params"]) {
                    for (NSString *key in self.deviceReportData.allKeys) {
                        if (![NSString isNullOrNilWithObject:key]) {
                            [deviceReportDic setValue:@{@"Value":self.deviceReportData[key]?:@""} forKey:key];
                        }
                    }
                }
                //重新添加下发属性
                [self.deviceInfo zipData:self.configData baseInfo:self.DataTemplateDic deviceData:deviceReportDic];
                //原有属性数组去重
                self.deviceInfo.properties = [self removeDuplicationOriginalArr:self.deviceInfo.properties];
                self.deviceInfo.allProperties = [self removeDuplicationOriginalArr:self.deviceInfo.allProperties];
                //刷新UI
                [self layoutHeader];
                [self.coll reloadData];
                
                //设备UUID FFE2 写入属性值   取模板数据 self.DataTemplateDic （最全的，和控制台一致），deviceinfo.property 不全
                [self writePropertyInfoInFFE2WithDic:self.DataTemplateDic[@"properties"]?:@[] reportDic:payloadDic dataTemplate:TIoTDataTemplateTypeProperty];
                
            }else if ([payloadDic[@"method"] isEqualToString:@"action"]) {
                //设备UUID FFE2 写入行为调用
                //轮询找到下发actionID和接口请求的actionID 匹配（有可能是一个ID多个参数）
                if ([self.DataTemplateDic.allKeys containsObject:@"actions"]) {
                        
                        if ([payloadDic.allKeys containsObject:@"params"]) {
                            //TLV 数据
                            [self writePropertyInfoInFFE2WithDic:self.DataTemplateDic[@"actions"]?:@[] reportDic:payloadDic dataTemplate:TIoTDataTemplateTypeAction];
                        }
                }
            }
        }
    }
}

//设备属性数组去重
- (NSMutableArray *)removeDuplicationOriginalArr:(NSMutableArray *)oriArr {
    NSMutableArray *resuleProperty = [NSMutableArray array];
    for (NSDictionary *dic in oriArr) {
        if (![resuleProperty containsObject:dic]) {
            [resuleProperty addObject:dic];
        }
    }
    return resuleProperty;
}

//获取/检测固件版本 (确认固件升级任务)
- (void)checkfirmwarVersion {
    NSDictionary *paramDic = @{@"ProductId":self.productId?:@"",
                               @"DeviceName":self.deviceName?:@"",
    };
    [[TIoTRequestObject shared] post:AppCheckFirmwareUpdate Param:paramDic success:^(id responseObject) {
        self.firmwareModel = [TIoTFirmwareModel yy_modelWithJSON:responseObject];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

//上报固件版本
- (void)reportFirmwareVersionWithVersion:(NSString *)version {
    NSDictionary *paramDic = @{@"Version":version?:@"",
                               @"DeviceId":[NSString stringWithFormat:@"%@/%@",self.productId?:@"",self.deviceName?:@""],
    };
    
    [[TIoTRequestObject shared] post:AppReportFirmwareVersion Param:paramDic success:^(id responseObject) {
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

- (NSString *)getVersionWithString:(NSString *)originVersionString {
    NSString *versionString = @"";
    NSArray *versionArray = [originVersionString componentsSeparatedByString:@"."];
    for (NSString *numStr in versionArray) {
        versionString = [versionString stringByAppendingString:numStr];
    }
    return versionString;
}

#pragma mark - event

- (void)addEmptyCandidateModelTipView {
    
    CGFloat kButtonWidth = 146;
    
    [self.view addSubview:self.emptyImageView];
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat kSpaceHeight = 70; //距离中心偏移量
        if ([TIoTUIProxy shareUIProxy].iPhoneX) {
            kSpaceHeight = 150;
        }
        make.left.equalTo(self.view).offset(60);
        make.right.equalTo(self.view).offset(-60);
        make.centerY.mas_equalTo(kScreenHeight/2).offset(-kSpaceHeight);
        if ([TIoTUIProxy shareUIProxy].iPhoneX) {
            make.height.mas_equalTo(190);
        }else {
            make.height.mas_equalTo(160);
        }

    }];
    
    [self.view addSubview:self.noIntelligentLogTipLabel];
    [self.noIntelligentLogTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emptyImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *deleteDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteDeviceButton.layer.cornerRadius = 20;
    deleteDeviceButton.layer.borderWidth = 1;
    deleteDeviceButton.layer.borderColor = [UIColor colorWithHexString:kWarnHexColor].CGColor;
    [deleteDeviceButton setButtonFormateWithTitlt:NSLocalizedString(@"delete_device", @"删除设备") titleColorHexString:kWarnHexColor font:[UIFont wcPfRegularFontOfSize:16]];
    [deleteDeviceButton addTarget:self action:@selector(deleteDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteDeviceButton];
    [deleteDeviceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noIntelligentLogTipLabel.mas_bottom).offset(30);
        make.width.mas_equalTo(kButtonWidth);
        make.height.mas_equalTo(40);
        make.centerX.equalTo(self.view);
    }];
}

- (void)deleteDevice {
    
    if ([self.bleNewType isEqualToString:@"ble"]) {
        [[TIoTRequestObject shared] post:AppGetDeviceConfig Param:@{@"ProductId":self.productId?:@"",
                                                                    @"DeviceName":self.deviceName?:@"",
                                                                    @"DeviceKey":@"ble_psk_device_ket",
                                                                    @"TimestampKey":@"ble_timestamp_device_ket",
        } success:^(id responseObject) {
            TIoTLLSyncDeviceConfigModel *model = [TIoTLLSyncDeviceConfigModel yy_modelWithJSON:responseObject];
            DDLogVerbose(@"ble_psk_device_ket:%@",model.Configs.ble_psk_device_ket);
            if (![NSString isNullOrNilWithObject:model.Configs.ble_psk_device_ket]) {
                self.psk = model.Configs.ble_psk_device_ket;
                [self writeDeleteBlueDeviceInfo];
                [self deleteDeviceNetwork];
            }
        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            DDLogVerbose(@"ble_psk_device_ket error:%@",dic);
        }];
    }else {
        [self deleteDeviceNetwork];
    }
    
}

- (void)deleteDeviceNetwork {
    [[TIoTRequestObject shared] post:AppDeleteDeviceInFamily Param:@{@"FamilyId":self.deviceDic[@"FamilyId"],@"ProductID":self.deviceDic[@"ProductId"],@"DeviceName":self.deviceDic[@"DeviceName"]} success:^(id responseObject) {
        
        //解绑请求成功
        if ([self.bleNewType isEqualToString:@"ble"]) {
            [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1 LLDeviceInfo:@"07"];
        }
        
        [HXYNotice addUpdateDeviceListPost];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        //解绑请求失败
        if ([self.bleNewType isEqualToString:@"ble"]) {
            [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1 LLDeviceInfo:@"08"];
        }
    }];
}
- (void)moreClick:(UIButton *)sender{
    
    __weak typeof(self) weakSelf = self;
    TIoTPanelMoreViewController *vc = [[TIoTPanelMoreViewController alloc] init];
    vc.title = NSLocalizedString(@"device_details", @"设备详情");
    vc.deviceDic = self.deviceDic;
    vc.deleteDeviceRequest = ^{
        if (![NSString isNullOrNilWithObject:weakSelf.psk]) {
            [weakSelf writeDeleteBlueDeviceInfo];
        }else {
            [[TIoTRequestObject shared] post:AppGetDeviceConfig Param:@{@"ProductId":weakSelf.productId?:@"",
                                                                        @"DeviceName":weakSelf.deviceName?:@"",
                                                                        @"DeviceKey":@"ble_psk_device_ket",
                                                                        @"TimestampKey":@"ble_timestamp_device_ket",
            } success:^(id responseObject) {
                TIoTLLSyncDeviceConfigModel *model = [TIoTLLSyncDeviceConfigModel yy_modelWithJSON:responseObject];
                DDLogVerbose(@"ble_psk_device_ket:%@",model.Configs.ble_psk_device_ket);
                if (![NSString isNullOrNilWithObject:model.Configs.ble_psk_device_ket]) {
                    weakSelf.psk = model.Configs.ble_psk_device_ket;
                    [weakSelf writeDeleteBlueDeviceInfo];
                }
            } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
                DDLogVerbose(@"ble_psk_device_ket error:%@",dic);
            }];
        }
    };
    vc.deleteDeviceBlock = ^(BOOL isSuccess) {
        if (self.characteristicFFE1 != nil) {
            if (isSuccess == YES) {
                //解绑请求成功
                [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1 LLDeviceInfo:@"07"];
            }else {
                //失败
                [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1 LLDeviceInfo:@"08"];
            }
        }
        
    };
    [self.navigationController pushViewController:vc animated:YES];
}

//开关或者其他
- (void)bottomBarLeftTap
{
    NSDictionary *info;
    if ([self.templateId isEqualToString:self.deviceInfo.bigProp[@"id"]]) {
        info = self.deviceInfo.bigProp;
    }
    else
    {
        for (NSDictionary *pro in self.deviceInfo.properties) {
            if ([self.templateId isEqualToString:pro[@"id"]]) {
                info = pro;
            }
        }
    }
    
    NSDictionary *define = info[@"define"];
    if ([define[@"type"] isEqualToString:@"bool"]) {
        BOOL value = [info[@"status"][@"Value"] boolValue];
        [self reportDeviceData:@{self.templateId:@(!value)}];
    }
    
    
}

//定时
- (void)bottomBarRightTap
{
    TIoTTimerListVC *vc = [TIoTTimerListVC new];
    vc.productId = self.productId;
    vc.deviceName = self.deviceName;
    vc.actions = self.deviceInfo.allProperties;
    [self.navigationController pushViewController:vc animated:YES];
}

//连接蓝牙设备中
- (void)connectingBlueDeviceUI {
    [self.blueTipLabel setLabelFormateTitle:@"连接蓝牙中" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    
//    [self.controlBlueDeviceButton setButtonFormateWithTitlt:@"断开连接" titleColorHexString:@"#ffffff" font:[UIFont wcPfRegularFontOfSize:14]];
    
    self.controlBlueDeviceButton.layer.borderColor = [UIColor colorWithHexString:kNoSelectedHexColor].CGColor;
    
    self.controlBlueDeviceButton.backgroundColor = [UIColor colorWithHexString:kNoSelectedHexColor];
    self.blueConnectView.backgroundColor = [UIColor colorWithHexString:kNoSelectedHexColor];
    
}
//连接蓝牙设备成功
- (void)connectedSuccessBlueDeviceUI {
    
    [self.blueTipLabel setLabelFormateTitle:@"蓝牙已连接" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentLeft];
    [self.controlBlueDeviceButton setButtonFormateWithTitlt:@"断开连接" titleColorHexString:@"#ffffff" font:[UIFont wcPfRegularFontOfSize:14]];
    
    self.controlBlueDeviceButton.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
    
    self.controlBlueDeviceButton.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    self.blueConnectView.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    
    self.deviceConnectStatus = TIoTBlueDeviceConnected;
}
//蓝牙断开连接
- (void)disconnectedBlueDeviceUI {
    [self.blueTipLabel setLabelFormateTitle:@"蓝牙未连接" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.controlBlueDeviceButton setButtonFormateWithTitlt:@"立即连接" titleColorHexString:kIntelligentMainHexColor font:[UIFont wcPfRegularFontOfSize:14]];
    
    self.controlBlueDeviceButton.layer.borderColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
    
    self.controlBlueDeviceButton.backgroundColor = [UIColor colorWithHexString:kNoSelectedHexColor];
    self.blueConnectView.backgroundColor = [UIColor colorWithHexString:kNoSelectedHexColor];
    
    self.deviceConnectStatus = TIoTBlueDeviceDisconnected;
}
//无法连接蓝牙设备
- (void)connectedFailBlueDeviceUI {
    
    [self.blueTipLabel setLabelFormateTitle:@"无法连接蓝牙设备" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentLeft];
    [self.controlBlueDeviceButton setButtonFormateWithTitlt:@"重试连接" titleColorHexString:@"#ffffff" font:[UIFont wcPfRegularFontOfSize:14]];
    
    self.controlBlueDeviceButton.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
    
    self.controlBlueDeviceButton.backgroundColor = [UIColor colorWithHexString:kInputErrorTipHexColor];
    self.blueConnectView.backgroundColor = [UIColor colorWithHexString:kInputErrorTipHexColor];
    
    self.deviceConnectStatus = TIoTBlueDeviceConnectedFail;
}
//蓝牙适配器不可用(手机没开蓝牙)
- (void)noAdaptorBlueDeviceUI {
    [self.blueTipLabel setLabelFormateTitle:@"当前蓝牙适配器不可用" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#ffffff" textAlignment:NSTextAlignmentLeft];
    [self.controlBlueDeviceButton setButtonFormateWithTitlt:@"重试连接" titleColorHexString:@"#ffffff" font:[UIFont wcPfRegularFontOfSize:14]];
    
    self.controlBlueDeviceButton.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
    
    self.controlBlueDeviceButton.backgroundColor = [UIColor colorWithHexString:kInputErrorTipHexColor];
    self.blueConnectView.backgroundColor = [UIColor colorWithHexString:kInputErrorTipHexColor];
    
    self.deviceConnectStatus = TIoTBlueDeviceConnectedFail;
}

///MARK:控制连接蓝牙设备按钮
- (void)controlConnectBlueDevice:(UIButton *)button {
    switch (self.deviceConnectStatus) {
        case TIoTBlueDeviceConnected: {
            //目前已连接中，点击按钮断开
            [self.blueManager disconnectPeripheral];
            break;
        }
        case TIoTBlueDeviceDisconnected: {
            //目前未连接，点击立即连接
            if (self.blueDevices.count > 0) {
//                CBPeripheral *device = self.blueDevices[0];
                
                for (CBPeripheral *device in self.blueDevices) {
                    NSDictionary<NSString *,id> *advertisementData = self.originBlueDevices[device];
                    if ([advertisementData.allKeys containsObject:@"kCBAdvDataManufacturerData"]) {
                        NSData *manufacturerData = advertisementData[@"kCBAdvDataManufacturerData"];
                        NSString *hexstr = [NSString transformStringWithData:manufacturerData];
                        NSString *producthex = [hexstr substringWithRange:NSMakeRange(18, hexstr.length-18)];
                        NSString *productstr = [NSString stringFromHexString:producthex];
                        self.currentProductId = productstr;
                        
                        if ([advertisementData.allKeys containsObject:@"kCBAdvDataServiceUUIDs"]) {
                            NSNumber *connectHexstr = advertisementData[@"kCBAdvDataIsConnectable"];
                            NSArray *uuidArray = advertisementData[@"kCBAdvDataServiceUUIDs"];
                            if (![productstr isEqualToString:self.productId] && [uuidArray containsObject:[CBUUID UUIDWithString:@"FFE0"]] && [connectHexstr isEqual: @(1)]) {
                                [self.blueManager connectBluetoothPeripheral:device];
                                break;
                            }
                        }else if([productstr isEqualToString:self.productId]) {
                            [self.blueManager connectBluetoothPeripheral:device];
                            break;
                        }
                    }
                }
                
            }else {
                [self.blueManager scanNearLLSyncService];
            }
            break;
           
        }
        case TIoTBlueDeviceConnectedFail: {
            //重试,重新开始扫描外设
            [self.blueManager scanNearLLSyncService];
            break;
        }
        default:
            break;
    }
}

#pragma mark - BluetoothCentralManagerDelegate
//实时扫描外设（目前扫描10s）
- (void)scanPerpheralsUpdatePerpherals:(NSDictionary<CBPeripheral *,NSDictionary<NSString *,id> *> *)perphersArr {
    self.originBlueDevices = perphersArr;
    
    self.blueDevices = perphersArr.allKeys;
}

//连接外设成功
- (void)connectBluetoothDeviceSucessWithPerpheral:(CBPeripheral *)connectedPerpheral withConnectedDevArray:(NSArray <CBPeripheral *>*)connectedDevArray {
    self.currentConnectedPerpheral = connectedPerpheral;
}
//断开外设
- (void)disconnectBluetoothDeviceWithPerpheral:(CBPeripheral *)disconnectedPerpheral {
    self.currentConnectedPerpheral = nil;
    //断开蓝牙设备
    [self disconnectedBlueDeviceUI];
}

- (void)didDiscoverCharacteristicsWithperipheral:(CBPeripheral *)peripheral ForService:(CBService *)service  {
    [MBProgressHUD dismissInView:nil];
    if (self.currentConnectedPerpheral) {
        //本地计算绑定标识
        NSString *bindID = [NSString getBindIdentifierWithProductId:self.productId deviceName:self.deviceName];
        NSString *deviceBindId = @"";
        //设备广播绑定标识符
        if (self.originBlueDevices) {
            if (self.blueDevices.count > 0) {
                for (CBPeripheral *device in self.blueDevices) {
                    //                CBPeripheral *device = self.blueDevices[0];
                    NSDictionary<NSString *,id> *advertisementData = self.originBlueDevices[device];
                    if ([advertisementData.allKeys containsObject:@"kCBAdvDataManufacturerData"]) {
                        NSData *manufacturerData = advertisementData[@"kCBAdvDataManufacturerData"];
                        NSString *hexstr = [NSString transformStringWithData:manufacturerData];
                        NSString *productHex = [hexstr substringWithRange:NSMakeRange(22, hexstr.length-22)];
                        deviceBindId = [productHex uppercaseString];
                    }
                    
                    //判断绑定标识符和设备广播的是否一致
                    if ([bindID isEqualToString:deviceBindId]) {
                        for (CBCharacteristic *characteristic in service.characteristics) {
                            NSString *uuidFirstString = [characteristic.UUID.UUIDString componentsSeparatedByString:@"-"].firstObject;
                            //判断是否是纯蓝牙 LLSync
                            if ([uuidFirstString isEqualToString:@"0000FFE1"]) {
                                //LLSync
                                
                                self.characteristicFFE1 = characteristic;
                                
                                [self getLocalPskWithProductId:self.productId deviceName:self.deviceName];
                                break;
                            }
                        }
                    }
//                    else {
//                        [self connectedFailBlueDeviceUI];
//                        [self writeLinkResultInDeviceWithSuccess:NO];
//                    }
                }
            }
        }
    }
}

//发送数据后，蓝牙回调
- (void)updateData:(NSArray *)dataHexArray withCharacteristic:(CBCharacteristic *)characteristic pheropheralUUID:(NSString *)pheropheralUUID serviceUUID:(NSString *)serviceString {
    if (self.currentConnectedPerpheral) {
        NSString *hexstr = [NSString transformStringWithData:characteristic.value];
        if (hexstr.length < 2) {
            DDLogWarn(@"不支持的蓝牙设备，服务的回调数据不属于llsync --%@",self.currentConnectedPerpheral.name);
            return;
        }
        NSString *cmdtype = [hexstr substringWithRange:NSMakeRange(0, 2)];
        //连接鉴权成功 （连接子设备）
        if ([cmdtype isEqualToString:@"06"]) {
            
            //子设备上报
            [self uploadingMessage];
            
            //写入设备连接结果
            [self writeLinkResultInDeviceWithSuccess:YES];
        }else if ([cmdtype isEqualToString:@"07"]) {
            //解除鉴权成功 （解除绑定）
            [self.blueManager disconnectPeripheral];
        }else if ([cmdtype isEqualToString:@"08"]) {
            
            //连接蓝牙设备成功
            [self connectedSuccessBlueDeviceUI];
            
            //连接成功后 将连接结果写入设备后，设备返回
            [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1 LLDeviceInfo:@"090000"];
            
            //获取设备上报固件版本号
            NSString *firmwareVersionHexString = [hexstr substringFromIndex:14];
            NSString *versionString = [NSString stringFromHexString:firmwareVersionHexString]?:@"";
            
            NSString *currentString = [self getVersionWithString:versionString];
            NSString *desString = [self getVersionWithString:self.firmwareModel.DstVersion];
            
            //升级固件提示弹框
            [self chooseUpdateFirwareAlertWithCurrentVersion:currentString desVersion:desString];
            
            [self reportFirmwareVersionWithVersion:versionString];
            
        }else if ([cmdtype isEqualToString:@"00"]) {
            //设备属性上报 （设备主动上报）
            if (!self.isDeviceReporting == YES) {
                NSString *jsonString = [self getDeviceReportDataJsonWithPropertyValueHex:hexstr?:@"" typeString:@"properties" structHeaderHex:@""];
                NSDictionary *paramDic = @{@"ProductId":self.productId?:@"",
                                           @"DeviceName":self.deviceName?:@"",
                                           @"Data":jsonString,
                                           @"DataTimeStamp":@([NSString getNowTimeTimestamp].integerValue),
                };
                [self reportDataAsDeviceWithData:paramDic withReportType:TIoTDeviceReportTypeProperty];
                self.isDeviceReporting = YES;
            }
        }else if ([cmdtype isEqualToString:@"01"]) {
            //数据模版中的控制回复 control_reply
//            01000100     01 11
            NSString *resultStrin = [hexstr substringFromIndex:hexstr.length - 2];
            //蓝牙上报物模型数据到控制台
            NSString *jsonString = @"";
            if (self.deviceReportData != nil) {
                jsonString = [NSString objectToJson:self.deviceReportData];
            }
            
            NSDictionary *paramDic = @{@"ProductId":self.productId?:@"",
                                       @"DeviceName":self.deviceName?:@"",
                                       @"Data":jsonString,
                                       @"DataTimeStamp":@([NSString getNowTimeTimestamp].integerValue),
            };
            
            if ([resultStrin isEqualToString:@"00"]) { //成功
//                [MBProgressHUD showSuccess:@"设备上报成功"];
                [self reportDataAsDeviceWithData:paramDic withReportType:TIoTDeviceReportTypeNone];
            }else if ([resultStrin isEqualToString:@"01"]) { //失败
                [MBProgressHUD showSuccess:NSLocalizedString(@"device_report_fail", @"设备上报失败")];
            }else if ([resultStrin isEqualToString:@"11"]) { //数据解析错误
                [MBProgressHUD showSuccess:NSLocalizedString(@"analysis_deviceData_error", @"设备数据解析错误")];
            }
            
        }else if ([cmdtype isEqualToString:@"04"]) {
            //设备行为调用写入设备后，设备广播回调
            
            NSDictionary *responseDic = @{};
            NSString *responseString = @"";
            if (hexstr.length >= 10) {
               NSString *responseHexString = [hexstr substringFromIndex:10];
                if (![NSString isNullOrNilWithObject:responseHexString]) {
                    responseString = [NSString stringFromHexString:responseString];
                }
            }
            if ([NSString isNullOrNilWithObject:responseString]) {
                responseDic = @{};
            }
            
            NSString *resultString = [hexstr substringWithRange:NSMakeRange(6, 2)];
            NSNumber *code = @(0);
            if ([resultString isEqualToString:@"00"]) {
                code = @(0);
            }else if ([resultString isEqualToString:@"01"]) {
                code = @(1);
                [MBProgressHUD showSuccess:NSLocalizedString(@"device_action_reply_fail", @"设备行为回复消息失败")];
            }else if ([resultString isEqualToString:@"10"]) {
                [MBProgressHUD showSuccess:NSLocalizedString(@"analysis_deviceData_error", @"设备数据解析错误")];
                code = @(2);
            }
            
            NSDictionary *payload = @{@"method":@"action_reply",
                                      @"clientToken":self.deviceReportPayload[@"clientToken"],
                                      @"ActionId":self.deviceReportPayload[@"actionId"],
                                      @"timestamp":@([NSString getNowTimeString].integerValue),
                                      @"response":responseDic,
                                      @"code":code,
                                      @"status":@"action execute success!",
                                      
            };
            NSString *payloadString = [NSString objectToJson:payload];
            NSString *topicString = [NSString stringWithFormat:@"$thing/up/action/%@/%@",self.productId?:@"",self.deviceName?:@""];
            NSDictionary *paramDic = @{@"ProductId":self.productId?:@"",
                                       @"DeviceName":self.deviceName?:@"",
                                       @"Topic":topicString,
                                       @"Payload":payloadString,
                                       
            };
            
            [self reoprtPublishMsgAsDeviceWithData:paramDic];
        }else if ([cmdtype isEqualToString:@"09"]) {
            //OTA固件升级,发送升级请求包至设备成功后，设备应答
            NSString *indicateString = [hexstr substringWithRange:NSMakeRange(6, 2)];
            NSString *binaryString = [NSString getBinaryByHex:indicateString];
            
            //允许升级请求包的设备反馈payload
            NSString *allowUpatePayload = [hexstr substringFromIndex:8];
            
            //单次循环中可以连续传输的数据包个数，取值范围0x00 ~ 0xFF
            NSString *singlesendPagesNumber = [allowUpatePayload substringWithRange:NSMakeRange(0, 2)];
            //单个数据包大小，取值范围 0x00 ~ 0xF0
            NSString *singlepageSize = [allowUpatePayload substringWithRange:NSMakeRange(2, 4)];
            //数据包的超时重传周期，单位：秒
            NSString *pageOuttimeHex = [allowUpatePayload substringWithRange:NSMakeRange(4, 6)];
            NSInteger pageOuttimeInt = [NSString getDecimalByHex:pageOuttimeHex];
            //设备重启最大时间，单位：秒
            NSString *deviceRestartMaxHex = [allowUpatePayload substringWithRange:NSMakeRange(6, 8)];
            NSInteger deviceRestartMaxInt = [NSString getDecimalByHex:deviceRestartMaxHex];
            //断点续传前已接收文件大小
            NSString *resumeFileSize = [allowUpatePayload substringWithRange:NSMakeRange(8, 16)];
            //连续两个数据包的发包间隔
            NSString *intervalTime = [allowUpatePayload substringWithRange:NSMakeRange(16, 18)];
            
            
            /*说明:
              1.    不支持断点续传时，已接收文件大小恒为0。
              2.    小程序连续 5 个超时重传周期内没有收到设备端回应，认为升级失败。
              3.    设备重启最大时间是设备下载成功后重启设备，小程序等待设备上报新版本号的最大时间，超出此时间小程序认为升级失败
             */
            
            if ([binaryString isEqualToString:@"00000000"]) { //禁止升级
                //禁止升级payload
                NSString *forbidUpdatePayload = [allowUpatePayload substringWithRange:NSMakeRange(0, 2)];
                if ([forbidUpdatePayload isEqualToString:@"02"]) {
                    [MBProgressHUD showError:@"设备禁止升级,设备电量不足"];
                }else if ([forbidUpdatePayload isEqualToString:@"03"]) {
                    [MBProgressHUD showError:@"设备禁止升级,版本号错误"];
                }else {
                    [MBProgressHUD showError:@"设备禁止升级"];
                }
            }else if ([binaryString isEqualToString:@"000000001"]) { //允许升级
                [MBProgressHUD showError:@"设备允许开始升级"];
                //升级数据包
                [self updateDataPage];
                
                //上报后台进度开始升级数据包
                [self reportAppOTAStatusProgress:@"updating" versioin:self.firmwareModel.DstVersion persent:@(0)];
                
            }else if ([binaryString isEqualToString:@"00000010"]) { //不支持断点续传
                [MBProgressHUD showError:@"设备不支持断点续传"];
            }else if ([binaryString isEqualToString:@"00000011"]) {
                [MBProgressHUD showError:@"设备支持断点续传"];
            }else {
                //保留 暂时按成功传
            }
            
        }
    }
}


///MARK:升级数据包
- (void)updateDataPage {
    
}

///MARK:设备主动属性上报，解析上报属性类型（数据定义类型）(返回字典 : key 属性类型枚举 value 属性value长度)
- (NSDictionary *)getFirstTypeWithHexType:(NSString *)hexHeaderType {
    NSString *firstTypeBin = [NSString getBinaryByHex:hexHeaderType?:@""];
    NSString *typeHeightBit = [firstTypeBin substringWithRange:NSMakeRange(0, 3)];
    NSString *dataBytesLength = @"0";
    NSDictionary *resultDic;
    
    if ([typeHeightBit isEqualToString:@"000"]) { //TIoTDataTemplatePropertyTypeBool, //布尔  0
        dataBytesLength = @"1";
        resultDic = @{@(TIoTDataTemplatePropertyTypeBool):dataBytesLength};
    }else if ([typeHeightBit isEqualToString:@"001"]) { //TIoTDataTemplatePropertyTypeInt, //整数 1
        dataBytesLength = @"4";
        resultDic = @{@(TIoTDataTemplatePropertyTypeInt):dataBytesLength};
    }else if ([typeHeightBit isEqualToString:@"010"]) { //TIoTDataTemplatePropertyTypeString, //字符串 2
        dataBytesLength = @"-1";
        resultDic = @{@(TIoTDataTemplatePropertyTypeString):dataBytesLength};
    }else if ([typeHeightBit isEqualToString:@"011"]) { //TIoTDataTemplatePropertyTypeFloat, //浮点 3
        dataBytesLength = @"4";
        resultDic = @{@(TIoTDataTemplatePropertyTypeFloat):dataBytesLength};
    }else if ([typeHeightBit isEqualToString:@"100"]) { //TIoTDataTemplatePropertyTypeEnumerate, //枚举 4
        dataBytesLength = @"2";
        resultDic = @{@(TIoTDataTemplatePropertyTypeEnumerate):dataBytesLength};
    }else if ([typeHeightBit isEqualToString:@"101"]) { //TIoTDataTemplatePropertyTypeTimestamp, //时间 5
        dataBytesLength = @"4";
        resultDic = @{@(TIoTDataTemplatePropertyTypeTimestamp):dataBytesLength};
    }else if ([typeHeightBit isEqualToString:@"110"]) { //TIoTDataTemplatePropertyTypeStruct, //结构体 6
        dataBytesLength = @"-1";
        resultDic = @{@(TIoTDataTemplatePropertyTypeStruct):dataBytesLength};
    }else {
        resultDic = @{@(-1):dataBytesLength};
    }
    
    return resultDic;
    
}

- (NSString *)getPropertyTypeWithEnum:(TIoTDataTemplatePropertyType)propertyType {
    
    NSString *typeString = @"";
    if (propertyType == TIoTDataTemplatePropertyTypeBool) {
        typeString = @"bool";
    }else if (propertyType == TIoTDataTemplatePropertyTypeInt) {
        typeString = @"int";
    }else if (propertyType == TIoTDataTemplatePropertyTypeString) {
        typeString = @"string";
    }else if (propertyType == TIoTDataTemplatePropertyTypeFloat) {
        typeString = @"float";
    }else if (propertyType == TIoTDataTemplatePropertyTypeEnumerate) {
        typeString = @"enum";
    }else if (propertyType == TIoTDataTemplatePropertyTypeTimestamp) {
        typeString = @"timestamp";
    }else if (propertyType == TIoTDataTemplatePropertyTypeStruct) {
        typeString = @"struct";
    }else if (propertyType == TIoTDataTemplatePropertyTypeStringenum) {
        typeString = @"stringenum";
    }
    return typeString;
}

///MARK:设备主动属性上报后，获取完整的json字符串,用于APP上传后台
/**
 propertyValueHex : TVL协议 value hex
 itemPropertyTypeString : 属性类型properties 为一级属性 struct递归结构体获取json
 structHeaderHex : 如果是struct，需转第一个字节
 */
- (NSString *)getDeviceReportDataJsonWithPropertyValueHex:(NSString *)propertyValueHex typeString:(NSString *)itemPropertyTypeString structHeaderHex:(NSString *)structHeaderHex {
    NSString *jsonString = @"";
    if (![NSString isNullOrNilWithObject:propertyValueHex]) {
        __block NSMutableDictionary *jsonDic = [NSMutableDictionary new];
        
        if ([self.DataTemplateDic.allKeys containsObject:@"properties"]) {
            __block NSArray *propertyTemplate = self.DataTemplateDic[@"properties"];;
            //判断外层属性还是结构体
            if (![NSString isNullOrNilWithObject:itemPropertyTypeString]) {
                if ([itemPropertyTypeString isEqualToString:@"struct"]) {
                    NSArray *templateArray = self.DataTemplateDic[@"properties"];
                    
                    NSString *structHeaderBin = [NSString getBinaryByHex:structHeaderHex];
                    NSString *structHeaderTemp = [structHeaderBin substringWithRange:NSMakeRange(4, 4)];
                    NSInteger structHeaderInt = [NSString getDecimalByBinary:structHeaderTemp];
                    
                    [templateArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSDictionary *itemProperty = (NSDictionary *)obj;
                        NSDictionary *defineDic = itemProperty[@"define"]?:@{};
                        if ([defineDic.allKeys containsObject:@"specs"] && idx == structHeaderInt) {
                            propertyTemplate = defineDic[@"specs"];
                            *stop = YES;
                        }
                    }];
                }
            }
            
            //累计每个属性的起始index
            NSInteger index = 0;
            
            for (int i = 1; i<= propertyValueHex.length; i++) {
                   // 4            14       20  28                 38            66                         76       80
//                @"0001 | 2100000001 | 820000| 43000161 | a400bc614e | c5000b0001410001612200000001 | 6610069e3f | 0701";
//                0001410001612200000001
                if ((i-1)%2==0 && (index == (i-1))) {
                    
                    //获取type长度
                    NSString *typeHexString = [propertyValueHex substringWithRange:NSMakeRange(i-1, 2)];
                    NSDictionary *typeInfoDic = [self getFirstTypeWithHexType:typeHexString];
                    
                    NSString *firstTypeBin = [NSString getBinaryByHex:typeHexString?:@""];
                    NSString *typeLowBit = [firstTypeBin substringWithRange:NSMakeRange(4, 4)];
                    NSInteger typeIndex = [NSString getDecimalByBinary:typeLowBit];
                    
                    if (![typeInfoDic.allKeys containsObject:@"-1"] && typeInfoDic.allKeys.firstObject != nil) {
                        NSNumber *propertyTypeKey = typeInfoDic.allKeys.firstObject;
                        NSString *propertyLengthValue = typeInfoDic[propertyTypeKey];
                        
                        //type header 1字节
                        NSInteger typeHeader = 1;
                        NSInteger valueLength = 0;
                        
                        NSString *itemValueHex = @"";
                        NSInteger itemStart = 0; //每个属性起始位置
                        NSInteger valueLenHex = 0; //每个属性值长度
                        
                        if (propertyTypeKey.integerValue == TIoTDataTemplatePropertyTypeString || propertyTypeKey.integerValue == TIoTDataTemplatePropertyTypeStruct) {
                            //注：字符串和结构体需要加value的长度，llevent上报格式 length 定义2个字节  1*2为type
                            NSString *lengthHex = [propertyValueHex substringWithRange:NSMakeRange(index+1*2, 2*2)];
                            NSInteger lengthInt = [NSString getDecimalByHex:lengthHex];
                            valueLength = lengthInt + 2;
                            //字符串和结构体  1*2为type 2字节
                            itemStart = index+1*2 + 2*2;
                            valueLenHex = lengthInt*2;
                        }else {
                            valueLength = propertyLengthValue.integerValue;
                            //1*2为type
                            itemStart = index+1*2;
                            valueLenHex = propertyLengthValue.integerValue * 2;
                        }
                        index = index + (typeHeader + valueLength)*2; //字节*2
                        
                        itemValueHex = [propertyValueHex substringWithRange:NSMakeRange(itemStart, valueLenHex)];
                        
                        NSLog(@"---%ld",index);
                        
                        //根据模板对照获取
                        [propertyTemplate enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSDictionary *propertyInfo = obj;
                            NSString *key = @"define";
                            if ([itemPropertyTypeString isEqualToString:@"struct"]) {
                                key = @"dataType";
                            }
                            NSDictionary *defineDic = propertyInfo[key]?:@{};
                            NSString *typeString = defineDic[@"type"]?:@"";
                            NSString *reportTypeString = [self getPropertyTypeWithEnum:propertyTypeKey.integerValue];
                            //index，type 一致
                            if (idx == typeIndex && [reportTypeString isEqualToString:typeString]) {
                                NSString *idString = propertyInfo[@"id"]?:@"";
                                if (propertyTypeKey.integerValue == TIoTDataTemplatePropertyTypeString) {
                                    NSString *hexStr = [NSString stringFromHexString:itemValueHex];
                                    [jsonDic setValue:hexStr forKey:idString];
                                }else if (propertyTypeKey.integerValue == TIoTDataTemplatePropertyTypeStruct) {
                                    NSString *headerHex = [propertyValueHex substringWithRange:NSMakeRange(index-itemValueHex.length-2*2-2, 2)];
                                    NSString *structJson = [self getDeviceReportDataJsonWithPropertyValueHex:itemValueHex typeString:@"struct" structHeaderHex:headerHex];
                                    NSDictionary *jsonStructDic = [NSString jsonToObject:structJson];
                                    [jsonDic setValue:jsonStructDic?:@{} forKey:idString];
                                }else if (propertyTypeKey.integerValue == TIoTDataTemplatePropertyTypeFloat) {
                                    float floatValue = [NSString getFloatByHex:itemValueHex];
                                    [jsonDic setValue:@(floatValue) forKey:idString];
                                }else if (propertyTypeKey.integerValue == TIoTDataTemplatePropertyTypeInt || propertyTypeKey.integerValue == TIoTDataTemplatePropertyTypeEnumerate || propertyTypeKey.integerValue == TIoTDataTemplatePropertyTypeBool || propertyTypeKey.integerValue == TIoTDataTemplatePropertyTypeTimestamp){
                                    NSInteger intTypeValue = [NSString getDecimalByHex:itemValueHex];
                                    [jsonDic setValue:@(intTypeValue) forKey:idString];
                                }else {
                                    [jsonDic setValue:itemValueHex?:@"" forKey:idString];
                                }
                                
                                *stop = YES;
                            }
                        }];
                    }
                }
            }
            
            jsonString = [NSString objectToJson:jsonDic?:@{}];
        }
    }
    return jsonString;
}

///MARK:升级固件提示弹框
- (void)chooseUpdateFirwareAlertWithCurrentVersion:(NSString *)curVersioin desVersion:(NSString *)desVersion {
    NSString * currentString = curVersioin;
    NSString * desString = desVersion;
    
    if (currentString.floatValue < desString.floatValue) {
        if (![NSString isNullOrNilWithObject:[TIoTCoreUserManage shared].firmwareUpdate]) {
            
            //只显示一次弹框（先每次都提示，后续添加升级入口后，只弹一次）
            NSString *messgeString = [NSString stringWithFormat:@"%@%@\n%@%@",NSLocalizedString(@"current_Version", @"当前固件版本为"),self.firmwareModel.CurrentVersion,NSLocalizedString(@"last_Version", @"当前固件版本为"),self.firmwareModel.DstVersion];
            self.firmwareView = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds withTopImage:nil];
            [self.firmwareView alertWithTitle:NSLocalizedString(@"firmware_update", @"可升级固件") message:messgeString  cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"update_now", @"立即升级")];
            self.firmwareView.cancelAction = ^{
            };
            [self.firmwareView setAlertViewContentAlignment:TextAlignmentStyleCenter];
            __weak typeof(self) weakSelf = self;
            self.firmwareView.doneAction = ^(NSString * _Nonnull text) {
                //上报开始下载 下载进度 下载完成
                
                //获取升级包URL后，开始下载
                [weakSelf getFrimwareOTAURL];
            };
            
            self.backMaskView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].delegate.window.frame];
            [[UIApplication sharedApplication].delegate.window addSubview:self.backMaskView];
            [self.firmwareView showInView:self.backMaskView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAlertView)];
            [self.backMaskView addGestureRecognizer:tap];
            
            [TIoTCoreUserManage shared].firmwareUpdate = @"1";
        }
    }
}

///MARK: 获取固件升级包URL
- (void)getFrimwareOTAURL {
    NSDictionary *paramDic = @{
                               @"DeviceId":[NSString stringWithFormat:@"%@/%@",self.productId?:@"",self.deviceName?:@""]
    };
    [[TIoTRequestObject shared] post:AppGetDeviceOTAInfo Param:paramDic success:^(id responseObject) {
        TIoTFirmwareOTAInfoModel *firmwareOTAInfo = [TIoTFirmwareOTAInfoModel yy_modelWithJSON:responseObject];
        //开始下载固件包上报
        [self reportAppOTAStatusProgress:@"downloading" versioin:self.firmwareModel.DstVersion persent:@(0)];
        //下载升级包
        [self downloadUpdateInfoURL:firmwareOTAInfo.FirmwareURL?:@""];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

///MARK:下载升级包
- (void)downloadUpdateInfoURL:(NSString *)urlString {
    
    NSURL* url = [NSURL URLWithString:urlString?:@""];
    
    NSURLSession* session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask* downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *fileName = [NSString stringWithFormat:@"%@%@_%@",self.productId,self.deviceName,self.firmwareModel.DstVersion];
        NSString *file = [caches stringByAppendingPathComponent:fileName];
        
        //将临时文件剪切或者复制Caches文件夹
        NSFileManager *manager = [NSFileManager defaultManager];
        
        //先清除，在写入
        if ([manager fileExistsAtPath:file]) {
            [manager removeItemAtPath:file error:nil];
        }
        
        // AtPath 原始文件路径
        // ToPath 目标文件路径
        [manager moveItemAtPath:location.path toPath:file error:nil];
        NSLog(@"download firmware file path :%@",file);
//        NSLog(@"Documentsdirectory: %@",
//        [manager contentsOfDirectoryAtPath:file error:nil]);
        NSData *fileData = [NSData dataWithContentsOfFile:file];
        NSLog(@"file data :%@",fileData);
        //发送升级请求包到设备
        [self sendFirmwareUpdateInfoToDeviceWithData:fileData];
        
        //下载固件包完成后上报
        [self reportAppOTAStatusProgress:@"downloading" versioin:self.firmwareModel.DstVersion persent:@(100)];
    }];
    // 开始任务
    [downloadTask resume];
    
}

///MARK:发送升级请求包到设备
- (void)sendFirmwareUpdateInfoToDeviceWithData:(NSData *)data {
    NSData *fileConentData = data;
    //type
    NSString *typeString = @"00";
    //value: file size
    NSString *dataLengthHexTemp = [NSString getHexByDecimal:fileConentData.length];
    NSString *dataLengthHex = [self getTVLValueWithOriginValue:dataLengthHexTemp bitString:@"00000000"];
    //value: file crc
    uLong crc32 = [self getCRC32ResultWithData:fileConentData];
    NSString *crcHexTemp = [NSString getHexByDecimal:crc32];
    NSString *crcHex = [self getTVLValueWithOriginValue:crcHexTemp bitString:@"00000000"];
    //value: file version
    NSString *fileVersionHex = [NSString hexStringFromString:self.firmwareModel.DstVersion];
    //value: file version len
    NSInteger versionLen = fileVersionHex.length/2;
    NSString *versionLengthHexTemp = [NSString getHexByDecimal:versionLen];
    NSString *versionLengthHex = [self getTVLValueWithOriginValue:versionLengthHexTemp bitString:@"00"];
    //Value 总长度
    NSInteger valueLen = (dataLengthHex.length + crcHex.length + fileVersionHex.length + versionLengthHex.length)/2;
    NSString *valueLengthTemp = [NSString getHexByDecimal:valueLen];
    NSString *valueLength = [self getTVLValueWithOriginValue:valueLengthTemp bitString:@"0000"];
    
    NSString *writeInfo = [NSString stringWithFormat:@"%@%@%@%@%@%@",typeString,valueLength,dataLengthHex,crcHex,versionLengthHex,fileVersionHex];
    
    [self writPropertyInfoInUUIDDeviceWithMessage:writeInfo UUIDString:FFE4UUIDString];
}

- (uLong)getCRC32ResultWithData:(NSData *)data {
    uLong crc = crc32(0L, Z_NULL, 0);
    crc = crc32(crc, data.bytes, (int)data.length);
    return crc;
}

///MARK:APP上报进度（下载，升级更新，烧录）
//status:downloading updating burning
- (void)reportAppOTAStatusProgress:(NSString *)status versioin:(NSString *)version persent:(NSNumber *)persent {
    NSDictionary *paramDic = @{@"DeviceId":[NSString stringWithFormat:@"%@/%@",self.productId?:@"",self.deviceName?:@""],
                               @"State":status?:@"",
                               @"ResultCode":@(0),
                               @"ResultMsg":@"",
                               @"Version":version?:@"",
                               @"Persent":persent,
                               
    };
    [[TIoTRequestObject shared] post:AppReportOTAStatus Param:paramDic success:^(id responseObject) {
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

///MARK:查询设备固件升级状态
- (void)checkDeviceFirmwareUpateStatus {
    NSDictionary *paramDic = @{@"ProductId":self.productId?:@"",
                               @"DeviceName":self.deviceName?:@"",
    };
    
    [[TIoTRequestObject shared] post:AppDescribeFirmwareUpdateStatus Param:paramDic success:^(id responseObject) {
        TIoTFirmwareUpdateStatusModel *updateStatusModel = [TIoTFirmwareUpdateStatusModel yy_modelWithJSON:responseObject];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}
///MARK:蓝牙设备属性上报物模型数据到控制台
- (void)reportDataAsDeviceWithData:(NSDictionary *)paramDic withReportType:(TIoTDeviceReportType)reportType {
    [[TIoTRequestObject shared] post:AppReportDataAsDevice Param:paramDic success:^(id responseObject) {
        TIoTReportDataAsDeviceModel *reportData = [TIoTReportDataAsDeviceModel yy_modelWithJSON:responseObject];
        NSDictionary *data = [NSString jsonToObject:reportData.Data]?:@{};
        TIoTReportDataAsDeviceResultModel *resultModel = [TIoTReportDataAsDeviceResultModel yy_modelWithJSON:data];
        if (resultModel.code.integerValue > 400 ) {
            [self writPropertyInfoInUUIDDeviceWithMessage:@"0201" UUIDString:FFE4UUIDString];
        }else if (resultModel.code.integerValue == 0) {
            [self writPropertyInfoInUUIDDeviceWithMessage:@"0200" UUIDString:FFE4UUIDString];
        }
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        if (reportType == TIoTDeviceReportTypeProperty) {
            [self writPropertyInfoInUUIDDeviceWithMessage:@"0201" UUIDString:FFE4UUIDString];
        }else if (reportType == TIoTDeviceReportTypeEvent) {
            
        }else if (reportType == TIoTDeviceReportTypeNewData) {
            
        }
    }];
}

///MARK:蓝牙设备行为回复消息（上报控制台）
-(void)reoprtPublishMsgAsDeviceWithData:(NSDictionary *)paramDic {
    [[TIoTRequestObject shared] post:AppPublishMsgAsDevice Param:paramDic success:^(id responseObject) {
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

///MARK: 子设备上报
- (void)uploadingMessage {
    
}

///MARK:将连接结果写入设备
- (void)writeLinkResultInDeviceWithSuccess:(BOOL)isSuccess {
    if (isSuccess == YES) {
        [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1?:[CBCharacteristic new] LLDeviceInfo:@"05"];
    }else {
        [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1?:[CBCharacteristic new] LLDeviceInfo:@"06"];
    }

}

/// MARK: 获取local psk
- (void)getLocalPskWithProductId:(NSString *)productId  deviceName:(NSString *)deviceName {
    
    [[TIoTRequestObject shared] post:AppGetDeviceConfig Param:@{@"ProductId":productId?:@"",
                                                                @"DeviceName":deviceName?:@"",
                                                                @"DeviceKey":@"ble_psk_device_ket",
                                                                @"TimestampKey":@"ble_timestamp_device_ket",
    } success:^(id responseObject) {
        TIoTLLSyncDeviceConfigModel *model = [TIoTLLSyncDeviceConfigModel yy_modelWithJSON:responseObject];
        DDLogVerbose(@"ble_psk_device_ket:%@",model.Configs.ble_psk_device_ket);
        [self writeBlueDeviceInfoWithDeviceCongModel:model];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        DDLogVerbose(@"ble_psk_device_ket error:%@",dic);
    }];
}

- (void)writeBlueDeviceInfoWithDeviceCongModel:(TIoTLLSyncDeviceConfigModel *)deviceModel {
    self.psk = deviceModel.Configs.ble_psk_device_ket?:@"";
    //TS
    NSString *timeStamp = [NSString getNowTimeString];
    self.timeStampString = timeStamp;
    //10进制转16进制
    NSString *tempTimeHex = [NSString getHexByDecimal:timeStamp.integerValue];
    
    //Sign info
    NSString *timeStampSignInfo = [NSString HmacSha1_Keyhex:self.psk data:timeStamp];
    
    NSString *writeInfo = [NSString stringWithFormat:@"010018%@%@",tempTimeHex,timeStampSignInfo];
    [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1 LLDeviceInfo:writeInfo];
}

//删除设备写入信息
- (void)writeDeleteBlueDeviceInfo {
    //Sign info
    NSString *unBindedRequestSignInfo = [NSString HmacSha1_Keyhex:self.psk data:@"UnbindRequest"];
    NSString *writeInfo = [NSString stringWithFormat:@"040014%@",unBindedRequestSignInfo];
    if (self.characteristicFFE1 != nil) {
        [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1 LLDeviceInfo:writeInfo];
    }
}

///MARK: 设备远程控制- UUID FFE2中写入property值 （控制台下发）
- (void)writePropertyInfoInFFE2WithDic:(NSArray *)propertyArray reportDic:(NSDictionary *)reportDic dataTemplate:(TIoTDataTemplateType)type{
    
    NSDictionary *dic = reportDic[@"params"]?:@{};
    
    //按格式组装设备需要数据（int enum bool，需要扩充float）
    
    if (propertyArray.count != 0) {
        NSString *value = @"";
        
        // property 类别
        if (type == TIoTDataTemplateTypeProperty) {
            for (NSDictionary *propertyDic in propertyArray) {
                NSDictionary *defineDic = propertyDic[@"define"]?:@{};
                NSString *dataTypeString = defineDic[@"type"]?:@"";
    //            NSString *dataTypeString = propertyDic[@"dataType"]?:@"";
                NSString *idString = propertyDic[@"id"]?:@"";
                if (self.deviceReportData != nil) {
                    
                    if (![NSString isNullOrNilWithObject:dataTypeString] && [self.deviceReportData.allKeys containsObject:idString]) {
                        if ([dataTypeString isEqualToString:@"int"]) {

                            NSString * IDValueString = [self setPropertyReportDeviceInfoWithType:TIoTDataTemplatePropertyTypeInt reportDic:dic idString:idString dataTypeString:dataTypeString];
                            //拼接value
                            value = [value stringByAppendingString:IDValueString];
                        }else if ([dataTypeString isEqualToString:@"bool"]) {
                            
                            NSString * IDValueString = [self setPropertyReportDeviceInfoWithType:TIoTDataTemplatePropertyTypeBool reportDic:dic idString:idString dataTypeString:dataTypeString];
                            //拼接value
                            value = [value stringByAppendingString:IDValueString];
                        }else if ([dataTypeString isEqualToString:@"enum"]) {
                            NSString * IDValueString = [self setPropertyReportDeviceInfoWithType:TIoTDataTemplatePropertyTypeEnumerate reportDic:dic idString:idString dataTypeString:dataTypeString];
                            //拼接value
                            value = [value stringByAppendingString:IDValueString];
                        }else if ([dataTypeString isEqualToString:@"float"]) {
                            
                        }
                        
                    }
                }

            }
            
            NSString *typeString = @"00";
            NSInteger length = value.length/2;
            NSString *lengthHex = [NSString getHexByDecimal:length];
            NSString *lengthResult = [self getMutableValueLength:lengthHex];
            //写入设备
            NSString *writeInfoString = [NSString stringWithFormat:@"%@%@%@",typeString,lengthResult,value];
            [self writPropertyInfoInUUIDDeviceWithMessage:writeInfoString UUIDString:FFE2UUIDString];
            
        }else if (type == TIoTDataTemplateTypeAction) {
            
            //action 类别  先算value 再算fixed 后算length
            //计算 action LLData value值(TVL) （TVL协议中 type + length（可选） +value; 字符串和结构体需要加拼接length）
            NSString *valueString = @"";
            NSString *bitSting = @"00000";
            
            NSString *actionID = reportDic[@"actionId"]?:@""; //上报dic中的ID
            for (NSDictionary *propertyDic in propertyArray) {
                NSString *idString = propertyDic[@"id"]?:@"";//原始数据模板action中的每种类型ID
                if (![NSString isNullOrNilWithObject:actionID] && [actionID isEqualToString:idString]) {
                    NSArray *inputArray = propertyDic[@"input"]?:@{};
                    if (inputArray.count != 0) {
                        for (int i = 0; i<inputArray.count; i++) {
                            NSDictionary *actionDic = inputArray[i]?:@{};
                            
                            
                            NSString *typePreString = @"";
                            //action中每项ID值
                            NSString *tempIDValue = [NSString getBinaryByDecimal:i];
                            
                            NSDictionary *defineDic = actionDic[@"define"]?:@{};
                            NSString *typeString = defineDic[@"type"]?:@"";
                            if ([typeString isEqualToString:@"int"]) {
                                typePreString = @"001";
                                
                            }else if ([typeString isEqualToString:@"bool"]) {
                                typePreString = @"000";
                                
                            }else if ([typeString isEqualToString:@"enum"]) {
                                typePreString = @"100";
                            }else if ([typeString isEqualToString:@"float"]) {
                                typePreString = @"011";
                            }else if ([typeString isEqualToString:@"timestamp"]) {
                                typePreString = @"101";
                            }else if ([typeString isEqualToString:@"string"]) {
                                typePreString = @"010";
                            }else if ([typeString isEqualToString:@"stringenum"]) {
                                typePreString = @"100";
                            }
                            
                            NSString *preTempIDValue = [bitSting substringToIndex:bitSting.length - tempIDValue.length];
                            NSString *resultIDValue= [NSString stringWithFormat:@"%@%@",preTempIDValue,tempIDValue];
                            NSString *tempValue = [NSString stringWithFormat:@"%@%@",typePreString,resultIDValue];
                            //TVL Type 计算 将2进制转16进制 1Byte
                            NSString *TVLType = [NSString getHexByBinary:tempValue]; //type
                            
                            //TVL value 计算  （多个数据需要拼接）
                            NSString *value = [self getMutableValueWithDefineDic:actionDic  reportDic:dic];
                            NSString *resultValue = [NSString stringWithFormat:@"%@%@",TVLType,value];
                            valueString = [valueString stringByAppendingString:resultValue];
                        }
                    }
                }
            }
            
            //action LLData Fixed Header
            NSString *fixedHeader = @"";
            NSArray *actionArray = self.DataTemplateDic[@"actions"]?:@[];
            if (actionArray.count != 0) {
                //拼接lldata type
                fixedHeader = [self getLLDataFixedHeaderDataTemplate:TIoTLLDataFixedHeaderDataTemplateTypeAction dataDefine:@"0" payloadDic:reportDic actionOrEventArray:actionArray];
            }
            
            //action LLData length
            NSInteger length = valueString.length/2;
            NSString *lengthHex = [NSString getHexByDecimal:length];
            NSString *lengthResult = [self getMutableValueLength:lengthHex];
            //写入设备
            NSString *writeInfoString = [NSString stringWithFormat:@"%@%@%@",fixedHeader,lengthResult,valueString];
            [self writPropertyInfoInUUIDDeviceWithMessage:writeInfoString UUIDString:FFE2UUIDString];
            
        }else if (type == TIoTDataTemplateTypeEvent) {
            //event 类别
        }
        
    }
}

///MARK: llData TVL 中的 value
- (NSString *)getMutableValueWithDefineDic:(NSDictionary *)actionDic reportDic:(NSDictionary *)dic {
    NSString *inputIDString = actionDic[@"id"]?:@"";   //
    NSString *TVLValue = @"";
    NSDictionary *defineDic = actionDic[@"define"];
    NSString *typeString = defineDic[@"type"]?:@"";
    
    if (dic.allKeys.count != 0) {
        for (int j = 0; j < dic.allKeys.count; j++) {
            if (![NSString isNullOrNilWithObject:inputIDString] && [inputIDString isEqualToString:dic.allKeys[j]]) {
                
                NSString *origionValue = dic[inputIDString]?:@"";
                
                if ([typeString isEqualToString:@"int"]) {
                    NSString *bitSting = @"00000000";
                    NSString *tempHexValue = [NSString getHexByDecimal:origionValue.integerValue];
                    TVLValue= [self getTVLValueWithOriginValue:tempHexValue bitString:bitSting];
                    
//                    TVLValue = [TVLValue stringByAppendingString:resultHexValue];
                    break;
                }else if ([typeString isEqualToString:@"bool"]) {
                    NSString *bitSting = @"00";
                    NSString *tempHexValue = [NSString getHexByDecimal:origionValue.integerValue];
                    TVLValue= [self getTVLValueWithOriginValue:tempHexValue bitString:bitSting];
                    
//                    TVLValue = [TVLValue stringByAppendingString:resultHexValue];
                    break;
                }else if ([typeString isEqualToString:@"enum"]) {
                    NSString *bitSting = @"0000";
                    NSString *tempHexValue = [NSString getHexByDecimal:origionValue.integerValue];
                    TVLValue= [self getTVLValueWithOriginValue:tempHexValue bitString:bitSting];
                    
//                    TVLValue = [TVLValue stringByAppendingString:resultHexValue];
                    break;
                }else if ([typeString isEqualToString:@"float"]) {
                    NSString *bitSting = @"00000000";
                    NSString *tempHexValue = [NSString getHexByDecimal:origionValue.floatValue];
                    TVLValue= [self getTVLValueWithOriginValue:tempHexValue bitString:bitSting];
                    
//                    TVLValue = [TVLValue stringByAppendingString:resultHexValue];
                    break;
                }else if ([typeString isEqualToString:@"timestamp"]) {
                    NSString *bitSting = @"00000000";
                    NSString *tempHexValue = [NSString getHexByDecimal:origionValue.integerValue];
                    TVLValue = [self getTVLValueWithOriginValue:tempHexValue bitString:bitSting];
                    
//                    TVLValue = [TVLValue stringByAppendingString:resultHexValue];
                    break;
                }else if ([typeString isEqualToString:@"string"]) {
                    NSString *originHexString = [NSString hexStringFromString:origionValue];
                    NSString *bitSting = @"";
                    for (int i = 0; i<originHexString.length/2; i++) {
                        bitSting = [bitSting stringByAppendingString:@"00"];
                    }
                    NSString *stringValue = [self getTVLValueWithOriginValue:originHexString bitString:bitSting];
                    
                    //需要在value前拼接length
                    NSString *lengthHex = [NSString getHexByDecimal:originHexString.length/2];
                    NSString *lengthBit = @"0000";
                    NSString *tempHexLength = [self getTVLValueWithOriginValue:lengthHex bitString:lengthBit];
                    TVLValue = [NSString stringWithFormat:@"%@%@",tempHexLength,stringValue];
                    break;
                }else if ([typeString isEqualToString:@"stringenum"]) {
                    NSString *originHexString = [NSString hexStringFromString:origionValue];
                    NSString *bitSting = @"";
                    for (int i = 0; i<originHexString.length/2; i++) {
                        bitSting = [bitSting stringByAppendingString:@"00"];
                    }
                    NSString *stringValue = [self getTVLValueWithOriginValue:originHexString bitString:bitSting];
                    
                    //需要在value前拼接length
                    NSString *lengthHex = [NSString getHexByDecimal:originHexString.length/2];
                    NSString *lengthBit = @"0000";
                    NSString *tempHexLength = [self getTVLValueWithOriginValue:lengthHex bitString:lengthBit];
                    TVLValue = [NSString stringWithFormat:@"%@%@",tempHexLength,stringValue];
                    break;
                    
                    break;
                }
            }
        }
    }
    
    return TVLValue;
}

///MARK:获取TVL协议中 Value (hex)  originHexValue (hex) bitString:(hex)
- (NSString *)getTVLValueWithOriginValue:(NSString *)originHexValue bitString:(NSString *)bitString {
    NSString *value = @"";
    NSString *preTempHexValue = [bitString substringToIndex:bitString.length - originHexValue.length];
    NSString *resultHexValue= [NSString stringWithFormat:@"%@%@",preTempHexValue,originHexValue];
    value = resultHexValue;
    return value;
}

///MARK: 多个属性 llData control操作 数据长度
- (NSString *)getMutableValueLength:(NSString *)lengthHex {
    //固定为两个字节
    NSString *bitString = @"0000";
    NSString *preTempLengthValue = [bitString substringToIndex:bitString.length - lengthHex.length];
    NSString *resultLengthValue= [NSString stringWithFormat:@"%@%@",preTempLengthValue,lengthHex];
    return resultLengthValue;
}

///MARK: 拼接 llData control操作 数据
- (NSString *)setPropertyReportDeviceInfoWithType:(TIoTDataTemplatePropertyType)typeValue reportDic:(NSDictionary *)dic idString:(NSString *)idString dataTypeString:(NSString *)dataTypeString {
    
    //length
    NSString *lengthString = @"";
    if (typeValue == TIoTDataTemplatePropertyTypeBool) { //布尔
        lengthString = @"0002";
    }else if (typeValue == TIoTDataTemplatePropertyTypeInt) { //int
        lengthString = @"0005";
    }else if (typeValue == TIoTDataTemplatePropertyTypeString) { //string
        
    }else if (typeValue == TIoTDataTemplatePropertyTypeFloat) { //float
        
    }else if (typeValue == TIoTDataTemplatePropertyTypeEnumerate) { //enumerate
        lengthString = @"0003";
    }else if (typeValue == TIoTDataTemplatePropertyTypeTimestamp) { //timestamp
        
    }else if (typeValue == TIoTDataTemplatePropertyTypeStruct) { //struct
        
    }
    
    //property value  TVL
    //IdValueString
    NSMutableArray *IDNumberArray = [self getPropertyIndexWithType:dataTypeString];
    //value
    NSString *valueString = @"";
    if ([dic.allKeys containsObject:idString]) {
        NSNumber *valueNumber = dic[idString]?:@(0);
        for (NSNumber *idNumber in IDNumberArray) {
            //头字节
            NSString *typeValueString = [self getTLVIDValue:idNumber.integerValue type:typeValue];

            NSString *valueHex = [self getTLVValue:valueNumber.integerValue type:typeValue];
            valueString = [NSString stringWithFormat:@"%@%@",typeValueString,valueHex];
        }
    }
    
    return valueString;
//    NSString *valueString = @"";
//    if ([dic.allKeys containsObject:idString]) {
//        NSNumber *valueNumber = dic[idString]?:@(0);
//        for (NSNumber *idNumber in IDNumberArray) {
//            //头字节
//            NSString *typeValueString = [self getTLVIDValue:idNumber.integerValue type:typeValue];
//
//            NSString *valueHex = [self getTLVValue:valueNumber.integerValue type:typeValue];
//            valueString = [NSString stringWithFormat:@"%@%@",typeValueString,valueHex];
//
//            //写入设备
//            NSString *writeInfoStrin = [NSString stringWithFormat:@"%@%@%@",typeString,lengthString,valueString];
//            [self writPropertyInfoInFFE2DeviceWithMessage:writeInfoStrin];
//        }
//
//    }
}

//获取下发属性在设备模板中index (TLV协议中Type 中 ID值)
- (NSMutableArray *)getPropertyIndexWithType:(NSString *)dataTypeString {
    NSMutableArray *idNumberArra = [NSMutableArray new];
    
    __block NSInteger IDNumber = 0;
    NSArray *propertyArr = self.DataTemplateDic[@"properties"]?:@[];
    
    [propertyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *propertyDic = obj;
        for (NSString *idkeyString in self.deviceReportData.allKeys) {
            if ([propertyDic.allKeys containsObject:@"define"]) {
                NSDictionary *defineDic = propertyDic[@"define"]?:@{};
                NSString *typeKey = defineDic[@"type"]?:@"";
                NSString *IDKey = propertyDic[@"id"]?:@"";
                if (![NSString isNullOrNilWithObject:typeKey] && [typeKey isEqualToString:dataTypeString] && [IDKey isEqualToString:idkeyString]) {
                    IDNumber = idx;
                    [idNumberArra addObject:@(IDNumber)];
                    break;
                    *stop = YES;
                }
            }
        }
        
    }];
    return idNumberArra;
}

///MARK:拼接获取 LLdata Fixed header  （property event action 数据模板协议交互用）
///fixedType : property event action
///requestOrReply: 0 request  1 reply
///payloadDic : 上报payloadDic
///dataArray:原始数据模板中action/event 数组
-(NSString *)getLLDataFixedHeaderDataTemplate:(TIoTLLDataFixedHeaderDataTemplateType)fixedType  dataDefine:(NSString *)requestOrReply payloadDic:(NSDictionary *)payloadDic actionOrEventArray:(NSArray *)dataArray {
    NSString *fixedString = @"";
    NSString *dataTemplateString = @"";
    
    //data template
    if (fixedType == TIoTLLDataFixedHeaderDataTemplateTypeProperty) {
        dataTemplateString = @"00";
    }else if (fixedType == TIoTLLDataFixedHeaderDataTemplateTypeEvent) {
        dataTemplateString = @"01";
    }else if (fixedType == TIoTLLDataFixedHeaderDataTemplateTypeAction) {
        dataTemplateString = @"10";
    }
    
    //dataDefine
    NSString *dataDefineString = requestOrReply?:@"";
    
    //ID 轮询查询
    NSString *bitSting = @"00000";
    __block NSInteger idValue = 0;
    if (payloadDic != nil) {
        NSString *actionID = payloadDic[@"actionId"]?:@"";
        if (dataArray.count != 0) {
            [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *actionDic = obj;
                NSString *IDString = actionDic[@"id"]?:@"";
                if (![NSString isNullOrNilWithObject:actionID] && [actionID isEqualToString:IDString]) {
                    idValue = idx;
                }
            }];
        }
        
    }
    
    NSString *tempIDValue = [NSString getBinaryByDecimal:idValue];
    //拼接TVL Type 1 Byte
    NSString *preTempIDValue = [bitSting substringToIndex:bitSting.length - tempIDValue.length];
    NSString *resultIDValue= [NSString stringWithFormat:@"%@%@",preTempIDValue,tempIDValue];
    NSString *tempValue = [NSString stringWithFormat:@"%@%@%@",dataTemplateString,dataDefineString,resultIDValue];
    //将2进制转16进制 1Byte
    fixedString = [NSString getHexByBinary:tempValue];
    
    return fixedString;
}

/// MARK:获取TLV协议中 type Header Value
- (NSString *)getTLVIDValue:(NSInteger)idValue type:(TIoTDataTemplatePropertyType)typeValue {
    NSString *bitSting = @"00000";
    NSString *preType = @"";
    NSString *valueSting = @"";
    
    if (typeValue == TIoTDataTemplatePropertyTypeBool) { //布尔
        preType = @"000";
    }else if (typeValue == TIoTDataTemplatePropertyTypeInt) { //int
        preType = @"001";
    }else if (typeValue == TIoTDataTemplatePropertyTypeString) { //string
        
    }else if (typeValue == TIoTDataTemplatePropertyTypeFloat) { //float
        
    }else if (typeValue == TIoTDataTemplatePropertyTypeEnumerate) { //enumerate
        preType = @"100";
    }else if (typeValue == TIoTDataTemplatePropertyTypeTimestamp) { //timestamp
        
    }else if (typeValue == TIoTDataTemplatePropertyTypeStruct) { //struct
        
    }
    
    NSString *tempIDValue = [NSString getBinaryByDecimal:idValue];
    //拼接TVL Type 1 Byte
    NSString *preTempIDValue = [bitSting substringToIndex:bitSting.length - tempIDValue.length];
    NSString *resultIDValue= [NSString stringWithFormat:@"%@%@",preTempIDValue,tempIDValue];
    NSString *tempValue = [NSString stringWithFormat:@"%@%@",preType,resultIDValue];
    //将2进制转16进制 1Byte
    valueSting = [NSString getHexByBinary:tempValue];
    return valueSting;
}

/// MARK:获取TLV协议中 Value
- (NSString *)getTLVValue:(NSInteger)value type:(TIoTDataTemplatePropertyType )typeValue {
    NSString *bitSting = @"";
    if (typeValue == TIoTDataTemplatePropertyTypeBool) { //布尔 1Byte
        bitSting = @"00";
    }else if (typeValue == TIoTDataTemplatePropertyTypeInt) { //int 4Byte
        bitSting = @"00000000";
    }else if (typeValue == TIoTDataTemplatePropertyTypeString) { //string N(<=2048)Byte
        
    }else if (typeValue == TIoTDataTemplatePropertyTypeFloat) { //float 4Byte
        
    }else if (typeValue == TIoTDataTemplatePropertyTypeEnumerate) { //enumerate  2Byte
        bitSting = @"0000";
    }else if (typeValue == TIoTDataTemplatePropertyTypeTimestamp) { //timestamp  4Byte
        
    }else if (typeValue == TIoTDataTemplatePropertyTypeStruct) { //struct N(<=2048)Byte
        
    }
    
    NSString *valueHex = [NSString getHexByDecimal:value];
    NSString *preTempValue = [bitSting substringToIndex:bitSting.length - valueHex.length];
    NSString *resultValue = [NSString stringWithFormat:@"%@%@",preTempValue,valueHex];
    return resultValue;
}

///MARK: 在UUID （FFE2 FFE3 FFE4 ）中将属性值写入设备
- (void)writPropertyInfoInUUIDDeviceWithMessage:(NSString *)writeInfo UUIDString:(NSString *)uuidString{
    if (self.characteristicFFE1 != nil) {
        CBService *service = self.characteristicFFE1.service;
        for (CBCharacteristic *characteristic in service.characteristics) {
            NSString *uuidFirstString = [characteristic.UUID.UUIDString componentsSeparatedByString:@"-"].firstObject;
            if ([uuidFirstString isEqualToString:uuidString] && ![NSString isNullOrNilWithObject:uuidString]) {
                if ([uuidString isEqualToString:FFE4UUIDString]) {
                    [self.blueManager sendFirmwareUpdateNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:characteristic LLDeviceInfo:writeInfo?:@""];
                }else {
                    [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:characteristic LLDeviceInfo:writeInfo?:@""];
                }
            }
        }
    }
}

#pragma mark - WCWaterFlowLayoutDelegate

- (CGSize)waterFlowLayout:(TIoTWaterFlowLayout *)waterFlowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.deviceInfo.properties.count) {
        NSDictionary *pro = self.deviceInfo.properties[indexPath.row];
        NSString *type = pro[@"ui"][@"type"];
        CGFloat width = 0;
        if ([type isEqualToString:@"btn-col-3"]) {
            width = ([UIScreen mainScreen].bounds.size.width - kSectionInset.left - kSectionInset.right - itemSpace * 2) / 3.0;
            return CGSizeMake(width, 120);
        }
        else if ([type isEqualToString:@"btn-col-2"]) {
            width = ([UIScreen mainScreen].bounds.size.width - kSectionInset.left - kSectionInset.right - itemSpace) / 2.0;
            return CGSizeMake(width, 120);
        }
        else if ([type isEqualToString:@"btn-col-1"])
        {
            width = [UIScreen mainScreen].bounds.size.width - kSectionInset.left - kSectionInset.right;
            return CGSizeMake(width, 60);
        }
    }
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - kSectionInset.left - kSectionInset.right, 60);
}

- (CGSize)waterFlowLayout:(TIoTWaterFlowLayout *)waterFlowLayout sizeForHeaderViewInSection:(NSInteger)section
{
//    if (self.deviceInfo.bigProp) {
//        NSString *type = self.deviceInfo.bigProp[@"define"][@"type"];
//        if ([type isEqualToString:@"bool"]) {
//            return CGSizeMake(0, 393.5);
//        }
//        else if ([type isEqualToString:@"enum"])
//        {
//            return CGSizeMake(0, 357);
//        }
//        else if ([type isEqualToString:@"int"])
//        {
//            return CGSizeMake(0, 350);
//        }
//        else if ([type isEqualToString:@"float"])
//        {
//            return CGSizeMake(0, 350);
//        }
//        return CGSizeMake(0, 0);
//    }
    return CGSizeMake(0, 0);
}

- (CGFloat)minSpaceForLines:(TIoTWaterFlowLayout *)waterFlowLayout
{
    return lineSpace;
}

- (CGFloat)minSpaceForCells:(TIoTWaterFlowLayout *)waterFlowLayout
{
    return itemSpace;
}

- (UIEdgeInsets)edgeInsetInWaterFlowLayout:(TIoTWaterFlowLayout *)waterFlowLayout
{
    return kSectionInset;
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.deviceInfo.properties.count + self.deviceInfo.timingProject;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row < self.deviceInfo.properties.count) {
        NSMutableDictionary *pro = self.deviceInfo.properties[indexPath.row];
        NSString *type = pro[@"ui"][@"type"];
        [pro setValue:self.userConfigDic forKey:@"Userconfig"];
        if ([type isEqualToString:@"btn-col-3"] || [type isEqualToString:@"btn-col-2"]) {
            TIoTMediumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemId3 forIndexPath:indexPath];
            cell.userInteractionEnabled = [self.deviceDic[@"Online"] boolValue];
            [cell setInfo:pro];
            [cell setThemeStyle:self.themeStyle];
            cell.boolUpdate = ^(NSDictionary * _Nonnull uploadInfo) {
                [self reportDeviceData:uploadInfo];
            };
            return cell;
        }
        else if ([type isEqualToString:@"btn-col-1"])
        {
            TIoTLongCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemId2 forIndexPath:indexPath];
            [cell setInfo:pro];
            [cell setThemeStyle:self.themeStyle];
            cell.userInteractionEnabled = [self.deviceDic[@"Online"] boolValue];
            cell.boolUpdate = ^(NSDictionary * _Nonnull uploadInfo) {
                [self reportDeviceData:uploadInfo];
            };
            return cell;
        }else {
            TIoTLongCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemId2 forIndexPath:indexPath];
            [cell setInfo:pro];
            [cell setThemeStyle:self.themeStyle];
            cell.userInteractionEnabled = [self.deviceDic[@"Online"] boolValue];
            cell.boolUpdate = ^(NSDictionary * _Nonnull uploadInfo) {
                [self reportDeviceData:uploadInfo];
            };
            return cell;
        }
    }
    else
    {
        TIoTLongCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemId2 forIndexPath:indexPath];
        [cell setShowInfo:@{@"name":NSLocalizedString(@"cloud_timing", @"云端定时"),@"content":@""}];
        [cell setThemeStyle:self.themeStyle];
        cell.boolUpdate = ^(NSDictionary * _Nonnull uploadInfo) {
            [self reportDeviceData:uploadInfo];
        };
        return cell;
    }
    
    return nil;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![[QCloudNetEnv shareEnv] isReachable]) {
        [MBProgressHUD showError:@"当前无网络"];
        return;
    }
    
    if (indexPath.row < self.deviceInfo.properties.count) {
        NSDictionary *dic = self.deviceInfo.properties[indexPath.row];
        if ([dic[@"define"][@"type"] isEqualToString:@"bool"]) {
            
        }
        else if ([dic[@"define"][@"type"] isEqualToString:@"enum"] || [dic[@"define"][@"type"] isEqualToString:@"stringenum"]){
            
            //trtc特殊判断逻辑
            NSString *key = dic[@"id"];
            if ([key isEqualToString:TIoTTRTCaudio_call_status] || [key isEqualToString:TIoTTRTCvideo_call_status]) {
                self.reportData = dic;
                [self reportDeviceData:@{key: @1}];
                return;
            }
            
            TIoTChoseValueView *choseView = [[TIoTChoseValueView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            choseView.dic = dic;
            choseView.updateData = ^(NSDictionary * _Nonnull dataDic) {
                
                [self reportDeviceData:dataDic];
            };
            [choseView show];
        }
        else if ([dic[@"define"][@"type"] isEqualToString:@"int"]){
            
            TIoTSlideView *slideView = [[TIoTSlideView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            slideView.dic = dic;
            slideView.updateData = ^(NSDictionary * _Nonnull dataDic) {
                
                [self reportDeviceData:dataDic];
            };
            [slideView show];
            
        }
        else if ([dic[@"define"][@"type"] isEqualToString:@"string"]){
            
            
            TIoTStringView *stringView = [[TIoTStringView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            stringView.dic = dic;
            stringView.updateData = ^(NSDictionary * _Nonnull dataDic) {
                
                [self reportDeviceData:dataDic];
            };
            [stringView show];
        }
        else if ([dic[@"define"][@"type"] isEqualToString:@"float"]){
            
            TIoTSlideView *slideView = [[TIoTSlideView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            slideView.dic = dic;
            slideView.updateData = ^(NSDictionary * _Nonnull dataDic) {
                
                [self reportDeviceData:dataDic];
            };
            [slideView show];
        }
        else if ([dic[@"define"][@"type"] isEqualToString:@"timestamp"]){
            
            TIoTTimeView *timeView = [[TIoTTimeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            timeView.dic = dic;
            timeView.updateData = ^(NSDictionary * _Nonnull dataDic) {
                
                [self reportDeviceData:dataDic];
            };
            [timeView show];
            
        }
    }
    else
    {
        //云端定时
        TIoTTimerListVC *vc = [TIoTTimerListVC new];
        vc.productId = self.productId;
        vc.deviceName = self.deviceName;
        vc.actions = self.deviceInfo.allProperties;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - getter

- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty_noTask"]];
    }
    return _emptyImageView;
}


- (UILabel *)noIntelligentLogTipLabel {
    if (!_noIntelligentLogTipLabel) {
        _noIntelligentLogTipLabel = [[UILabel alloc]init];
        _noIntelligentLogTipLabel.text = NSLocalizedString(@"no_candidate_model", @"您还未定义物模型，请定义后体验");
        _noIntelligentLogTipLabel.font = [UIFont wcPfRegularFontOfSize:14];
        _noIntelligentLogTipLabel.textColor= [UIColor colorWithHexString:@"#6C7078"];
        _noIntelligentLogTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noIntelligentLogTipLabel;
}

- (UIImageView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }
    return _bgView;
}

- (UICollectionView *)coll
{
    if (!_coll) {
        TIoTWaterFlowLayout *layout = [[TIoTWaterFlowLayout alloc] init];
        layout.delegate = self;
        
        _coll = [[TIoTCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
        _coll.backgroundColor = [UIColor clearColor];
        _coll.delegate = self;
        _coll.dataSource = self;
        _coll.bounces = NO;
        _coll.contentInset = UIEdgeInsetsMake([TIoTUIProxy shareUIProxy].navigationBarHeight, 0, 0, 0);
//        _coll.delaysContentTouches = NO;
        
    }
    return _coll;
}

- (UIView *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = [UIColor whiteColor];
        _bottomBar.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08].CGColor;
        _bottomBar.layer.shadowOffset = CGSizeMake(0,0);
        _bottomBar.layer.shadowRadius = 16;
        _bottomBar.layer.shadowOpacity = 1;
        
        CAGradientLayer *layer = [[CAGradientLayer alloc] init];
        layer.frame = CGRectMake(0, 0, kScreenWidth, 76 + [TIoTUIProxy shareUIProxy].tabbarAddHeight);
        layer.colors = @[(id)[UIColor whiteColor].CGColor,(id)[UIColor whiteColor].CGColor];
        layer.startPoint = CGPointMake(0, 0);
        layer.endPoint = CGPointMake(0, 1);
        self.bottomLayer = layer;
        [_bottomBar.layer addSublayer:layer];
        
        [_bottomBar addSubview:self.stackView];
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _bottomBar;
}

- (UIStackView *)stackView
{
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
        _stackView.distribution = UIStackViewDistributionFillEqually;
        _stackView.alignment = UIStackViewAlignmentFill;
    }
    return _stackView;
}

- (DeviceInfo *)deviceInfo
{
    if (!_deviceInfo) {
        _deviceInfo = [[DeviceInfo alloc] init];
    }
    return _deviceInfo;
}

- (UIView *)blueConnectView {
    if (!_blueConnectView) {
        _blueConnectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 46)];
        _blueConnectView.backgroundColor = [UIColor colorWithHexString:kNoSelectedHexColor];
    }
    return _blueConnectView;
}

- (UILabel *)blueTipLabel {
    if (!_blueTipLabel) {
        _blueTipLabel = [[UILabel alloc]init];
        [_blueTipLabel setLabelFormateTitle:@"连接蓝牙中" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    }
    return _blueTipLabel;
}

- (UIButton *)controlBlueDeviceButton {
    if (!_controlBlueDeviceButton) {
        _controlBlueDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_controlBlueDeviceButton setButtonFormateWithTitlt:@"" titleColorHexString:@"#ffffff" font:[UIFont wcPfRegularFontOfSize:14]];
        _controlBlueDeviceButton.layer.borderWidth = 1;
        _controlBlueDeviceButton.layer.cornerRadius = 10;
        _controlBlueDeviceButton.layer.borderColor = [UIColor colorWithHexString:kNoSelectedHexColor].CGColor;
        _controlBlueDeviceButton.backgroundColor = [UIColor colorWithHexString:kNoSelectedHexColor];
        [_controlBlueDeviceButton addTarget:self action:@selector(controlConnectBlueDevice:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _controlBlueDeviceButton;
}
@end
