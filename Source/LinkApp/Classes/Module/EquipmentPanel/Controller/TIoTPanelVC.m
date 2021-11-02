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

#define FFE1UUIDString @"0000FFE1"
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
@property (nonatomic, strong) NSArray *structIDArray; //获取最新设备信息后，用于结构体idArray
@property (nonatomic, strong) NSMutableDictionary *typeTimesDic; //外层 key:type value:同类型属性在模板数组中的index
@property (nonatomic, strong) NSMutableDictionary *detailStructTpyeTimesDic; //结构体中 key:type value:同类型属性在模板数组中的index
@property (nonatomic, assign) NSInteger MTUInt; //连接成功后设备返回的MTU 计算后的字节数
@property (nonatomic, strong) NSData *fileData; //固件升级下载完整文件的数据

@property (nonatomic, assign) NSInteger cycleCount; //需要循环的累计数
@property (nonatomic, assign) NSInteger cycleNum; //文件满足一次循环的数量 (整循环数)
@property (nonatomic, assign) NSInteger singleCyclePackageNum; //单次循环中发包数
@property (nonatomic, strong) NSString *allDataStringHex; //计算全部数据string hex
@property (nonatomic, assign) NSInteger itemPackageDataLenBytes; //一个数据包的长度 字符数
@property (nonatomic, assign) NSInteger singleCyclePackageBytes; //单次循环中数据的总长度 字符数
@property (nonatomic, assign) NSInteger singlePageSizeInt; //单个数据包大小（设备返回的） 已经转为10进制
@property (nonatomic, assign) NSInteger cycleNumDataLen; //计算整发的循环的数据长度 (整数)
@property (nonatomic, assign) NSInteger lessSingleCyclePackageNum; //计算不满一次循环中，能整包发的次数
@property (nonatomic, assign) NSInteger itemPackageDataLen; //每包中 payload 长度
@property (nonatomic, assign) NSInteger lessSingleCyclePackageDataLen; //不满一次循环中，能整包发送的数据长度
@property (nonatomic, assign) NSInteger lastPackageDataLen; //计算不满单次循环，不能整包发的最后一个数据包长度
@property (nonatomic, assign) NSInteger nextSeqInt; //next seq
@property (nonatomic, assign) NSInteger fileSizeInt; //已发的数据长度 （字节）
@property (nonatomic, assign) NSInteger pageOuttimeInt; //数据包的超时重传周期，单位：秒
@property (nonatomic, assign) NSInteger deviceRestartMaxInt;//设备重启最大时间，单位：秒

@end

@implementation TIoTPanelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [HXYNotice addReportDeviceListener:self reaction:@selector(deviceReport:)];
    self.deviceInfo.deviceId = self.deviceDic[@"DeviceId"];
    
    //续传
    [HXYNotice addFirmwareUpdateDataLister:self reaction:@selector(continueSendData:)];
    
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)nav_customBack {
    [self.blueManager stopScan];
    [self.blueManager disconnectPeripheral];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [TIoTCoreUserManage shared].sys_call_status = @"-1";
    [self.blueManager stopScan];
    [self.blueManager disconnectPeripheral];
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
                        [self.blueManager connectBluetoothPeripheral:device];
//                        if([productstr isEqualToString:self.productId]) {
//                            [self.blueManager connectBluetoothPeripheral:device];
//                            break;
//                        }
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
                NSString *value = [self getPropertyInfoValueHexInFFE2WithDic:self.DataTemplateDic[@"properties"]?:@[] reportDic:payloadDic dataTemplate:TIoTDataTemplateTypeProperty];
                //将完整信息TVL数据 写入设备中FFE2特征中
                [self writeInfoInFFE2WithValue:value reportDic:payloadDic tyep:TIoTDataTemplateTypeProperty headerHexInProperty:@"00"];
                
                
            }else if ([payloadDic[@"method"] isEqualToString:@"action"]) {
                //设备UUID FFE2 写入行为调用
                //轮询找到下发actionID和接口请求的actionID 匹配（有可能是一个ID多个参数）
                if ([self.DataTemplateDic.allKeys containsObject:@"actions"]) {
                        
                        if ([payloadDic.allKeys containsObject:@"params"]) {
                            //TLV 数据
                            NSString *value = [self getPropertyInfoValueHexInFFE2WithDic:self.DataTemplateDic[@"actions"]?:@[] reportDic:payloadDic dataTemplate:TIoTDataTemplateTypeAction];
                            //将完整信息TVL数据 写入设备中FFE2特征中
                            [self writeInfoInFFE2WithValue:value reportDic:payloadDic tyep:TIoTDataTemplateTypeAction headerHexInProperty:@"00"];
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
        BOOL isFind = NO;
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
                         
                                isFind = YES;
                                
                                self.characteristicFFE1 = characteristic;
                                
                                [self getLocalPskWithProductId:self.productId deviceName:self.deviceName];
                                break;
                            }
                        }
                    }
                }
                
                if (isFind == NO) {
                    [self connectedFailBlueDeviceUI];
                    [self writeLinkResultInDeviceWithSuccess:NO];
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
        NSString *cmdtype = [[hexstr substringWithRange:NSMakeRange(0, 2)] uppercaseString];
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
            
            self.MTUInt = 0;
            //MTU
            NSString *MTUFileString = [hexstr substringWithRange:NSMakeRange(8, 4)];
            NSString *MTUFilebinaryString = [NSString getBinaryByHex:MTUFileString];
            NSString *MTUHex = [MTUFilebinaryString substringFromIndex:6];
            self.MTUInt = [NSString getDecimalByHex:MTUHex]/16;
            
            //获取设备上报固件版本号
            NSString *firmwareVersionHexString = [hexstr substringFromIndex:14];
            NSString *versionString = [NSString stringFromHexString:firmwareVersionHexString]?:@"";
            
            NSString *currentString = [self getVersionWithString:versionString];
            NSString *desString = [self getVersionWithString:self.firmwareModel.DstVersion];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(overtimeDeviceResartMax) object:nil];
            
            //升级固件提示弹框
            [self chooseUpdateFirwareAlertWithCurrentVersion:currentString desVersion:desString];
            
            [self reportFirmwareVersionWithVersion:versionString];
            
        }else if ([cmdtype isEqualToString:@"00"]) {
            //设备属性上报 （设备主动上报）
            if (!self.isDeviceReporting == YES) {
                NSString *jsonString = [self getDeviceReportDataJsonWithPropertyValueHex:hexstr?:@"" typeString:@"properties" structHeaderHex:@"" eventDicInex:0];
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
            
        }else if ([cmdtype isEqualToString:@"02"]) {
         //获取设备最新信息
            
            [self getDeviceNewestInfo];
            
        }else if ([cmdtype isEqualToString:@"03"]) {
         //设备事件上报
            //type:03 length:2Btye eventId:1Byte value:TVL
            [self deviceReportEventWithMessage:hexstr];
            
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
                [MBProgressHUD showError:@"设备不支持断点续传，并开始升级"];
                //发送设备升级数据包
                [self sendUpdateDataPages:allowUpatePayload];
                
                //上报后台进度开始升级数据包
                [self reportAppOTAStatusProgress:@"updating" versioin:self.firmwareModel.DstVersion persent:@(0)];
            }else if ([binaryString isEqualToString:@"00000010"]) { //不支持断点续传
                [MBProgressHUD showError:@"设备不支持断点续传"];
            }else if ([binaryString isEqualToString:@"00000011"]) {
                [MBProgressHUD showError:@"设备支持断点续传,并开始升级"];
                
                //发送设备升级数据包
                [self sendUpdateDataPages:allowUpatePayload];
                
                //上报后台进度开始升级数据包
                [self reportAppOTAStatusProgress:@"updating" versioin:self.firmwareModel.DstVersion persent:@(0)];
            }else {
                //保留 暂时按成功传
            }
            
        }else if ([cmdtype isEqualToString:@"0A"]) {
            //1、升级数据包应答 每发送一个轮询后，设备会返回一次应答
            //2、或者丢包后，需要断点续传
            DDLogInfo(@"device report continue send :%@",hexstr);
            
            //next seq
            NSString *nextSeq = [hexstr substringWithRange:NSMakeRange(6, 2)];
            self.nextSeqInt = [NSString getDecimalByHex:nextSeq];
            
            //file size
            NSString *fileSize = [hexstr substringWithRange:NSMakeRange(8, 8)];
            NSInteger fileSizeTemp = [NSString getDecimalByHex:fileSize];
            self.fileSizeInt = fileSizeTemp*2;
            
            //发送固件数据给设备
            [HXYNotice postFirmwareUpdateData];
        }else if ([cmdtype isEqualToString:@"0B"]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(firmwareUpdateFail) object:nil];
            //失败时需调用升级失败方法处，成功时暂时显示toast
            
            //开始计时是否超出设备重启最大时间，超出则认为升级失败
            [self performSelector:@selector(overtimeDeviceResartMax) withObject:nil afterDelay:self.deviceRestartMaxInt];
        }
    }
}

///MARK:收到设备回复后续传
- (void)continueSendData:(NSNotification *)noti {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(firmwareUpdateFail) object:nil];
    
    //不足一次发的起始位置
    NSInteger lessSingleCyxleInitPosi = self.cycleNumDataLen*2;
    
    if (self.fileSizeInt*2 < lessSingleCyxleInitPosi) {
        
        [self cycleNumSend];
        
        self.cycleCount += 1;
        self.nextSeqInt = 0;
        self.fileSizeInt = 0;
        [self lessSingleCycleSend];

        self.nextSeqInt = 0;
        self.fileSizeInt = 0;
        [self lastDataSend];
        
    }else if ((self.fileSizeInt*2 >= lessSingleCyxleInitPosi) && (self.fileSizeInt*2 < (lessSingleCyxleInitPosi + self.lessSingleCyclePackageDataLen))) {
        
        [self lessSingleCycleSend];

        self.nextSeqInt = 0;
        self.fileSizeInt = 0;
        [self lastDataSend];
        
    }else if (self.fileSizeInt*2 >= (lessSingleCyxleInitPosi + self.lessSingleCyclePackageDataLen)){
        
        [self lastDataSend];
    }
}

///MARK:发送升级数据包
/*
 * 1 先将安装包进行拆包，分多次循环传输完，单次循环 每次长度 1Byte 00-ff （设备升级请求应答包中 设备已返回）
 * 2 升级数据包:  单次循环中 向设备发送升级数据包,LLOTA格式 (type + length + value:seq+payload Nbytes )， 单个数据包 1Byte 00-F0 (设备升级请求应答包中 设备已返回）
     - seq表示数据包在单次循环中的序列号，从0开始，每一包数据增加1，直到total package numbers – 1结束，单次循环结束后重新从0开始
     - 设备通过 LLEvent 对升级数据包作出应答，（type + length + value:Next Seq+File size）,
     - 小程序连续 5 个超时重传周期内没有收到设备端回应，认为升级失败。
     - 设备重启最大时间是设备下载成功后重启设备，小程序等待设备上报新版本号的最大时间，超出此时间小程序认为升级失败
 *  3 设备应答包: 设备通过 LLEvent 对升级数据包作出应答
      - next seq是设备收到的数据包的seq的下一个seq，file size是设备已接收的正确文件的大小。
      - 设备收到单个循环的所有数据包后，使用next seq和file size对此次循环作出应答，小程序收到应答后再发送下一循环的数据包数据包。
      - 设备收到错误的seq时，发送应答包给小程序请求重传，小程序根据设备上报的next seq和file size重新传输数据，小程序应该从file size处开始传输，seq等于next seq。
      - 当传输出错时，在一个数据重传周期内，设备端只会上报一次数据应答包。
      - 连续5个数据重传周期内没有收到正确的数据包，设备端认为升级失败，用户可以控制断开连接。
      - 升级数据包最后一个循环中数据包可能不足total package numbers，设备会根据文件大小计算，以便在收到最后一个数据包时仍然可以发送数据应答包。
 *  4 升级数据结束通知包 02 (判断只有02 1byte)
      - 小程序通过 LLOTA 通知设备升级数据包下发结束
 
    payload : 升级请求包的设备返回 payload
 */
- (void)sendUpdateDataPages:(NSString *)payload {
    NSString *allowUpatePayload = payload?:@"";
    
    //单次循环中可以连续传输的数据包个数，取值范围0x00 ~ 0xFF
    NSString *singlesendPagesNumber = [allowUpatePayload substringWithRange:NSMakeRange(0, 2)];
    NSInteger adinglesendPageInt = [NSString getDecimalByHex:singlesendPagesNumber];
    //单个数据包大小，取值范围 0x00 ~ 0xF0
    NSString *singlepageSizeHex = [allowUpatePayload substringWithRange:NSMakeRange(2, 2)];
    self.singlePageSizeInt = [NSString getDecimalByHex:singlepageSizeHex];
    //数据包的超时重传周期，单位：秒
    NSString *pageOuttimeHex = [allowUpatePayload substringWithRange:NSMakeRange(4, 2)];
    self.pageOuttimeInt = [NSString getDecimalByHex:pageOuttimeHex];
    //设备重启最大时间，单位：秒
    NSString *deviceRestartMaxHex = [allowUpatePayload substringWithRange:NSMakeRange(6, 2)];
    self.deviceRestartMaxInt = [NSString getDecimalByHex:deviceRestartMaxHex];
    //断点续传前已接收文件大小
    NSString *resumeFileSize = [allowUpatePayload substringWithRange:NSMakeRange(8, 8)];
    //连续两个数据包的发包间隔
//    NSString *intervalTime = [allowUpatePayload substringWithRange:NSMakeRange(16, 2)];
    
    //实际单个数据包的大小 (type 1B+ lenght 1B + value: seq 1B + payload)
    
    /*
    112*255 = 28560
    682848/28560 =  23.9092436975
    28560*23 = 656880 （整数）
    682848 - 656880 = 25968  (余数)
    25968/112 = 231.857142857
    231*112 = 25872
    25968- 25872 = 96
    */
    
    //计算全部数据string hex
    self.allDataStringHex = [NSString getDataFromHexStr:self.fileData];
    //单次循环中发包数
    self.singleCyclePackageNum = adinglesendPageInt;
    //每包中 payload 长度
    self.itemPackageDataLen = self.singlePageSizeInt - 3;
    //单次循环的数据长度
    NSInteger singleCycleDataLen = self.itemPackageDataLen * adinglesendPageInt;
    //计算需要几次循环
    self.cycleNum = self.fileData.length/singleCycleDataLen;
    //计算整发的循环的数据长度 (整数)
     self.cycleNumDataLen = singleCycleDataLen * self.cycleNum;
    //计算不满一次循环的数据长度 （余数）
    NSInteger lessSingleCycleDataLen = self.fileData.length - self.cycleNumDataLen;
    //计算不满一次循环中，能整包发的次数
    self.lessSingleCyclePackageNum = lessSingleCycleDataLen/self.itemPackageDataLen;
    //不满一次循环中，能整包发送的数据长度
    self.lessSingleCyclePackageDataLen = self.lessSingleCyclePackageNum *self.itemPackageDataLen;
    //计算不满单次循环，不能整包发的最后一个数据包长度
    self.lastPackageDataLen = lessSingleCycleDataLen - self.lessSingleCyclePackageDataLen;
    
    self.itemPackageDataLenBytes= self.itemPackageDataLen*2;
    self.singleCyclePackageBytes = self.singleCyclePackageNum*self.itemPackageDataLen*2;
    
    [self sendFirmwareUpdateData];
    
}

///MARK:发送固件升级数据
- (void)sendFirmwareUpdateData {
    
    //开始计时 5个超时重传周期内没有设备设备回应，认为失败
    [self performSelector:@selector(firmwareUpdateFail) withObject:nil afterDelay:5*self.pageOuttimeInt];
    
    //所有完整循环
    self.cycleCount = 0;
    self.nextSeqInt = 0;
    self.fileSizeInt = 0;
    [self cycleNumSend];
    
    self.cycleCount += 1;
    self.nextSeqInt = 0;
    self.fileSizeInt = 0;
    //不足一个循环
    [self lessSingleCycleSend];
    
    self.nextSeqInt = 0;
    self.fileSizeInt = 0;
    //最后一个数据包
    [self lastDataSend];
}

//升级失败
- (void)firmwareUpdateFail {
    [MBProgressHUD showError:@"升级失败"];
    [self.blueManager disconnectPeripheral];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(firmwareUpdateFail) object:nil];
}

//设备重启最大超时
- (void)overtimeDeviceResartMax {
    [MBProgressHUD showError:@"升级失败"];
    [self.blueManager disconnectPeripheral];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(overtimeDeviceResartMax) object:nil];
}

//MARK:完整单循环
- (void)cycleNumSend {
    
    //需要计算能满单次循环的包数量和剩余的一次循环，在剩余的一次循环中，再计算能满一包的数量和不足一包的数量
    //可循环整发
    
    int i = 0;
//    for (NSInteger i = self.cycleCount; i<self.cycleNum; i++) {
        self.cycleCount = i;
        //单次可循环整包
        for (NSInteger j = self.nextSeqInt; j < self.singleCyclePackageNum; j++) {
            
            NSInteger startLocation = 0;
            if (self.fileSizeInt > 0) {
                startLocation = self.fileSizeInt*2;
            }else {
                startLocation = j*self.itemPackageDataLenBytes + i*self.singleCyclePackageBytes;
            }
            
            NSString *itemPackageWriteInfo = @"";
            //数据包type
            NSString *packageType = @"01";
            //拼接完整的每个数据包 value
            NSString *itemDataHexString = [self.allDataStringHex substringWithRange:NSMakeRange(startLocation, self.itemPackageDataLenBytes)];
            NSString *seqHexTemp = [NSString getHexByDecimal:j];
            NSString *seqHex = [self getTVLValueWithOriginValue:seqHexTemp bitString:@"00"];
            NSString *valueHexString = [NSString stringWithFormat:@"%@%@",seqHex,itemDataHexString];
            //数据包length
            NSInteger packageLenInt = self.singlePageSizeInt - 2;// (type 1B len 1b)
            NSString *packageLen = [NSString getHexByDecimal:packageLenInt];
            
            itemPackageWriteInfo = [NSString stringWithFormat:@"%@%@%@",packageType,packageLen,valueHexString];
            
            [self writePropertyInfoInUUIDDeviceWithMessage:itemPackageWriteInfo UUIDString:FFE4UUIDString];
        }
}

//MARK: 不足一次单循环，可以完整分包的循环
- (void)lessSingleCycleSend {
    
    //不足一次发的起始位置
    NSInteger lessSingleCyxleInitPosi = self.cycleNumDataLen*2; //字节数*2 转为字符串个数
    
    //不足一次循环发，单次可循环整包发
    for (NSInteger i = self.nextSeqInt; i<self.lessSingleCyclePackageNum; i++) {
        
        NSInteger startLocation = 0;
        if (self.fileSizeInt > 0) {
            startLocation = self.fileSizeInt*2;
        }else {
            startLocation = i*self.itemPackageDataLen*2+lessSingleCyxleInitPosi;
        }
        
        NSString *itemPackageWriteInfo = @"";
        //数据包type
        NSString *packageType = @"01";
        //拼接完整的每个数据包 value
        NSString *itemDataHexString = [self.allDataStringHex substringWithRange:NSMakeRange(startLocation, self.itemPackageDataLen)];
        NSString *seqHexTemp = [NSString getHexByDecimal:i];
        NSString *seqHex = [self getTVLValueWithOriginValue:seqHexTemp bitString:@"00"];
        NSString *valueHexString = [NSString stringWithFormat:@"%@%@",seqHex,itemDataHexString];
        //数据包length
        NSInteger packageLenInt = self.singlePageSizeInt - 2;// (type 1B len 1b)
        NSString *packageLen = [NSString getHexByDecimal:packageLenInt];
        
        itemPackageWriteInfo = [NSString stringWithFormat:@"%@%@%@",packageType,packageLen,valueHexString];
        [self writePropertyInfoInUUIDDeviceWithMessage:itemPackageWriteInfo UUIDString:FFE4UUIDString];
    }
}

//MARK:最后一个数据包
- (void)lastDataSend {
    
    NSInteger lessSingleCyxleInitPosi = self.cycleNumDataLen*2;
    
    //最后一包的起始位置
    NSInteger lastPackageInitPosi = 0;
    
    if (self.fileSizeInt > 0) {
        lastPackageInitPosi = self.fileSizeInt*2;
    }else {
        lastPackageInitPosi = lessSingleCyxleInitPosi + self.lessSingleCyclePackageDataLen;
    }
    //不足一次循环，不足整包发
    NSString *itemPackageWriteInfo = @"";
    //数据包type
    NSString *packageType = @"01";
    //拼接完整的每个数据包 value
    NSString *itemDataHexString = [self.allDataStringHex substringWithRange:NSMakeRange(lastPackageInitPosi, self.lastPackageDataLen)];
    NSString *seqHexTemp = [NSString getHexByDecimal:self.lessSingleCyclePackageNum];
    NSString *seqHex = [self getTVLValueWithOriginValue:seqHexTemp bitString:@"00"];
    NSString *valueHexString = [NSString stringWithFormat:@"%@%@",seqHex,itemDataHexString];
    //数据包length
    NSInteger packageLenInt = self.singlePageSizeInt - 2;// (type 1B len 1b)
    NSString *packageLen = [NSString getHexByDecimal:packageLenInt];
    
    itemPackageWriteInfo = [NSString stringWithFormat:@"%@%@%@",packageType,packageLen,valueHexString];
    [self writePropertyInfoInUUIDDeviceWithMessage:itemPackageWriteInfo UUIDString:FFE4UUIDString];
    
    //结束通知包
    [self writePropertyInfoInUUIDDeviceWithMessage:@"02" UUIDString:FFE4UUIDString];
    
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
                          propertie类型 :properties  事件类型  event: events
 structHeaderHex : 如果是struct，需转第一个字节
 eventDicInex: 如果是事件：事件的index  其他传空 0
 */
- (NSString *)getDeviceReportDataJsonWithPropertyValueHex:(NSString *)propertyValueHex typeString:(NSString *)itemPropertyTypeString structHeaderHex:(NSString *)structHeaderHex eventDicInex:(NSInteger)eventIndex {
    NSString *jsonString = @"";
    if (![NSString isNullOrNilWithObject:propertyValueHex]) {
        __block NSMutableDictionary *jsonDic = [NSMutableDictionary new];
        
//        if ([self.DataTemplateDic.allKeys containsObject:@"properties"]) {
        if ([self.DataTemplateDic.allKeys containsObject:itemPropertyTypeString?:@""]) {
//            __block NSArray *propertyTemplate = self.DataTemplateDic[@"properties"];
            //默认属性 模板数组
            __block NSArray *propertyTemplate = self.DataTemplateDic[itemPropertyTypeString]?:@[];
            //如果是event  需重新获取event对应模板数组
            if ([itemPropertyTypeString isEqualToString:@"events"]) {
                NSDictionary *eventDic = propertyTemplate[eventIndex]?:@{};
                propertyTemplate = eventDic[@"params"]?:@[];
            }
            
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
                                    NSString *structJson = [self getDeviceReportDataJsonWithPropertyValueHex:itemValueHex typeString:@"struct" structHeaderHex:headerHex eventDicInex:0];
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
            NSString *messgeString = [NSString stringWithFormat:@"%@%@\n%@%@",NSLocalizedString(@"current_Version", @"当前固件版本为"),self.firmwareModel.CurrentVersion,NSLocalizedString(@"last_Version", @"最新固件版本为"),self.firmwareModel.DstVersion];
            self.firmwareView = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds withTopImage:nil];
            __weak typeof(self) weakSelf = self;
            
            [self.firmwareView alertWithTitle:NSLocalizedString(@"firmware_update", @"可升级固件") message:messgeString  cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"update_now", @"立即升级")];
            self.firmwareView.doneAction = ^(NSString * _Nonnull text) {
                //上报开始下载 下载进度 下载完成
                //获取升级包URL后，开始下载
                [weakSelf getFrimwareOTAURL];
            };
            self.firmwareView.cancelAction = ^{
            };
            [self.firmwareView setAlertViewContentAlignment:TextAlignmentStyleCenter];
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
        DDLogInfo(@"download firmware file path :%@",file);
//        NSLog(@"Documentsdirectory: %@",
//        [manager contentsOfDirectoryAtPath:file error:nil]);
        self.fileData = [NSData dataWithContentsOfFile:file];
        DDLogInfo(@"file data :%@",self.fileData);
        
        //发送升级请求包到设备
        [self sendFirmwareUpdateInfoToDeviceWithData:self.fileData];
        
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
    
    //value
    NSString *sliceDataString = [writeInfo substringFromIndex:6];
    if (!(sliceDataString.length >= 16)) {
        return;
    }

    //分片发送
    NSInteger sliceGroup = sliceDataString.length/2/self.MTUInt;
    NSString *sliceType = @"";
    //中间
    for (int i = 0; i < sliceGroup; i++) {
        if (i == 0) {
            sliceType = @"0040";
        }else {
            sliceType = @"0080";
        }
        NSString *sliceDataLen = [NSString getHexByDecimal:self.MTUInt];
        NSString *sliceData = [sliceDataString substringWithRange:NSMakeRange(i*self.MTUInt*2, self.MTUInt*2)];
        NSString *sliceWriteInfo = [NSString stringWithFormat:@"%@%@%@",sliceType,sliceDataLen,sliceData];
        [self writePropertyInfoInUUIDDeviceWithMessage:sliceWriteInfo UUIDString:FFE4UUIDString];
    }

    //最后一片
    NSString *lastSliceType = @"00C0";
     //已发数据长度
    NSInteger alreadySendDataLen = self.MTUInt*2*sliceGroup;
    NSString *lastSliceData = [sliceDataString substringFromIndex:alreadySendDataLen];
    NSString *lastSliceDataLen = [NSString getHexByDecimal:lastSliceData.length/2];
    NSString *lasrSliceWriteInfo = [NSString stringWithFormat:@"%@%@%@",lastSliceType,lastSliceDataLen,lastSliceData];
    [self writePropertyInfoInUUIDDeviceWithMessage:lasrSliceWriteInfo UUIDString:FFE4UUIDString];
     
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
//        TIoTFirmwareUpdateStatusModel *updateStatusModel = [TIoTFirmwareUpdateStatusModel yy_modelWithJSON:responseObject];
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
            [self writePropertyInfoInUUIDDeviceWithMessage:@"0201" UUIDString:FFE4UUIDString];
        }else if (resultModel.code.integerValue == 0) {
            [self writePropertyInfoInUUIDDeviceWithMessage:@"0200" UUIDString:FFE4UUIDString];
        }
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        if (reportType == TIoTDeviceReportTypeProperty) {
            [self writePropertyInfoInUUIDDeviceWithMessage:@"0201" UUIDString:FFE4UUIDString];
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

///MARK: 设备远程控制- UUID FFE2中写入的property hex 值 （控制台下发）
//reportDic 用params再包一层
- (NSString *)getPropertyInfoValueHexInFFE2WithDic:(NSArray *)propertyArray reportDic:(NSDictionary *)reportDic dataTemplate:(TIoTDataTemplateType)type {
    
    NSDictionary *dic = reportDic[@"params"]?:@{};
    NSString *value = @"";
    
    if (self.typeTimesDic.allKeys.count != 0) {
        [self.typeTimesDic removeAllObjects];
    }
    //按格式组装设备需要数据（int enum bool，需要扩充float）
    
    if (propertyArray.count != 0) {
        
        // property 类别
        if (type == TIoTDataTemplateTypeProperty) {
//            for (NSDictionary *propertyDic in propertyArray) {
            for (int i = 0; i<propertyArray.count; i++) {
                NSDictionary *propertyDic = propertyArray[i]?:@{};
                NSDictionary *defineDic = propertyDic[@"define"]?:@{};
                NSString *dataTypeString = defineDic[@"type"]?:@"";
    //            NSString *dataTypeString = propertyDic[@"dataType"]?:@"";
                NSString *idString = propertyDic[@"id"]?:@"";
                //保存每个属性对应出现的index
                [self.typeTimesDic setValue:@(i) forKey:dataTypeString];
                
                if ([dataTypeString isEqualToString:@"struct"]) {
                    
                    if ([dic.allKeys containsObject:idString]) {
                        NSDictionary *structDetailDic = dic[idString]?:@{};
                        NSString *structString = @"";
                        NSDictionary *tempDefineDic = propertyDic[@"define"]?:@{};
                        NSArray* specsArray = tempDefineDic[@"specs"]?:@{};
//                        for (NSDictionary *structDic in specsArray) {
                        for (int j = 0; j<specsArray.count; j++) {
                            NSDictionary *structDic = specsArray[j]?:@{};
                            defineDic = structDic[@"dataType"]?:@{};
                            NSString *dataTypeString = defineDic[@"type"]?:@"";
                           NSString * IdStructString = structDic[@"id"]?:@"";
                            //保存每个属性对应出现的index
                            [self.detailStructTpyeTimesDic setValue:@(j) forKey:dataTypeString];
                            
                            //计算struct value
                            structString = [self getPropertyjointWithReportDic:structDetailDic dataTypeString:dataTypeString idString:IdStructString valueString:structString searchIndexArray:specsArray isDetailStruct:YES withStructValueHex:@""];
                        }
                        //获取外层完整的结构体，包括 type length value
                        structString = [self getPropertyjointWithReportDic:dic dataTypeString:dataTypeString idString:idString valueString:structString searchIndexArray:propertyArray isDetailStruct:NO withStructValueHex:structString];
                        
                        value = [value stringByAppendingString:structString];
                    }
                    
                }else {
                    value = [self getPropertyjointWithReportDic:dic dataTypeString:dataTypeString idString:idString valueString:value searchIndexArray:propertyArray isDetailStruct:NO withStructValueHex:@""];
                }
                
            }
            
//            NSString *typeString = @"00";
//            NSInteger length = value.length/2;
//            NSString *lengthHex = [NSString getHexByDecimal:length];
//            NSString *lengthResult = [self getMutableValueLength:lengthHex];
//            //写入设备
//            NSString *writeInfoString = [NSString stringWithFormat:@"%@%@%@",typeString,lengthResult,value];
//            [self writPropertyInfoInUUIDDeviceWithMessage:writeInfoString UUIDString:FFE2UUIDString];
            
        }else if (type == TIoTDataTemplateTypeAction) {
            
            //action 类别  先算value 再算fixed 后算length
            //计算 action LLData value值(TVL) （TVL协议中 type + length（可选） +value; 字符串和结构体需要加拼接length）

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
                            value = [value stringByAppendingString:resultValue];
                        }
                    }
                }
            }
            
//            //action LLData Fixed Header
//            NSString *fixedHeader = @"";
//            NSArray *actionArray = self.DataTemplateDic[@"actions"]?:@[];
//            if (actionArray.count != 0) {
//                //拼接lldata type
//                fixedHeader = [self getLLDataFixedHeaderDataTemplate:TIoTLLDataFixedHeaderDataTemplateTypeAction dataDefine:@"0" payloadDic:reportDic actionOrEventArray:actionArray];
//            }
//
//            //action LLData length
//            NSInteger length = value.length/2;
//            NSString *lengthHex = [NSString getHexByDecimal:length];
//            NSString *lengthResult = [self getMutableValueLength:lengthHex];
//            //写入设备
//            NSString *writeInfoString = [NSString stringWithFormat:@"%@%@%@",fixedHeader,lengthResult,value];
//            [self writPropertyInfoInUUIDDeviceWithMessage:writeInfoString UUIDString:FFE2UUIDString];
            
        }else if (type == TIoTDataTemplateTypeEvent) {
            //event 类别
            
        }
        
    }
    return value;
}

///MARK:获取属性拼接后的value
//indexOriginArray: 结构体为 内层dic; 非结构体 为原始property数据(self.DataTemplateDic)
//只有在计算完结构体后再传，其他情况传空
- (NSString *)getPropertyjointWithReportDic:(NSDictionary *)dic dataTypeString:(NSString *)dataTypeString idString:(NSString *)idString valueString:(NSString *)value searchIndexArray:(NSArray *)indexOriginArray isDetailStruct:(BOOL)isDetailStruct withStructValueHex:(NSString *)structString {
    
    if (dic != nil) {
        TIoTDataTemplatePropertyType type;
        
        if (![NSString isNullOrNilWithObject:dataTypeString] && [dic.allKeys containsObject:idString]) {
            if ([dataTypeString isEqualToString:@"int"]) {
                type = TIoTDataTemplatePropertyTypeInt;
            }else if ([dataTypeString isEqualToString:@"bool"]) {
                type = TIoTDataTemplatePropertyTypeBool;
            }else if ([dataTypeString isEqualToString:@"enum"]) {
                type = TIoTDataTemplatePropertyTypeEnumerate;
            }else if ([dataTypeString isEqualToString:@"float"]) {
                type = TIoTDataTemplatePropertyTypeFloat;
            }else if ([dataTypeString isEqualToString:@"string"]) {
                type = TIoTDataTemplatePropertyTypeString;
            }else if ([dataTypeString isEqualToString:@"timestamp"]) {
                type = TIoTDataTemplatePropertyTypeTimestamp;
            }else {
                type = TIoTDataTemplatePropertyTypeStruct;
            }
         
            NSString * IDValueString = [self setPropertyReportDeviceInfoWithType:type reportDic:dic idString:idString dataTypeString:dataTypeString propertyIndexArray:indexOriginArray isDetailStruct:isDetailStruct withStructValueHex:structString];
            //拼接value
            if (![NSString isNullOrNilWithObject:structString]) {
                NSString *tempStructHex = [NSString stringWithFormat:@"%@%@",IDValueString,value];
                value = [@"" stringByAppendingString:tempStructHex];
            }else {
                value = [value stringByAppendingString:IDValueString];
            }
            
        }
    }
    
    return value;
}

///MARK: 设备远程控制- UUID FFE2中写入完成数据
- (void)writeInfoInFFE2WithValue:(NSString *)value reportDic:(NSDictionary *)reportDic tyep:(TIoTDataTemplateType)type headerHexInProperty:(NSString *)typeHeaderString{
    if (type == TIoTDataTemplateTypeProperty) {  //property 属性
        NSString *typeString = typeHeaderString?:@"00";//@"00";
        NSInteger length = value.length/2;
        NSString *lengthHex = [NSString getHexByDecimal:length];
        NSString *lengthResult = [self getMutableValueLength:lengthHex];
        //写入设备
        NSString *writeInfoString = [NSString stringWithFormat:@"%@%@%@",typeString,lengthResult,value];
        [self writePropertyInfoInUUIDDeviceWithMessage:writeInfoString UUIDString:FFE2UUIDString];
    }else if (type == TIoTDataTemplateTypeAction) { //action 行为
        //action LLData Fixed Header
        NSString *fixedHeader = @"";
        NSArray *actionArray = self.DataTemplateDic[@"actions"]?:@[];
        if (actionArray.count != 0) {
            //拼接lldata type
            fixedHeader = [self getLLDataFixedHeaderDataTemplate:TIoTLLDataFixedHeaderDataTemplateTypeAction dataDefine:@"0" payloadDic:reportDic actionOrEventArray:actionArray];
        }
        
        //action LLData length
        NSInteger length = value.length/2;
        NSString *lengthHex = [NSString getHexByDecimal:length];
        NSString *lengthResult = [self getMutableValueLength:lengthHex];
        //写入设备
        NSString *writeInfoString = [NSString stringWithFormat:@"%@%@%@",fixedHeader,lengthResult,value];
        [self writePropertyInfoInUUIDDeviceWithMessage:writeInfoString UUIDString:FFE2UUIDString];
    }else if (type == TIoTDataTemplateTypeEvent) { //event 事件
        
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
- (NSString *)setPropertyReportDeviceInfoWithType:(TIoTDataTemplatePropertyType)typeValue reportDic:(NSDictionary *)dic idString:(NSString *)idString dataTypeString:(NSString *)dataTypeString propertyIndexArray:(NSArray *)indexOriginArray isDetailStruct:(BOOL )isDetailStruct withStructValueHex:(NSString *)withStructValueHex {
    
    //property value  TVL
    //IdValueString
    NSMutableArray *IDNumberArray = [self getPropertyIndexWithType:dataTypeString propertyIndexArray:indexOriginArray isDetailStruct:isDetailStruct];
    //value
    NSString *valueString = @"";
    
    NSNumber *propertyIndex = self.typeTimesDic[dataTypeString];
    NSNumber *detailStructPropertyIndex = self.detailStructTpyeTimesDic[dataTypeString];
    
    if ([dic.allKeys containsObject:idString]) {
        
        if (typeValue == TIoTDataTemplatePropertyTypeBool || typeValue == TIoTDataTemplatePropertyTypeInt || typeValue == TIoTDataTemplatePropertyTypeEnumerate || typeValue == TIoTDataTemplatePropertyTypeTimestamp || typeValue == TIoTDataTemplatePropertyTypeFloat) {
            NSNumber *valueNumber = dic[idString]?:@(0);
            for (NSNumber *idNumber in IDNumberArray) {
                //判断是当前模板属性数组中的index 才计算value
                BOOL isEqualIndex = NO;
                if (isDetailStruct == YES) {
                    if (detailStructPropertyIndex.integerValue == idNumber.integerValue) {
                        isEqualIndex = YES;
                    }else {
                        isEqualIndex = NO;
                    }
                }else {
                    if (propertyIndex.integerValue == idNumber.integerValue) {
                        isEqualIndex = YES;
                    }else {
                        isEqualIndex = NO;
                    }
                }
                
                if (isEqualIndex) {
                    //头字节
                    NSString *typeValueString = [self getTLVIDValue:idNumber.integerValue type:typeValue];
                    //value hex
                    NSString *tempValueNumber = [NSString stringWithFormat:@"%ld",valueNumber.integerValue];
                    if (typeValue == TIoTDataTemplatePropertyTypeFloat) {
                        tempValueNumber = [NSString stringWithFormat:@"%f",valueNumber.floatValue];
                    }
                    NSString *valueHex = [self getTLVValue:tempValueNumber type:typeValue];
                    valueString = [NSString stringWithFormat:@"%@%@",typeValueString,valueHex];
                }
            }
        }else if (typeValue == TIoTDataTemplatePropertyTypeString) {
//            NSString *tempValueString = @"";
            
            NSString *idValueString = dic[idString]?:@"";
            for (NSNumber *idNumber in IDNumberArray) {
                //判断是当前模板属性数组中的index 才计算value
                BOOL isEqualIndex = NO;
                if (isDetailStruct == YES) {
                    if (detailStructPropertyIndex.integerValue == idNumber.integerValue) {
                        isEqualIndex = YES;
                    }else {
                        isEqualIndex = NO;
                    }
                }else {
                    if (propertyIndex.integerValue == idNumber.integerValue) {
                        isEqualIndex = YES;
                    }else {
                        isEqualIndex = NO;
                    }
                }
                
                if (isEqualIndex) {
                    //                //头字节
                    NSString *typeValueString = [self getTLVIDValue:idNumber.integerValue type:TIoTDataTemplatePropertyTypeString];
                    //value hex
                    NSString *valueHex = [self getTLVValue:idValueString type:typeValue];
                    valueString = [NSString stringWithFormat:@"%@%@",typeValueString,valueHex];
                }
            }
        }else if (typeValue == TIoTDataTemplatePropertyTypeStruct) {
            
//            NSString *tempValueString = @"";
            NSDictionary *idStructValueDic = dic[idString]?:@"";
            NSString *idStructValueString = [NSString objectToJson:idStructValueDic];
            for (NSNumber *idNumber in IDNumberArray) {
                //判断是当前模板属性数组中的index 才计算value
                BOOL isEqualIndex = NO;
                if (isDetailStruct == YES) {
                    if (detailStructPropertyIndex.integerValue == idNumber.integerValue) {
                        isEqualIndex = YES;
                    }else {
                        isEqualIndex = NO;
                    }
                }else {
                    if (propertyIndex.integerValue == idNumber.integerValue) {
                        isEqualIndex = YES;
                    }else {
                        isEqualIndex = NO;
                    }
                }
                
                if (isEqualIndex) {
                    //头字节
                    NSString *typeValueString = [self getTLVIDValue:idNumber.integerValue type:TIoTDataTemplatePropertyTypeStruct];
                    //value hex
                    NSString *valueHex = [self getTLVValue:idStructValueString type:typeValue];
                    valueString = [NSString stringWithFormat:@"%@%@",typeValueString,valueHex];
                    
                    if (![NSString isNullOrNilWithObject:withStructValueHex]) {
                        NSString *structLengthHexValue = [NSString getHexByDecimal:withStructValueHex.length/2];
                        NSString *valueHex = [self getTVLValueWithOriginValue:structLengthHexValue bitString:@"0000"];
                        valueString = [NSString stringWithFormat:@"%@%@",typeValueString,valueHex];
                    }
                }
            }
        }
    }
    
    return valueString;
}

//获取下发属性在设备模板中index (TLV协议中Type 中 ID值)
- (NSMutableArray *)getPropertyIndexWithType:(NSString *)dataTypeString propertyIndexArray:(NSArray *)indexOriginArray isDetailStruct:(BOOL)isDetailStruct {
    NSMutableArray *idNumberArra = [NSMutableArray new];
    
    __block NSInteger IDNumber = 0;
//    NSArray *propertyArr = self.DataTemplateDic[@"properties"]?:@[];
    NSArray *propertyArr = indexOriginArray?:@[];
    
    NSMutableArray *idArray = [NSMutableArray new];
    if (isDetailStruct == YES) { //结构体
        [indexOriginArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *detailStructDic = obj;
            [idArray addObject:detailStructDic[@"id"]];
        }];
    }else { //非结构体
        idArray = [NSMutableArray arrayWithArray:self.structIDArray];
    }
    [propertyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *propertyDic = obj;
        for (NSString *idkeyString in idArray) {
//        for (NSString *idkeyString in self.deviceReportData.allKeys) {
            NSDictionary *defineDic = [NSDictionary new];
            if ([propertyDic.allKeys containsObject:@"define"]) {
                //非结构体
                defineDic = propertyDic[@"define"]?:@{};
            }else if ([propertyDic.allKeys containsObject:@"dataType"]) {
                //结构体
                defineDic = propertyDic[@"dataType"]?:@{};
            }
            
            NSString *typeKey = defineDic[@"type"]?:@"";
            NSString *IDKey = propertyDic[@"id"]?:@"";
            if (![NSString isNullOrNilWithObject:typeKey] && [typeKey isEqualToString:dataTypeString] && [IDKey isEqualToString:idkeyString]) {
                IDNumber = idx;
                [idNumberArra addObject:@(IDNumber)];
                break;
                *stop = YES;
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
- (NSString *)getTLVIDValue:(NSInteger )idValue type:(TIoTDataTemplatePropertyType)typeValue {
    NSString *bitSting = @"00000";
    NSString *preType = @"";
    NSString *valueSting = @"";
    
    if (typeValue == TIoTDataTemplatePropertyTypeBool) { //布尔
        preType = @"000";
    }else if (typeValue == TIoTDataTemplatePropertyTypeInt) { //int
        preType = @"001";
    }else if (typeValue == TIoTDataTemplatePropertyTypeString) { //string
        preType = @"010";
    }else if (typeValue == TIoTDataTemplatePropertyTypeFloat) { //float
        preType = @"011";
    }else if (typeValue == TIoTDataTemplatePropertyTypeEnumerate) { //enumerate
        preType = @"100";
    }else if (typeValue == TIoTDataTemplatePropertyTypeTimestamp) { //timestamp
        preType = @"101";
    }else if (typeValue == TIoTDataTemplatePropertyTypeStruct) { //struct
        preType = @"110";
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
- (NSString *)getTLVValue:(NSString *)value type:(TIoTDataTemplatePropertyType )typeValue {
    NSString *bitSting = @"";
    if (typeValue == TIoTDataTemplatePropertyTypeBool) { //布尔 1Byte
        bitSting = @"00";
    }else if (typeValue == TIoTDataTemplatePropertyTypeInt) { //int 4Byte
        bitSting = @"00000000";
    }else if (typeValue == TIoTDataTemplatePropertyTypeString) { //string N(<=2048)Byte
        
    }else if (typeValue == TIoTDataTemplatePropertyTypeFloat) { //float 4Byte
        bitSting = @"00000000";
    }else if (typeValue == TIoTDataTemplatePropertyTypeEnumerate) { //enumerate  2Byte
        bitSting = @"0000";
    }else if (typeValue == TIoTDataTemplatePropertyTypeTimestamp) { //timestamp  4Byte
        bitSting = @"00000000";
    }else if (typeValue == TIoTDataTemplatePropertyTypeStruct) { //struct N(<=2048)Byte
        
    }
    NSString *valueHex = @"";
    
    //及苏阿奴valueHex: 字符串和结构体需要算出valueHex后再计算length，其他属性直接计算valueHex
    if (typeValue == TIoTDataTemplatePropertyTypeBool || typeValue == TIoTDataTemplatePropertyTypeInt || typeValue == TIoTDataTemplatePropertyTypeEnumerate || typeValue == TIoTDataTemplatePropertyTypeTimestamp) {
        valueHex = [NSString getHexByDecimal:value.integerValue];
    }else if (typeValue == TIoTDataTemplatePropertyTypeFloat) {
        valueHex = [NSString getHexByFloat:value.floatValue];
    }else if (typeValue == TIoTDataTemplatePropertyTypeString) {
        valueHex = [NSString hexStringFromString:value];
    }else if (typeValue == TIoTDataTemplatePropertyTypeStruct) {
        //结构体中 json 字符串转 NSDictionary
        NSDictionary *structDic = (NSDictionary *)[NSString jsonToObject:value];
        //json 转化的 dic 完整拼接的 value hex
        valueHex = [self getPropertyInfoValueHexInFFE2WithDic:self.DataTemplateDic[@"properties"]?:@[] reportDic:structDic dataTemplate:TIoTDataTemplateTypeProperty];
    }
    
    //计算最终value: 字符串和结构体 需要单独加value的length （返回了包含length 的 value）,其他类型不用
    NSString *preTempValue = @"";
    if (typeValue == TIoTDataTemplatePropertyTypeString || typeValue == TIoTDataTemplatePropertyTypeStruct) {
        //value 前的2Bytes 长度
        NSString *valueLenHex = [NSString getHexByDecimal:valueHex.length/2];
        NSString *tempValueLenBit = @"0000";
        preTempValue = [self getTVLValueWithOriginValue:valueLenHex bitString:tempValueLenBit];
        
    }else {
        //type Header
        preTempValue = [bitSting substringToIndex:bitSting.length - valueHex.length];
    }
    NSString *resultValue = [NSString stringWithFormat:@"%@%@",preTempValue,valueHex];
    return resultValue;
}

///MARK: 在UUID （FFE2 FFE3 FFE4 ）中将属性值写入设备
- (void)writePropertyInfoInUUIDDeviceWithMessage:(NSString *)writeInfo UUIDString:(NSString *)uuidString{
    if (self.characteristicFFE1 != nil) {
        CBService *service = self.characteristicFFE1.service;
        if (service.characteristics != nil) {
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
}

///MARK:获取设备最新信息，用于设备获取最新值上报
- (void)getDeviceNewestInfo{
    [[TIoTRequestObject shared] post:AppGetDeviceData Param:@{@"ProductId":self.productId,@"DeviceName":self.deviceName} success:^(id responseObject) {
        
        //获取设备最新信息上报
        NSString *newestStr = (NSString *)responseObject[@"Data"];
        NSDictionary *newestDic = [NSString jsonToObject:newestStr]?:@{};
        
        NSArray *propertyArray = self.DataTemplateDic[@"properties"]?:@[];
        
        //重组后的属性字典
        NSMutableDictionary *reportPropertyDic = [NSMutableDictionary new];
        
        for (NSString *propertyIDString in newestDic.allKeys) {
            //获取设备最新属性对应的字典,需要取数Value 对应不同类型的值
            NSDictionary *idDic = newestDic[propertyIDString]?:@{};
            
            for (NSDictionary *propertyDic in propertyArray) {
                NSDictionary *defineDic = propertyDic[@"define"]?:@{};
                NSString *dataTypeString = defineDic[@"type"]?:@"";
                NSString *idString = propertyDic[@"id"]?:@"";
                if (newestDic != nil) {
                    
                    if (![NSString isNullOrNilWithObject:dataTypeString] && [newestDic.allKeys containsObject:idString] && [propertyIDString isEqualToString:idString]) {
                        if ([dataTypeString isEqualToString:@"int"]) {
                            NSNumber *intValue = idDic[@"Value"];
                            [reportPropertyDic setValue:intValue forKey:propertyIDString];
                        }else if ([dataTypeString isEqualToString:@"bool"]) {
                            NSNumber *boolValue = idDic[@"Value"];
                            [reportPropertyDic setValue:boolValue forKey:propertyIDString];
                        }else if ([dataTypeString isEqualToString:@"enum"]) {
                            NSNumber *enumValue = idDic[@"Value"];
                            [reportPropertyDic setValue:enumValue forKey:propertyIDString];
                        }else if ([dataTypeString isEqualToString:@"float"]) {
                            NSString *floatValue = idDic[@"Value"];
                            [reportPropertyDic setValue:@(floatValue.floatValue) forKey:propertyIDString];
                        }else if ([dataTypeString isEqualToString:@"string"]) {
                            NSString *stringValue = idDic[@"Value"];
                            [reportPropertyDic setValue:stringValue forKey:propertyIDString];
                        }else if ([dataTypeString isEqualToString:@"timestamp"]) {
                            NSNumber *timeStampValue = idDic[@"Value"];
                            [reportPropertyDic setValue:timeStampValue forKey:propertyIDString];
                        }else if ([dataTypeString isEqualToString:@"struct"]) {
                            NSDictionary *structDic = idDic[@"Value"];
                            [reportPropertyDic setValue:structDic forKey:propertyIDString];
                        }
                        
                    }
                }

            }
        }
        
        self.structIDArray = [NSArray arrayWithArray:newestDic.allKeys]?:@[];
        
        //reportDic 需要 key:params value: newestDic
        NSDictionary *reportDic = @{@"params":reportPropertyDic?:@{}};
        NSString *value = [self getPropertyInfoValueHexInFFE2WithDic:propertyArray reportDic:reportDic dataTemplate:TIoTDataTemplateTypeProperty];
        //将完整信息TVL数据 写入设备中FFE2特征中   type 22 result 00
        [self writeInfoInFFE2WithValue:value reportDic:reportDic tyep:TIoTDataTemplateTypeProperty headerHexInProperty:@"2200"];

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        NSString *writeInfo = @"22010000";
        [self writePropertyInfoInUUIDDeviceWithMessage:writeInfo UUIDString:FFE2UUIDString];
    }];
}

///MARK: 设备事件上报
- (void)deviceReportEventWithMessage:(NSString *)message {
    //type:03 length:2Btye eventId:1Byte value:TVL
    NSString *eventMessageHex = message;
    NSString *eventIdHex = [eventMessageHex substringWithRange:NSMakeRange(6, 2)];
    NSString *eventValueHex = [eventMessageHex substringFromIndex:8];
    
    //eventid int
    NSInteger eventIdIndex = [NSString getDecimalByHex:eventIdHex];
    __block NSString *eventId = @"";
    //获取设备事件上报数据对应模板中的 eventDic  （self.DataTemplateDic 模板全部数据）
    if (self.DataTemplateDic != nil) {
        NSArray *eventArray = self.DataTemplateDic[@"events"]?:@[];
        [eventArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *eventDic = (NSDictionary *)obj?:@{};
            if (idx == eventIdIndex) {
                eventId = eventDic[@"id"];
            }
        }];
    }
    
    //去除eventid的 1byte 和属性上报格式保持一致，可复用
    
    NSString *jsonString = [self getDeviceReportDataJsonWithPropertyValueHex:eventValueHex?:@"" typeString:@"events" structHeaderHex:@"" eventDicInex:eventIdIndex];
    NSDictionary *dic = @{@"DeviceId":[NSString stringWithFormat:@"%@/%@",self.productId?:@"",self.deviceName?:@""],
                          @"EventId":eventId?:@"",
                          @"Params":jsonString?:@"",
                          @"Method":@"ReportEventAsDevice",
    };
    
    //上报事件
    [self requestReportDeviceEvent:dic withEventIndex:eventIdIndex];
}
///MARK:设备事件上报请求
- (void)requestReportDeviceEvent:(NSDictionary *)dic withEventIndex:(NSInteger)eventIdIndex {
    NSString *bitSting = @"00000";
    NSString *preType = @"011";
    NSString *tempIDValue = [NSString getBinaryByDecimal:eventIdIndex];
    //拼接TVL Type 1 Byte
    NSString *preTempIDValue = [bitSting substringToIndex:bitSting.length - tempIDValue.length];
    NSString *resultIDValue= [NSString stringWithFormat:@"%@%@",preTempIDValue,tempIDValue];
    NSString *tempValue = [NSString stringWithFormat:@"%@%@",preType,resultIDValue];
    //将2进制转16进制 1Byte
    NSString *replayType = [NSString getHexByBinary:tempValue];
    
    NSDictionary *paramDic = [NSDictionary dictionaryWithDictionary:dic?:@{}];
    [[TIoTRequestObject shared] post:AppReportDeviceEvent Param:paramDic success:^(id responseObject) {
        NSString *replayResult = @"00";
        NSString *writeInfo = [NSString stringWithFormat:@"%@%@",replayType,replayResult];
        [self writePropertyInfoInUUIDDeviceWithMessage:writeInfo UUIDString:FFE2UUIDString];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        NSString *replayResult = @"01";
        NSString *writeInfo = [NSString stringWithFormat:@"%@%@",replayType,replayResult];
        [self writePropertyInfoInUUIDDeviceWithMessage:writeInfo UUIDString:FFE2UUIDString];
    }];
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

- (NSMutableDictionary *)typeTimesDic {
    if (!_typeTimesDic) {
        _typeTimesDic = [NSMutableDictionary new];
    }
    return _typeTimesDic;
}

- (NSMutableDictionary *)detailStructTpyeTimesDic {
    if (!_detailStructTpyeTimesDic) {
        _detailStructTpyeTimesDic = [NSMutableDictionary new];
    }
    return _detailStructTpyeTimesDic;
}
@end
