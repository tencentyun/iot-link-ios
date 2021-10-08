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

static CGFloat itemSpace = 9;
static CGFloat lineSpace = 9;
#define kSectionInset UIEdgeInsetsMake(10, 16, 10, 16)

static NSString *itemId2 = @"i_ooo223";
static NSString *itemId3 = @"i_ooo454";


typedef NS_ENUM(NSInteger,TIoTBlueDeviceConnectStatus) {
    TIoTBlueDeviceDisconnected,
    TIoTBlueDeviceConnected,
    TIoTBlueDeviceConnectedFail,
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
                CBPeripheral *device = self.blueDevices[0];
                NSDictionary<NSString *,id> *advertisementData = self.originBlueDevices[device];
                if ([advertisementData.allKeys containsObject:@"kCBAdvDataManufacturerData"]) {
                    NSData *manufacturerData = advertisementData[@"kCBAdvDataManufacturerData"];
                    NSString *hexstr = [NSString transformStringWithData:manufacturerData];
                    NSString *producthex = [hexstr substringWithRange:NSMakeRange(18, hexstr.length-18)];
                    NSString *productstr = [NSString stringFromHexString:producthex];
                    self.currentProductId = productstr;
                    
                    [self.blueManager connectBluetoothPeripheral:device];

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
    [self.tipAlertView removeFromSuperview];
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
            NSDictionary *DataTemplateDic = [NSString jsonToObject:DataTemplate];

//            TIoTDataTemplateModel *product = [TIoTDataTemplateModel yy_modelWithJSON:DataTemplate];
            TIoTProductConfigModel *config = [TIoTProductConfigModel yy_modelWithJSON:dic];
            if ([config.Panel.type isEqualToString:@"h5"]) {

            }else {
                [self getDeviceData:dic andBaseInfo:DataTemplateDic];
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
        }
    }
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
                CBPeripheral *device = self.blueDevices[0];
                NSDictionary<NSString *,id> *advertisementData = self.originBlueDevices[device];
                if ([advertisementData.allKeys containsObject:@"kCBAdvDataManufacturerData"]) {
                    NSData *manufacturerData = advertisementData[@"kCBAdvDataManufacturerData"];
                    NSString *hexstr = [NSString transformStringWithData:manufacturerData];
                    NSString *producthex = [hexstr substringWithRange:NSMakeRange(18, hexstr.length-18)];
                    NSString *productstr = [NSString stringFromHexString:producthex];
                    self.currentProductId = productstr;
                    
                    [self.blueManager connectBluetoothPeripheral:device];
                    
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
    //连接蓝牙设备成功
    [self connectedSuccessBlueDeviceUI];
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
                }
            }
        }
        
//        //判断绑定标识符和设备广播的是否一致
//        if ([bindID isEqualToString:deviceBindId]) {
//            for (CBCharacteristic *characteristic in service.characteristics) {
//                NSString *uuidFirstString = [characteristic.UUID.UUIDString componentsSeparatedByString:@"-"].firstObject;
//                //判断是否是纯蓝牙 LLSync
//                if ([uuidFirstString isEqualToString:@"0000FFE1"]) {
//                    //LLSync
//
//                    self.characteristicFFE1 = characteristic;
//
//                    [self getLocalPskWithProductId:self.productId deviceName:self.deviceName];
//                    break;
//                }
//            }
//        }
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
            //连接成功后 将连接结果写入设备后，设备返回
            [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1 LLDeviceInfo:@"090000"];
        }
    }
}

///MARK: 子设备上报
- (void)uploadingMessage {
    
}

///MARK:将连接结果写入设备
- (void)writeLinkResultInDeviceWithSuccess:(BOOL)isSuccess {
    if (isSuccess == YES) {
        [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1 LLDeviceInfo:@"05"];
    }else {
        [self.blueManager sendNewLLSynvWithPeripheral:self.currentConnectedPerpheral Characteristic:self.characteristicFFE1 LLDeviceInfo:@"06"];
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
