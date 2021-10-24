//
//  WCHomeViewController.m
//  TenextCloud
//
//

#import "TIoTHomeViewController.h"
#import "TIoTEquipmentTableViewCell.h"
#import "TIoTNewAddEquipmentViewController.h"
#import "TIoTMessageViewController.h"
#import "TIoTPanelVC.h"
#import "TIoTRefreshHeader.h"
#import "TIoTAppEnvironment.h"
#import "TIoTAppConfig.h"

#import "CMPageTitleContentView.h"
#import <YYModel.h>
#import "FamilyModel.h"
#import "RoomModel.h"

#import "TIoTPopoverVC.h"
#import "TIoTOptionalView.h"

#import <MJRefresh.h>

#import "UIView+Extension.h"
#import "TIoTWebVC.h"
#import "MGJRouter.h"

#import "Firebase.h"
#import "TIoTTRTCUIManage.h"
#import "UILabel+TIoTExtension.h"
#import "UIImage+Ex.h"
#import "TIoTAddressParseModel.h"
#import "TIoTFamilyInfoVC.h"
#import "TIoTEquipmentNewCell.h"
#import "TIoTShortcutView.h"

@import Lottie;

static CGFloat weatherHeight = 10;
static CGFloat kHeaderViewHeight = 162;

@interface TIoTHomeViewController ()<UITableViewDelegate,UITableViewDataSource,CMPageTitleContentViewDelegate,UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) UITableView *devicesTableView;
@property (nonatomic, strong) NSMutableArray *devicesArray; //一般设备原始数据拆分后的数组
@property (nonatomic, strong) NSMutableArray *deviceConfigArray; //一般设备获取每个配置后数组

@property (nonatomic, strong) NSMutableArray *shareDevicesArray; //分享设备原始数据拆分后的数组
@property (nonatomic, strong) NSMutableArray *shareDeviceConfigArray; //分享设备获取每个配置后数组

@property (nonatomic, strong) CMPageTitleContentView *tableHeaderView;

@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UILabel *nick;
@property (nonatomic, strong) UILabel *weatherLab;
@property (nonatomic, strong) UIButton *addBtn;


@property (nonatomic,strong) NSArray *families;
@property (nonatomic,strong) NSArray *rooms;
@property (nonatomic,copy)  NSString *currentFamilyId;
@property (nonatomic,copy)  NSNumber *currentFamilyRole;
@property (nonatomic,copy)  NSString *currentRoomId;


@property (nonatomic, strong) NSMutableDictionary *allRoomDeviceInfo;
@property (nonatomic, assign) NSInteger offset;//设备数据偏移量
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, copy) NSArray *deviceIds;

@property (nonatomic, strong) NSMutableArray *shareDataArr;
@property (nonatomic) dispatch_semaphore_t sem;
@property (nonatomic, strong) UIView  *headerView;
@property (nonatomic, strong) UILabel *cityMessageLabel;
@property (nonatomic, strong) UILabel *dailyNameLabel;
@property (nonatomic, strong) TIoTWeatherVC *animationVC;
@property (nonatomic, strong) AnimationView * weatherAnimationView;
@property (nonatomic, strong) NSString *weatherContentTypeText;

@property (nonatomic, strong) NSString *weatherTemp;
@property (nonatomic, strong) NSString *weatherLocation;
@property (nonatomic, strong) NSString *weatherText;
@property (nonatomic, strong) NSString *weatherHumidity;
@property (nonatomic, strong) NSString *weatherWindDir;
@property (nonatomic, strong) NSString *weatherTypeText;
@property (nonatomic, strong) UIView *slideTitleBackView;
@property (nonatomic, strong) UIImageView *weatherBackImage;
@property (nonatomic, strong) UILabel *unitLabel;
@property (nonatomic, strong) UIButton *weatherBottomBtn;

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;

@property (nonatomic, assign) bool isHideWeatherView; //用户判断切换页面或跳转页面后，天气view 加载时间延时出现情况
@property (nonatomic, assign) CGFloat tableViewScrollOffset; // tableView偏移量
@property (nonatomic, assign) CGFloat weatherScrollOffsetY; //天气view便宜量
@property (nonatomic, assign) BOOL isRefreshRoomList;    //修改房间后判断是否要刷新房间列表
@end

@implementation TIoTHomeViewController
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark lifeCircle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isHideWeatherView = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.tabBarController.tabBar.hidden = NO;
    
    if ([[TIoTCoreUserManage shared].isRreshDeviceList isEqualToString:@"1"]) {
        [self getRoomList:[TIoTCoreUserManage shared].familyId];
    }
    [TIoTCoreUserManage shared].isRreshDeviceList = @"0";
    
    if (self.devicesTableView) {
        if (self.currentFamilyId != nil) {
            
            if (self.isRefreshRoomList == NO) {
                //保持天气动画位置，跟随滚动区域是否显示
                [self scrollViewDidScroll:self.devicesTableView];
            }else {
                [self clearCMTitleView];
                [self getRoomList:[TIoTCoreUserManage shared].familyId];
            }
            
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.weatherAnimationView.hidden = YES;
    self.isHideWeatherView = YES;
    self.isRefreshRoomList = NO;
    self.currentRoomId = @"";
}

- (void)dealloc{
    [HXYNotice removeListener:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNotifications];
    
    [self setupUI];
    [self setupRefreshView];
    
    [MBProgressHUD showLodingNoneEnabledInView:[UIApplication sharedApplication].keyWindow withMessage:@""];
    [self getFamilyList];
    
    [self registFeedBackRouterController];
    
}

#pragma mark - Other

- (void)addNotifications
{
    [HXYNotice addSocketConnectSucessListener:self reaction:@selector(socketConnected)];
    [HXYNotice addUpdateDeviceListListener:self reaction:@selector(updateDevice:)];
    [HXYNotice addUpdateFamilyListListener:self reaction:@selector(getFamilyList)];
    [HXYNotice addUpdateRoomListListener:self reaction:@selector(getRoomList)];
    //进入前台需要轮训下trtc状态，防止漏接现象
    [HXYNotice addAPPEnterForegroundLister:self reaction:@selector(appEnterForeground)];
    
    [HXYNotice addReceiveShareDeviceLister:self reaction:@selector(getSharedDevicesList)];
}

- (void)appEnterForeground {
    //进入前台需要轮训下trtc状态，防止漏接现象//轮训设备状态，查看trtc设备是否要呼叫我
    [[TIoTTRTCUIManage sharedManager] repeatDeviceData:self.dataArr];
    [[TIoTTRTCUIManage sharedManager] repeatDeviceData:self.shareDataArr];
}

//通过控制器的布局视图可以获取到控制器实例对象    modal的展现方式需要取到控制器的根视图
- (UIViewController *)currentViewController
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    // modal展现方式的底层视图不同
    // 取到第一层时，取到的是UITransitionView，通过这个view拿不到控制器
    UIView *firstView = [keyWindow.subviews firstObject];
    UIView *secondView = [firstView.subviews firstObject];
    UIViewController *vc = [secondView parentController];
    
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        if ([tab.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
            return [nav.viewControllers lastObject];
        } else {
            return tab.selectedViewController;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        return [nav.viewControllers lastObject];
    } else {
        return vc;
    }
    return nil;
}

/**  集成刷新控件 */
- (void)setupRefreshView
{
    // 下拉刷新
    WeakObj(self)
//    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{
//        [selfWeak getFamilyList];
//    }];
    
//    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
//        [selfWeak loadMoreData];
//    }];
    
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.devicesTableView.mj_header.automaticallyChangeAlpha = YES;
    
    self.devicesTableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{
        [selfWeak getFamilyList];
    }];
    
//    self.devicesTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
//        [selfWeak loadMoreData];
//    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.devicesTableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)endRefresh:(BOOL)isFooter total:(NSInteger)total {
    self.offset += 10;
    
    if (isFooter) {
        if (self.offset >= total) {
            [self.devicesTableView.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [self.devicesTableView.mj_footer endRefreshing];
        }
    }
    else{
        [self.devicesTableView.mj_header endRefreshing];
        if (self.offset >= total) {
            [self.devicesTableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.devicesTableView.mj_footer endRefreshing];
        }
    }
}

- (void)refreshUI{
    
    if (self.devicesArray.count == 0) {//[data[@"Total"] integerValue] == 0) {
        
        [MBProgressHUD dismissInView:self.view];
        
        if ([NSString isNullOrNilWithObject:self.currentRoomId]) {
            if (self.shareDevicesArray.count == 0) {
                [self showEmptyView];
            }else {
                [self.devicesTableView  hideStatus];
            }
        }else {
            [self showEmptyView];
        }
        
        //房间列表显示
        self.tableHeaderView.hidden = NO;
        [self addTableHeaderView];
        [self.deviceConfigArray removeAllObjects];
        [self.devicesTableView reloadData];
        
        [self getFamilyInfoAddressWithFamilyID:self.currentFamilyId?:@""];
    }
    else{
        
        self.addBtn.hidden = YES;
        //房间列表显示
        self.tableHeaderView.hidden = NO;
        [self addTableHeaderView];
        [self.devicesTableView hideStatus];
        [self.devicesTableView reloadData];
        
        [self getFamilyInfoAddressWithFamilyID:self.currentFamilyId?:@""];
    }
    
}

- (void)refreshShareUI {
    if (self.shareDevicesArray.count == 0) {
        [self.shareDeviceConfigArray removeAllObjects];
        [self.devicesTableView reloadData];
        
    }
}

///MARK: 显示空白提示页
- (void)showEmptyView {
    WeakObj(self)
    if (!self.currentRoomId || self.currentRoomId.length == 0) {
        [self.devicesTableView showEmpty2:NSLocalizedString(@"addDeveice_immediately", @"立即添加") desc:NSLocalizedString(@"no_device_please_addition", @"当前暂无设备，请添加设备") image:[UIImage imageNamed:@"home_noDevice"] block:^{
            [selfWeak addEquipmentViewController];
        }];
        
        self.addBtn.hidden = YES;
        
        [TIoTCoreUserManage shared].currentRoomId = @"";
        
    } else {
        [self.devicesTableView showEmpty2:NSLocalizedString(@"addDeveice_immediately", @"立即添加") desc:NSLocalizedString(@"no_device_please_addition", @"当前暂无设备，请添加设备") image:[UIImage imageNamed:@"home_noDevice"] block:^{
            [selfWeak addEquipmentViewController];
        }];
    }
}

- (void)setupUI{
    self.fd_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = self.view.bounds;
    gl.startPoint = CGPointMake(0.5, 0);
    gl.endPoint = CGPointMake(0.5, 1);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0),@(1.0f)];
    [self.view.layer addSublayer:gl];
    
    [self.view addSubview:self.devicesTableView];
    [self.devicesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset([TIoTUIProxy shareUIProxy].navigationBarHeight + weatherHeight);
        make.left.right.bottom.mas_equalTo(0);
    }];
    
    
    [self setNav];
    
}

- (void)addTableHeaderView {
    
    NSMutableArray *roomNames = [NSMutableArray array];
    [roomNames addObject:NSLocalizedString(@"all__", @"全部")];
    [roomNames addObjectsFromArray:[self.rooms valueForKey:@"RoomName"]?:@[]];
    
    NSInteger index = 0;
    for (int i = 0; i < self.rooms.count; i ++) {
        RoomModel *model = self.rooms[i];
        if ([self.currentRoomId isEqualToString:model.RoomId]) {
            index = i + 1;
            break;
        }
    }
    if (index == 0) {
        self.currentRoomId = nil;
    }

    CMPageTitleConfig *config = [CMPageTitleConfig defaultConfig];
    config.cm_switchMode = CMPageTitleSwitchMode_Scale|CMPageTitleSwitchMode_Underline;
    config.cm_titles = roomNames;
    config.cm_font = [UIFont wcPfRegularFontOfSize:14];
    config.cm_selectedFont = [UIFont fontWithName:@"Helvetica" size:18];
    config.cm_normalColor = [UIColor colorWithHexString:@"#BFD2FF"];
    config.cm_selectedColor = [UIColor whiteColor];
    config.cm_additionalMode = CMPageTitleAdditionalMode_Seperateline;
    config.cm_underlineColor = [UIColor whiteColor];
    config.cm_underlineWidth = 16;
    config.cm_contentMode = CMPageTitleContentMode_Left;
    config.cm_underlineBorder = YES;
    config.cm_underlineWidthScale = 0.3;
    config.cm_underlineLabelInterval = 7;
    
    
    if (self.slideTitleBackView == nil) {
        
        //在CMPage背景后添加view底层
        self.slideTitleBackView = [[UIView alloc]initWithFrame:CGRectMake(0,kHeaderViewHeight - 44, kScreenWidth, 44)];
        self.slideTitleBackView.backgroundColor = [UIColor clearColor];
        
        [self.devicesTableView addSubview:self.slideTitleBackView];
        
        self.weatherBackImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"banner_header"]];
        self.slideTitleBackView.clipsToBounds = YES;
        [self.slideTitleBackView addSubview:self.weatherBackImage];
        [self.weatherBackImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.slideTitleBackView.mas_left);
            make.right.equalTo(self.slideTitleBackView.mas_right).offset(-7);
            make.bottom.equalTo(self.slideTitleBackView.mas_bottom);
            make.height.mas_equalTo([TIoTUIProxy shareUIProxy].navigationBarHeight + weatherHeight + 162);
        }];
        
    }
    
    
    if (self.tableHeaderView == nil) {
        self.tableHeaderView = [[CMPageTitleContentView alloc] initWithConfig:config];
        self.tableHeaderView.backgroundColor = [UIColor clearColor];
        self.tableHeaderView.frame = CGRectMake(0,0, kScreenWidth, 44);
        self.tableHeaderView.contentSize = CGSizeMake(config.cm_minContentWidth, 44);
        self.tableHeaderView.cm_delegate = self;
        self.tableHeaderView.cm_selectedIndex = index;
        [self.slideTitleBackView addSubview:self.tableHeaderView];
    }
    
    /// 添加天气UI 要在CMPageTitleContentView完后再添加 达到天气在CMPage上效果
    [self setWeatherUI];
    
}

- (void)setNav{
    //最下层固定
    [self.view addSubview:self.navView];
    
}

#pragma mark - 天气动画
- (void)setWeatherUI {
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kHeaderViewHeight)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    self.headerView.clipsToBounds = YES;
    UIImageView *backImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"banner_header"]];
    [self.headerView addSubview:backImage];
    [backImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.headerView);
        make.top.equalTo(self.headerView.mas_top).offset(-([TIoTUIProxy shareUIProxy].navigationBarHeight + weatherHeight));
        make.height.mas_equalTo([TIoTUIProxy shareUIProxy].navigationBarHeight + weatherHeight + 162);
    }];
    
    self.devicesTableView.tableHeaderView = self.headerView;
    
    
    self.weatherBottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.weatherBottomBtn addTarget:self action:@selector(chooseFamilyDetail) forControlEvents:UIControlEventTouchUpInside];
    self.weatherBottomBtn.enabled = YES;
    [self.headerView addSubview:self.weatherBottomBtn];
    [self.weatherBottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self.headerView);
    }];
    
    //添加天气数据
    self.weatherLab = [[UILabel alloc] init];
    [self.weatherLab setLabelFormateTitle:[NSString stringWithFormat:@"%@",self.weatherTemp] font:[UIFont fontWithName:@"Helvetica" size:57] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
    [self.headerView addSubview:self.weatherLab];
    [self.weatherLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        if (![NSString isNullOrNilWithObject:self.weatherTemp]) {
            make.centerY.equalTo(self.headerView).offset(-22);
        }else {
            make.centerY.equalTo(self.headerView).offset(-30);
        }
        
    }];
    
    self.unitLabel = [[UILabel alloc]init];
    
    if (![NSString isNullOrNilWithObject:self.weatherTemp]) {
        
        [self.unitLabel setLabelFormateTitle: @"˚" font:[UIFont fontWithName:@"Helvetica" size:80] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
    }else {
        [self.unitLabel setLabelFormateTitle: @"" font:[UIFont fontWithName:@"PingFang-SC" size:12] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
        
        [self.weatherLab setLabelFormateTitle:NSLocalizedString(@"no_weather_info", "暂无天气信息") font:[UIFont fontWithName:@"PingFang-SC" size:12] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
    }
    
    [self.headerView addSubview:self.unitLabel];
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.weatherLab.mas_right);
        make.top.equalTo(self.weatherLab.mas_top);
    }];
    
    self.cityMessageLabel = [[UILabel alloc]init];
    [self.cityMessageLabel setLabelFormateTitle:[NSString stringWithFormat:@"%@ %@",self.weatherText,self.weatherLocation] font:[UIFont fontWithName:@"PingFang-SC" size:12] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
    [self.headerView addSubview:self.cityMessageLabel];
    [self.cityMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (![NSString isNullOrNilWithObject:self.weatherTemp]) {
            make.bottom.equalTo(self.weatherLab.mas_bottom).offset(-11);
            make.left.equalTo(self.unitLabel.mas_left).offset(3);
        }else {
            make.bottom.equalTo(self.weatherLab.mas_bottom);
            make.left.equalTo(self.weatherLab.mas_right);
        }
        
    }];
    
    self.dailyNameLabel = [[UILabel alloc]init];
    if (![NSString isNullOrNilWithObject:self.weatherTemp]) {
        [self.dailyNameLabel setLabelFormateTitle:[NSString stringWithFormat:@"%@ %@ | %@ %@",NSLocalizedString(@"relative_humidity", @"相对湿度"),self.weatherHumidity,NSLocalizedString(@"now_windDirection", @"实况风向"),self.weatherWindDir] font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:@"#BFD2FF" textAlignment:NSTextAlignmentLeft];
    }else {
        [self.dailyNameLabel setLabelFormateTitle:NSLocalizedString(@"please_set_location", "请先设置当前家庭位置") font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:@"#BFD2FF" textAlignment:NSTextAlignmentLeft];
    }
    
    [self.headerView addSubview:self.dailyNameLabel];
    [self.dailyNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (![NSString isNullOrNilWithObject:self.weatherTemp]) {
            make.top.equalTo(self.weatherLab.mas_bottom).offset(-4);
        }else {
            make.top.equalTo(self.weatherLab.mas_bottom).offset(5);
        }
        
        make.left.equalTo(self.weatherLab.mas_left);
    }];
    
    //天气动画
    CGFloat kWeatherWidth = 150;
    CGFloat kWeatherHeight = 150;
    
    CGFloat kTopPadding = -12;
    if ([self.weatherTypeText isEqualToString:@"WeatherTypeRain"]) {
        kTopPadding = -20;
    }
    
    if (self.weatherAnimationView == nil) {
        self.animationVC = [[TIoTWeatherVC alloc]init];
        self.weatherAnimationView = [self.animationVC weatherAnimationWithJsName:self.weatherTypeText animationFrame:CGRectMake(0, 0, 300, 300)];
        [[UIApplication sharedApplication].delegate.window addSubview:self.weatherAnimationView];
        [self.weatherAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo([TIoTUIProxy shareUIProxy].navigationBarHeight + weatherHeight+kTopPadding);
            make.leading.mas_equalTo(kScreenWidth-kWeatherWidth+5);
            make.height.mas_equalTo(kWeatherWidth);
            make.width.mas_equalTo(kWeatherHeight);
        }];
        self.weatherAnimationView.hidden = YES;
    }
    
}

///MARK: 查询家庭的地址
- (void)getFamilyInfoAddressWithFamilyID:(NSString *)currentFamilyId {
    
    NSDictionary *param = @{@"FamilyId":currentFamilyId};
    [[TIoTRequestObject shared] post:AppDescribeFamily Param:param success:^(id responseObject) {
        
        NSString *addressString = responseObject[@"Data"][@"Address"]?:@"";
        
        NSDictionary *dic =  [NSString jsonToObject:addressString?:@""];
        if (dic != nil) {
            double lat = [dic[@"latitude"] doubleValue];
            double lng = [dic[@"longitude"] doubleValue];
            
            self.latitude = lat;
            self.longitude = lng;
            
            //请求天气数据
            [self requestWeatherData];
            
        }else {
            [self getFamilyLocationWith:addressString];
        }
        
        
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

///MARK: 获取家庭经纬度
- (void)getFamilyLocationWith:(NSString *)addressString {
    TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@&key=%@",MapSDKAddressParseURL,addressString?:@"",model.TencentMapSDKValue];
    
    NSString *urlEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    [[TIoTRequestObject shared] get:urlEncoded isNormalRequest:YES success:^(id responseObject) {
        TIoTAddressParseModel *addressModel = [TIoTAddressParseModel yy_modelWithJSON:responseObject[@"result"]];
        
        self.latitude = addressModel.location.lat;
        self.longitude = addressModel.location.lng;
        
        //请求天气数据
        [self requestWeatherData];
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

///MARK: 请求天气数据
- (void)requestWeatherData {

    [self requestWeatherNowData];
}

///MARK:请求天气实况
- (void)requestWeatherNowData {
    [TIoTAppUtil getWeatherTypeWithLocation:[NSString stringWithFormat:@"%f,%f",self.longitude,self.latitude] completion:^(NSString * _Nonnull temp, NSString * _Nonnull weatherType, NSString * _Nonnull windDir, NSString * _Nonnull weatherContent, NSString * _Nonnull humidity) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.weatherTemp = temp;
            self.weatherWindDir = windDir;
            self.weatherText = weatherContent;
            self.weatherTypeText = weatherType;
            self.weatherHumidity = humidity;
            if (![NSString isNullOrNilWithObject:temp]) {
                
                [self.weatherLab setLabelFormateTitle:[NSString stringWithFormat:@"%@",self.weatherTemp] font:[UIFont fontWithName:@"Helvetica" size:57] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
                [self.unitLabel setLabelFormateTitle: @"˚" font:[UIFont fontWithName:@"Helvetica" size:80] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
                [self.dailyNameLabel setLabelFormateTitle:[NSString stringWithFormat:@"%@ %@ | %@ %@",NSLocalizedString(@"relative_humidity", @"相对湿度"),self.weatherHumidity,NSLocalizedString(@"now_windDirection", @"实况风向"),self.weatherWindDir] font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:@"#BFD2FF" textAlignment:NSTextAlignmentLeft];
                
                self.weatherBottomBtn.enabled = NO;
                
                if (self.isHideWeatherView == NO) {
                    
                    CGFloat offSetY = self.tableViewScrollOffset;
                    CGFloat kOrigionY = 162 - 44+1;
                    CGFloat kWeatherOriX = kScreenWidth - 150/2 + 5;
                    if (offSetY > 0 && offSetY <= kOrigionY) {
                        if (![NSString isNullOrNilWithObject:self.weatherTemp]) {
                            self.weatherBottomBtn.enabled = NO;
                            self.weatherAnimationView.hidden = NO;
                            self.weatherAnimationView.center = CGPointMake(kWeatherOriX, self.weatherScrollOffsetY);
                            self.weatherAnimationView.alpha = (kOrigionY - offSetY)/kOrigionY;
                        }else {
                            self.weatherBottomBtn.enabled = YES;
                            self.weatherAnimationView.hidden = YES;
                        }
                    }else if (offSetY > kOrigionY) {
                        self.weatherAnimationView.hidden = YES;
                    }else {
                        self.weatherAnimationView.hidden = NO;
                    }
                    
                }
                if ( [NSString isNullOrNilWithObject:self.weatherContentTypeText] || ![self.weatherContentTypeText isEqualToString:self.weatherTypeText]) {
              [self.animationVC switchWeatherAnimationWithJsName:self.weatherTypeText];
                }
                
            }else {
                
                [self.unitLabel setLabelFormateTitle: @"" font:[UIFont fontWithName:@"PingFang-SC" size:12] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
                [self.weatherLab setLabelFormateTitle:NSLocalizedString(@"no_weather_info", "暂无天气信息") font:[UIFont fontWithName:@"PingFang-SC" size:12] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
                [self.dailyNameLabel setLabelFormateTitle:NSLocalizedString(@"please_set_location", "请先设置当前家庭位置") font:[UIFont wcPfRegularFontOfSize:16] titleColorHexString:@"#BFD2FF" textAlignment:NSTextAlignmentLeft];
                self.weatherBottomBtn.enabled = YES;
                self.weatherAnimationView.hidden = YES;
            }
            
            [self requestWeatherCityData];
            
            self.weatherContentTypeText = weatherType;
        });
    }];
    
}

///MARK:请求城市信息
- (void)requestWeatherCityData {
    [TIoTAppUtil getWeatherCityDataTaskWithLocation:[NSString stringWithFormat:@"%f,%f",self.longitude,self.latitude] completion:^(NSString * _Nonnull cityName) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.weatherLocation = cityName;
            if (![NSString isNullOrNilWithObject:cityName]) {
                [self.cityMessageLabel setLabelFormateTitle:[NSString stringWithFormat:@"%@ %@",self.weatherText,self.weatherLocation] font:[UIFont fontWithName:@"PingFang-SC" size:12] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
            }else {
                [self.cityMessageLabel setLabelFormateTitle:@"" font:[UIFont fontWithName:@"PingFang-SC" size:12] titleColorHexString:@"#FFFFFF" textAlignment:NSTextAlignmentLeft];
                
            }
            
        });
    }];
}

- (void)socketConnected
{
//    dispatch_semaphore_signal(self.sem);
}

/// 天气无数据时候，点击天气view进入家庭详情
- (void)chooseFamilyDetail {
    for (FamilyModel *model in self.families) {
        if ([self.currentFamilyId isEqualToString:model.FamilyId]) {
            NSDictionary * familyDic= [model yy_modelToJSONObject];
            TIoTFamilyInfoVC *vc = [[TIoTFamilyInfoVC alloc] init];
            vc.familyInfo = familyDic;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

/// 通过MGJRouter 注册帮助反馈控制器，以便点击通知后跳转
- (void)registFeedBackRouterController {
        
    [MGJRouter registerURLPattern:@"TIoT://TPNSPushManage/feedback" toHandler:^(NSDictionary *routerParameters) {
        //传入推送的全部信息，在控制器内部取出URL，进行展示
        NSString *url = routerParameters[MGJRouterParameterUserInfo][@"customMessageContent"][@"url"]?:@"";
        if (url.length) {
            TIoTWebVC *vc = [[TIoTWebVC alloc] init];
            vc.title = NSLocalizedString(@"feedbak_detail", @"反馈详情");
            vc.urlPath = [self judgeToAppendAppTypeWithUrl:url];
            vc.needJudgeJump = YES;
            UIViewController *topVc = [self topViewController];
            if ([topVc isMemberOfClass:[TIoTWebVC class]]) {
                [topVc performSelector:@selector(loadUrl:) withObject:[self judgeToAppendAppTypeWithUrl:url]];
            } else {
                [topVc.navigationController pushViewController:vc animated:YES];
            }
        }
    }];
}

- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

- (NSString *)judgeToAppendAppTypeWithUrl:(NSString *)url {
    NSRange range = [url rangeOfString:@"?#"];
    NSMutableString *mString = [NSMutableString stringWithString:url];
    if (range.location != NSNotFound) {
        NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        [mString insertString:[NSString stringWithFormat:@"appID=%@&lang=%@", bundleId,[TIoTAppUtilOC getLangParameter]] atIndex:range.location+1];
        return [NSString stringWithString:mString];
    } else {
        return url;
    }
}

#pragma mark - request

- (void)getFamilyList
{
    [[TIoTRequestObject shared] post:AppGetFamilyList Param:@{} success:^(id responseObject) {
        self.families = [NSArray yy_modelArrayWithClass:[FamilyModel class] json:responseObject[@"FamilyList"]];
        
        if (self.families.count > 0) {
            if (!self.currentFamilyId) {
                [self chooseFamilyByIndex:0];
            }
            else
            {
                BOOL isExit = NO;
                for (FamilyModel *model in self.families) {
                    if ([self.currentFamilyId isEqualToString:model.FamilyId]) {
                        isExit = YES;
                        [self getRoomList:self.currentFamilyId];
                        break;
                    }
                }
                
                if (!isExit) {//当前选中家庭不存在
                    [self chooseFamilyByIndex:0];
                }
            }
            
        }
        else
        {
            [self createFamily];
        }
        
        [[TIoTRequestObject shared] post:AppGetUser Param:@{} success:^(id responseObject) {
            NSDictionary *data = responseObject[@"Data"];
            [[TIoTCoreUserManage shared] saveUserInfo:data];
            //上报用户userid
            [FIRAnalytics setUserID:[TIoTCoreUserManage shared].userId];
            [[FIRCrashlytics crashlytics] setUserID:[TIoTCoreUserManage shared].userId];
            
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)getRoomList {
    self.isRefreshRoomList = YES;
}

- (void)getRoomList:(NSString *)familyId
{
    if (familyId == nil) {
        return;
    }
    [[TIoTRequestObject shared] post:AppGetRoomList Param:@{@"FamilyId":familyId} success:^(id responseObject) {
        self.rooms = [NSArray yy_modelArrayWithClass:[RoomModel class] json:responseObject[@"RoomList"]];
        
        [self loadNewData];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
    
}

- (void)loadNewData{
    self.offset = 0;
    NSString *roomId = self.currentRoomId ?: @"";
    NSString *familyId = self.currentFamilyId ?: @"";
    
    [[TIoTRequestObject shared] post:AppGetFamilyDeviceList Param:@{@"FamilyId":familyId,@"RoomId":roomId,@"Offset":@(self.offset),@"Limit":@(1000000)} success:^(id responseObject) {
        [self endRefresh:NO total:[responseObject[@"Total"] integerValue]];
        
        [self.dataArr removeAllObjects];
        [self.dataArr addObjectsFromArray:responseObject[@"DeviceList"]];
        
        //刷新新页面时候，需要清空
        [self.deviceConfigArray removeAllObjects];
        
        [self updateDeviceStatus];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
    
    [self getSharedDevicesList];
}

- (void)loadMoreData{
    
    NSString *roomId = self.currentRoomId ?: @"";
    [[TIoTRequestObject shared] post:AppGetFamilyDeviceList Param:@{@"FamilyId":self.currentFamilyId,@"RoomId":roomId,@"Offset":@(self.offset),@"Limit":@(10)} success:^(id responseObject) {
        [self endRefresh:YES total:[responseObject[@"Total"] integerValue]];
        [self.dataArr addObjectsFromArray:responseObject[@"DeviceList"]];
        
        NSArray *tempListArr = responseObject[@"DeviceList"];
        for (int i = 0; i < tempListArr.count; i+=2) {
            
            NSArray *itemArr = nil;
            if (i+1 <= tempListArr.count-1) {
                itemArr = @[tempListArr[i],tempListArr[i+1]];
            }else {
                itemArr = @[tempListArr[i]];
            }
//            NSArray *itemArr = @[tempListArr[i],tempListArr[i+1]];
            
            [self.devicesArray addObject:itemArr];
            
        }
        
        if (self.dataArr.count == 0) {
            [self refreshUI];
        }
        
        if (self.devicesArray.count == 0) {
            [self refreshUI];
        }
        
        
        [self updateDeviceStatus];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
    
}

//获取设备状态
- (void)updateDeviceStatus{
    
    NSArray *arr = [self.dataArr valueForKey:@"DeviceId"];
//    self.deviceIds = [arr copy];
//    dispatch_semaphore_signal(self.sem);
    
    if (arr.count > 0) {
        NSDictionary *dic = @{@"ProductId":self.dataArr[0][@"ProductId"],@"DeviceIds":arr};
        
        [[TIoTRequestObject shared] post:AppGetDeviceStatuses Param:dic success:^(id responseObject) {
            NSArray *statusArr = responseObject[@"DeviceStatuses"];
            
            NSMutableArray *tmpArr = [NSMutableArray array];
            for (NSDictionary *tmpDic in self.dataArr) {
                
                NSString *deviceId = tmpDic[@"DeviceId"];
                for (NSDictionary *statusDic in statusArr) {
                    if ([deviceId isEqualToString:statusDic[@"DeviceId"]]) {
                        NSString *onLineSing = [NSString stringWithFormat:@"%@",statusDic[@"Online"]?:@""];
                        if (!([NSString isNullOrNilWithObject:onLineSing] || onLineSing.integerValue < 0)) {
                            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                            [dic addEntriesFromDictionary:tmpDic];
                            [dic setValue:statusDic[@"Online"] forKey:@"Online"];
                            
                            [tmpArr addObject:dic];
                            break;
                        }
                       
                    }
                }
                
                
            }
            
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:tmpArr];
            
            [self.devicesArray removeAllObjects];
            for (int i = 0; i < tmpArr.count; i+=2) {
                NSArray *itemArr = nil;
                if (i+1 <= tmpArr.count-1) {
                    itemArr = @[tmpArr[i],tmpArr[i+1]];
                }else {
                    itemArr = @[tmpArr[i]];
                }
                
                [self.devicesArray addObject:itemArr];
                
            }
            
            
            [self refreshUI];
            
            //配对dataArr 个数，请求每个设备的快捷入口相关数据；数据deviceConfigArray 和原始数据dataArray 相同后 保证一一匹配，才能reload
            NSMutableArray *productidArr = [NSMutableArray new];
            for (int i = 0; i< self.dataArr.count; i++) {
                NSString *productIDString = self.dataArr[i][@"ProductId"] ?:@"";
                [productidArr addObject:productIDString];
            }
            [self requestDeviceEquipmentWithProductID:productidArr isSharedDevice:NO];
            
            //轮训设备状态，查看trtc设备是否要呼叫我,只执行一次，防止过度刷新
            [self onceFrushTRTCDevice];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }else {
        NSArray *tempListArray = [NSArray arrayWithArray:self.dataArr];
        [self.devicesArray removeAllObjects];
        for (int i = 0; i < tempListArray.count; i+=2) {

            NSArray *itemArr = nil;
            if (i+1 <= tempListArray.count-1) {
                itemArr = @[tempListArray[i],tempListArray[i+1]];
            }else {
                itemArr = @[tempListArray[i]];
            }

//            NSArray *itemArr = @[tempListArray[i],tempListArray[i+1]];

            [self.devicesArray addObject:itemArr];

        }
//        //刷新新页面时候，需要清空
//        [self.deviceConfigArray removeAllObjects];
        
        if (self.devicesArray.count == 0 || self.dataArr.count == 0) {
            [self refreshUI];
        }
    }
}

///MARK: 分享设备列表请求
- (void)getSharedDevicesList {
    
    [[TIoTRequestObject shared] post:AppListUserShareDevices Param:@{@"Offset":@0,@"Limit":@1000000} success:^(id responseObject) {
        
        [self endRefresh:NO total:[responseObject[@"Total"] integerValue]];
        
        [self.shareDataArr removeAllObjects];
        [self.shareDataArr addObjectsFromArray:responseObject[@"ShareDevices"]];
        
        [self.shareDeviceConfigArray removeAllObjects];
        
        NSArray *shareDeviceArray = [NSArray arrayWithArray:responseObject[@"ShareDevices"]?:@[]];
        
        NSArray *prodictIDArr = [shareDeviceArray valueForKey:@"ProductId"]?:@[];
        
        [self getShareDeviceListInfo:prodictIDArr];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

///MARK: 获取分享设备列表设备信息
- (void)getShareDeviceListInfo:(NSArray *)productIDsArray {
    [[TIoTRequestObject shared] post:AppGetProducts Param:@{@"ProductIds":productIDsArray?:@[]} success:^(id responseObject) {
        NSArray *deviceInfoArr = responseObject[@"Products"];
        
        NSMutableArray *tmpArr = [NSMutableArray array];
        for (NSDictionary *tmpDic in self.shareDataArr) {
            
            NSString *deviceId = tmpDic[@"ProductId"];
            for (NSDictionary *statusDic in deviceInfoArr) {
                if ([deviceId isEqualToString:statusDic[@"ProductId"]]) {
                    NSString *onLineSing = [NSString stringWithFormat:@"%@",statusDic[@"Name"]?:@""];
                    if (!([NSString isNullOrNilWithObject:onLineSing] || onLineSing.integerValue < 0)) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic addEntriesFromDictionary:tmpDic];
                        [dic setValue:statusDic[@"Name"] forKey:@"AliasName"];
                        [tmpArr addObject:dic];
                        break;
                    }
                    
                }
            }
            
        }
        
        [self.shareDataArr removeAllObjects];
        [self.shareDataArr addObjectsFromArray:tmpArr];
        
        [self updateSharedDeviceStatus];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

///MARK:获取分享设备状态
- (void)updateSharedDeviceStatus{
    NSArray *arr = [self.shareDataArr valueForKey:@"DeviceId"];
    if (arr.count > 0) {
        NSDictionary *dic = @{@"ProductId":self.shareDataArr[0][@"ProductId"],@"DeviceIds":arr};
        
        [[TIoTRequestObject shared] post:AppGetDeviceStatuses Param:dic success:^(id responseObject) {
            NSArray *statusArr = responseObject[@"DeviceStatuses"];
            
            NSMutableArray *tmpArr = [NSMutableArray array];
            for (NSDictionary *tmpDic in self.shareDataArr) {
                
                NSString *deviceId = tmpDic[@"DeviceId"];
                for (NSDictionary *statusDic in statusArr) {
                    if ([deviceId isEqualToString:statusDic[@"DeviceId"]]) {
                        NSString *onLineSing = [NSString stringWithFormat:@"%@",statusDic[@"Online"]?:@""];
                        if (!([NSString isNullOrNilWithObject:onLineSing] || onLineSing.integerValue < 0)) {
                            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                            [dic addEntriesFromDictionary:tmpDic];
                            [dic setValue:statusDic[@"Online"] forKey:@"Online"];
                            [tmpArr addObject:dic];
                            break;
                        }
                    }
                }
            }
            
            [self.shareDataArr removeAllObjects];
            [self.shareDataArr addObjectsFromArray:tmpArr];
            
            [self.shareDevicesArray removeAllObjects];
            
            for (int i = 0; i < tmpArr.count; i+=2) {
                NSArray *itemArr = nil;
                if (i+1 <= tmpArr.count-1) {
                    itemArr = @[tmpArr[i],tmpArr[i+1]];
                }else {
                    itemArr = @[tmpArr[i]];
                }
                
                [self.shareDevicesArray addObject:itemArr];
                
            }
            
            [self refreshShareUI];
            
            //共享设备 配对原始请求数据进行拆分
            NSMutableArray *shareProductidArr = [NSMutableArray new];
            for (int i = 0; i< self.shareDataArr.count; i++) {
                NSString *productIDString = self.shareDataArr[i][@"ProductId"] ?:@"";
                [shareProductidArr addObject:productIDString];
            }
            [self requestDeviceEquipmentWithProductID:shareProductidArr isSharedDevice:YES];
            
            [self onceFrushTRTCShareDevice];
            
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }else {
        [self.shareDevicesArray removeAllObjects];
        NSArray *tempListArr = [NSArray arrayWithArray:self.shareDataArr];
        for (int i = 0; i < tempListArr.count; i+=2) {
            
            NSArray *itemArr = nil;
            if (i+1 <= tempListArr.count-1) {
                itemArr = @[tempListArr[i],tempListArr[i+1]];
            }else {
                itemArr = @[tempListArr[i]];
            }
//            NSArray *itemArr = @[tempListArr[i],tempListArr[i+1]];
            
            [self.shareDevicesArray addObject:itemArr];
            
        }
        
        if (self.shareDevicesArray.count == 0 || self.shareDataArr.count == 0) {
            [self refreshShareUI];
        }
    }
}

- (void)onceFrushTRTCShareDevice {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //轮训设备状态，查看trtc设备是否要呼叫我
        [[TIoTTRTCUIManage sharedManager] repeatDeviceData:self.shareDataArr];
    });
}

- (void)onceFrushTRTCDevice {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //轮训设备状态，查看trtc设备是否要呼叫我
        [[TIoTTRTCUIManage sharedManager] repeatDeviceData:self.dataArr];
    });
}

- (void)createFamily
{
    NSDictionary *param = @{@"Name":NSLocalizedString(@"my_family", @"我的家") ,@"Address":@""};
    [[TIoTRequestObject shared] post:AppCreateFamily Param:param success:^(id responseObject) {
        [self getFamilyList];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

//MARK: 获取添加快捷入口的设备信息（是否显示开关，快捷项有多少）
- (void)requestDeviceEquipmentWithProductID:(NSMutableArray *)IdArray isSharedDevice:(BOOL)isShared{

    [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":IdArray?:@[]} success:^(id responseObject) {
        NSArray *data = responseObject[@"Data"];
        if (data.count > 0) {
            
            //和devicesArray 组合方式一样，将源数据按照@[@{},@{}] 为一个cellItem重新组装
            for (int i = 0; i < data.count; i+=2) {
                
                NSArray *itemArr = nil;
                if (i+1 <= data.count-1) {
                    NSDictionary *configLeft = [NSString jsonToObject:data[i][@"Config"]]?:@{};
                    NSDictionary *shortcutDicLeft = configLeft?:@{};
                    
                    NSDictionary *configRight = [NSString jsonToObject:data[i+1][@"Config"]]?:@{};
                    NSDictionary *shortcutDicRight = configRight?:@{};
                    
                    itemArr = @[shortcutDicLeft,shortcutDicRight];
                }else {
                    NSDictionary *configLeft = [NSString jsonToObject:data[i][@"Config"]]?:@{};
                    NSDictionary *shortcutDicLeft = configLeft?:@{};
                    itemArr = @[shortcutDicLeft];
                }
                
                if (isShared == NO) {
                    [self.deviceConfigArray addObject:itemArr];
                }else {
                    [self.shareDeviceConfigArray addObject:itemArr];
                }
                
            }
            
            [self.devicesTableView reloadData];
        }
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {

    }];
}

#pragma mark - event

///MARK:切换家庭 切换家庭需要清空房间ID
- (void)chooseFamilyByIndex:(NSInteger)index
{
    
    FamilyModel *model = self.families[index];
    [TIoTCoreUserManage shared].familyId = model.FamilyId;
    self.nick.text = model.FamilyName;
    self.currentFamilyId = model.FamilyId;
    self.currentFamilyRole = model.Role;
    [TIoTCoreUserManage shared].FamilyType = model.FamilyType;
    
    //涉及到房间变化，需要clear再刷新
    [self clearCMTitleView];
    
    //切换家庭需要清空房间ID
    self.currentRoomId = nil;
    [self.devicesTableView hideStatus];
    
    [self getRoomList:model.FamilyId];
    
    //查询家庭的地址
    [self getFamilyInfoAddressWithFamilyID:model.FamilyId?:@""];
}

///MARK:清理CMTitleContentView 保证每次切换房间都能刷新rooms
- (void)clearCMTitleView {
    [self.tableHeaderView removeFromSuperview];
    self.tableHeaderView = nil;
}

- (void)messageClick:(id)sender{
    TIoTMessageViewController *vc = [[TIoTMessageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addClick:(id)sender{
    [self addEquipmentViewController];
}

- (void)updateDevice:(id)sender{
    [self loadNewData];
}

//添加设备
- (void)addEquipmentViewController{
    TIoTNewAddEquipmentViewController *vc = [[TIoTNewAddEquipmentViewController alloc] init];
    vc.roomId = self.currentRoomId ?: @"";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)selectFamily:(UIButton *)sender
{
    if (self.families) {
        TIoTOptionalView *vv = [[TIoTOptionalView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        vv.selected = ^(NSInteger index) {
            [self chooseFamilyByIndex:index];
        };
        vv.doneAction = ^{
            UIViewController *vc = [[NSClassFromString(@"TIoTFamiliesVC") alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        };
        vv.currentValue = self.currentFamilyId;
        vv.titles = self.families;
        [vv show];
//        WCPopoverVC *viewVC = [[WCPopoverVC alloc] init];
//        viewVC.families = self.families;
//        viewVC.update = ^(NSInteger index) {
//            [self chooseFamilyByIndex:index];
//        };
//        viewVC.preferredContentSize =CGSizeMake(150,self.families.count * 60);
//        viewVC.modalPresentationStyle =UIModalPresentationPopover;
//        
//        UIPopoverPresentationController *popVC = viewVC.popoverPresentationController;
//        popVC.delegate = self;
//        popVC.sourceView = sender;
//        CGRect rect = sender.bounds;
//        rect.size.width = 100;
//        popVC.sourceRect = rect;
//        
//        popVC.permittedArrowDirections =UIPopoverArrowDirectionUp;
//        [self presentViewController:viewVC animated:YES completion:nil];
    }
}


#pragma mark - TableViewDelegate && TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([NSString isNullOrNilWithObject:self.currentRoomId]) {   //【全部】房间
        if (self.shareDevicesArray.count>0 && self.devicesArray.count>0) {
            return 2;
        }else {
            return 1;
        }
    }else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([NSString isNullOrNilWithObject:self.currentRoomId]) {   //【全部】房间
        if (self.shareDevicesArray.count > 0 && self.devicesArray.count > 0) {
            if (section == 0) {
                return self.devicesArray.count;
            }else {
                return self.shareDevicesArray.count;
            }
        }else if (self.shareDevicesArray.count > 0 && self.devicesArray.count == 0){
            return self.shareDevicesArray.count;
        }else if (self.shareDevicesArray.count == 0 && self.devicesArray.count > 0) {
            return self.devicesArray.count;
        }else {
            return 0;
        }
    }else {
        return self.devicesArray.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([NSString isNullOrNilWithObject:self.currentRoomId]) {   //【全部】房间
        if (self.shareDevicesArray.count > 0 && self.devicesArray.count > 0) {
            if (indexPath.section == 0) {
                return [self cellForDeviceWithTableView:tableView IndexPath:indexPath sourceData:self.dataArr newDeivceData:self.devicesArray configData:self.deviceConfigArray];
            }else {
                return [self cellForDeviceWithTableView:tableView IndexPath:indexPath sourceData:self.shareDataArr newDeivceData:self.shareDevicesArray configData:self.shareDeviceConfigArray];
            }
        }else if (self.shareDevicesArray.count > 0 && self.devicesArray.count == 0){
            return [self cellForDeviceWithTableView:tableView IndexPath:indexPath sourceData:self.shareDataArr newDeivceData:self.shareDevicesArray configData:self.shareDeviceConfigArray];
        }else if (self.shareDevicesArray.count == 0 && self.devicesArray.count > 0) {
            return [self cellForDeviceWithTableView:tableView IndexPath:indexPath sourceData:self.dataArr newDeivceData:self.devicesArray configData:self.deviceConfigArray];
        }else {
            return [self cellForDeviceWithTableView:tableView IndexPath:indexPath sourceData:self.dataArr newDeivceData:self.devicesArray configData:self.deviceConfigArray];
        }
    }else {
        return [self cellForDeviceWithTableView:tableView IndexPath:indexPath sourceData:self.dataArr newDeivceData:self.devicesArray configData:self.deviceConfigArray];
    }
    
}

- (UITableViewCell *)cellForDeviceWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath sourceData:(NSMutableArray *)sourceDataArray newDeivceData:(NSMutableArray *)devicesDataArray configData:(NSMutableArray *)configDataArray {
    
    TIoTEquipmentNewCell *cell = [TIoTEquipmentNewCell cellWithTableView:tableView];
    if (indexPath.row < devicesDataArray.count) {
        [cell setCellDataArray:devicesDataArray[indexPath.row]];
    }
    
    [cell setSelectIndexPatch:indexPath];
    
    __weak typeof(self) weakSelf = self;
    cell.clickLeftDeviceBlock = ^(NSIndexPath * _Nonnull leftIndexPath) {
        [weakSelf chooseDeviceWith:leftIndexPath withDataArr:sourceDataArray];
    };
    
    cell.clickRightDeviceBlock = ^(NSIndexPath * _Nonnull rightIndexPath) {
        [weakSelf chooseDeviceWith:rightIndexPath withDataArr:sourceDataArray];
    };
    
    if (indexPath.row < configDataArray.count) {
        [cell setDeviceConfigArray:configDataArray[indexPath.row]?:@[]];
    }
    
    cell.clickQuickBtnBlock = ^(NSDictionary * _Nonnull productData, NSDictionary * _Nonnull configData, NSArray * _Nonnull shortcutConfigArray){
        
        NSArray *devIds = @[productData[@"DeviceId"]];
        [HXYNotice postHeartBeat:devIds];
        [HXYNotice addActivePushPost:devIds];
        
        NSString * alias = productData[@"AliasName"];
        NSString *deviceName = @"";
        if (alias && [alias isKindOfClass:[NSString class]] && alias.length > 0) {
            
            deviceName = alias;
            
        } else {
            
            deviceName = productData[@"DeviceName"];
        }
        
        __weak typeof(self)weakSelf = self;
        TIoTShortcutView *shortcut = [[TIoTShortcutView alloc]init];
        [shortcut shortcutViewData:configData?:@{} productId:productData[@"ProductId"]?:@"" deviceDic:[productData mutableCopy] withDeviceName:deviceName shortcutArray:shortcutConfigArray];
        
        shortcut.moreFunctionBlock = ^{
            
            //点击更多进入设备面板详情
            TIoTPanelVC *vc = [[TIoTPanelVC alloc] init];
            weakSelf.navigationController.tabBarController.tabBar.hidden = YES;
            vc.title = [NSString stringWithFormat:@"%@",productData[@"AliasName"]];
            vc.productId = productData[@"ProductId"];
            vc.deviceName = [NSString stringWithFormat:@"%@",productData[@"DeviceName"]];
            vc.deviceDic = [productData mutableCopy];
            vc.isOwner = [weakSelf.currentFamilyRole integerValue] == 1;
            vc.configData = configData?:@{};
            [weakSelf.navigationController pushViewController:vc animated:YES];
            
        };
        [weakSelf.view addSubview:shortcut];
        
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)chooseDeviceWith:(NSIndexPath *)indexPath withDataArr:(NSMutableArray *)dataArr{
    
    NSMutableArray *dataArray = [NSMutableArray arrayWithArray:dataArr?:@[]];
    
    NSArray *devIds = @[dataArray[indexPath.row][@"DeviceId"]];
    //    if ([WCWebSocketManage shared].socketReadyState == SR_OPEN) {
    [HXYNotice postHeartBeat:devIds];
    [HXYNotice addActivePushPost:devIds];
    
    //    }
    //    else
    //    {
    //        [MBProgressHUD showError:@"请检查网络"];
    //    }
    
    NSString *productIDString = dataArray[indexPath.row][@"ProductId"] ?:@"";
    
    [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":@[productIDString]} success:^(id responseObject) {
        NSArray *data = responseObject[@"Data"];
        if (data.count > 0) {
            NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
            
            TIoTProductConfigModel *configModel = [TIoTProductConfigModel yy_modelWithJSON:config];
            if ([configModel.Panel.type isEqualToString:@"h5"]) {
                
                self.currentRoomId = [TIoTCoreUserManage shared].currentRoomId?:@"";
                
                //h5自定义面板
                NSDictionary *deviceDic = [dataArray[indexPath.row] copy];
                NSString *deviceID = deviceDic[@"DeviceId"];
                NSString *familyId = [TIoTCoreUserManage shared].familyId;
                NSString *roomID = self.currentRoomId ? : @"0";
                NSString *familyType = [NSString stringWithFormat:@"%ld",(long)[TIoTCoreUserManage shared].FamilyType];
                
                __weak typeof(self) weadkSelf= self;
                
                [MBProgressHUD showLodingNoneEnabledInView:[UIApplication sharedApplication].keyWindow withMessage:@""];
                [[TIoTRequestObject shared] post:AppGetTokenTicket Param:@{} success:^(id responseObject) {
                    
                    DDLogDebug(@"AppGetTokenTicket responseObject%@", responseObject);
                    NSString *ticket = responseObject[@"TokenTicket"]?:@"";
                    NSString *requestID = responseObject[@"RequestId"]?:@"";
                    NSString *platform = @"iOS";
                    TIoTWebVC *vc = [TIoTWebVC new];
                    weadkSelf.navigationController.tabBarController.tabBar.hidden = YES;
                    NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
                    NSString *url = [NSString stringWithFormat:@"%@/?deviceId=%@&familyId=%@&appID=%@&roomId=%@&familyType=%@&lid=%@&quid=%@&platform=%@&regionId=%@&ticket=%@&uin=%@", [TIoTCoreAppEnvironment shareEnvironment].deviceDetailH5URL,deviceID,familyId,bundleId,roomID,familyType,requestID,requestID,platform,[TIoTCoreUserManage shared].userRegionId,ticket,TIoTAPPConfig.GlobalDebugUin];
                    vc.urlPath = url;
                    vc.needJudgeJump = YES;
                    vc.needRefresh = YES;
                    vc.deviceDic = [dataArray[indexPath.row] mutableCopy];
                    [weadkSelf.navigationController pushViewController:vc animated:YES];
                    [MBProgressHUD dismissInView:weadkSelf.view];
                    
                } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                    [MBProgressHUD dismissInView:weadkSelf.view];
                }];
                
            }else {
                
                //标准面板
                TIoTPanelVC *vc = [[TIoTPanelVC alloc] init];
                self.navigationController.tabBarController.tabBar.hidden = YES;
                vc.title = [NSString stringWithFormat:@"%@",dataArray[indexPath.row][@"AliasName"]];
                vc.productId = dataArray[indexPath.row][@"ProductId"];
                vc.deviceName = [NSString stringWithFormat:@"%@",dataArray[indexPath.row][@"DeviceName"]];
                vc.deviceDic = [dataArray[indexPath.row] mutableCopy];
                vc.isOwner = [self.currentFamilyRole integerValue] == 1;
                vc.configData = config;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([NSString isNullOrNilWithObject:self.currentRoomId]) {   //【全部】房间
        if (self.shareDataArr.count>0 && self.dataArr.count>0) {
            if (section == 0) {
                return [self getDeviceHeaderSectionView];
            }else {
                return [self getShareDeviceHeaderSectionView];
            }
        }else if (self.shareDataArr.count > 0 && self.dataArr.count == 0){
            return [self getShareDeviceHeaderSectionView];
        }else if (self.shareDataArr.count == 0 && self.dataArr.count > 0) {
            return [self getDeviceHeaderSectionView];
        }else {
            return nil;
        }
    }else {
        if (self.dataArr.count != 0) {
            return [self getDeviceHeaderSectionView];
        }else {
            return nil;
        }
    }
    
}

///MARK: 非共享设备sectionView
- (UIView *)getDeviceHeaderSectionView {
    UIView *headerSectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    headerSectionView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    UILabel *sectionTitle = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, kScreenWidth, 44)];
    NSString *titleString = [NSString stringWithFormat:@"%@(%lu)",NSLocalizedString(@"my_devices", @"我的设备"),(unsigned long)self.dataArr.count];
    [sectionTitle setLabelFormateTitle:titleString font:[UIFont wcPfMediumFontOfSize:14] titleColorHexString:@"#15161A" textAlignment:NSTextAlignmentLeft];
    [headerSectionView addSubview:sectionTitle];

    return headerSectionView;
}

///MARK: 共享设备sectionView
- (UIView *)getShareDeviceHeaderSectionView {
    UIView *shareHeaderSectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    shareHeaderSectionView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    UILabel *sectionTitle = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, kScreenWidth, 44)];
    NSString *titleString = [NSString stringWithFormat:@"%@(%lu)",NSLocalizedString(@"shared_devices", @"共享设备"),(unsigned long)self.shareDataArr.count];
    [sectionTitle setLabelFormateTitle:titleString font:[UIFont wcPfMediumFontOfSize:14] titleColorHexString:@"#15161A" textAlignment:NSTextAlignmentLeft];
    [shareHeaderSectionView addSubview:sectionTitle];

    return shareHeaderSectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offSetY = scrollView.contentOffset.y;
    self.tableViewScrollOffset = offSetY;
    
    CGFloat limit = 44 + weatherHeight;
    if (offSetY <= -(limit + [TIoTUIProxy shareUIProxy].statusHeight)) {
        self.navView.hidden = NO;
    }
    else if (offSetY > -(limit + [TIoTUIProxy shareUIProxy].statusHeight))
    {
        self.navView.hidden = NO;
        if (offSetY > -[TIoTUIProxy shareUIProxy].statusHeight) {
            //向上滑动
            self.slideTitleBackView.hidden = NO;
        }
        else
        {
            self.slideTitleBackView.hidden = NO;
        }
    }
    
    CGFloat kOrigionY = 162 - 44+1;
    CGFloat kWeatherOriY = [TIoTUIProxy shareUIProxy].navigationBarHeight + weatherHeight + 150/2 -12;
    CGFloat kWeatherOriX = kScreenWidth - 150/2 + 5;
    
    if (offSetY <=0) {
        [self.view insertSubview:self.tableHeaderView aboveSubview:self.devicesTableView];
        self.tableHeaderView.center = CGPointMake(kScreenWidth/2, kOrigionY -offSetY + kOrigionY);
        [self.view insertSubview:self.slideTitleBackView aboveSubview:self.devicesTableView];
        
        if (![TIoTUIProxy shareUIProxy].iPhoneX) {
            self.slideTitleBackView.center = CGPointMake(self.tableHeaderView.center.x, self.tableHeaderView.center.y - 24);
            self.tableHeaderView.center = self.slideTitleBackView.center;
        }else {
            self.slideTitleBackView.center = self.tableHeaderView.center;
        }
        [self.weatherBackImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.slideTitleBackView.mas_right).offset(-7);
        }];
        
        CGPoint weatherCenter = CGPointMake(kWeatherOriX, kWeatherOriY - offSetY);
        CGFloat alphaValue = 1;
        
        [self controlWeatherViewWithCenter:weatherCenter alpha:alphaValue];
        
    }else if (offSetY > 0 && offSetY <= kOrigionY) {
        [self.view insertSubview:self.tableHeaderView aboveSubview:self.devicesTableView];
        self.tableHeaderView.center = CGPointMake(kScreenWidth/2, kOrigionY - offSetY + kOrigionY);
        
        [self.view insertSubview:self.slideTitleBackView aboveSubview:self.devicesTableView];
        if (![TIoTUIProxy shareUIProxy].iPhoneX) {
            self.slideTitleBackView.center = CGPointMake(self.tableHeaderView.center.x, self.tableHeaderView.center.y - 24);
            self.tableHeaderView.center = self.slideTitleBackView.center;
        }else {
            self.slideTitleBackView.center = self.tableHeaderView.center;
        }
        [self.weatherBackImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.slideTitleBackView.mas_right).offset(-7);
        }];
        
        CGPoint weatherCenter = CGPointMake(kWeatherOriX, kWeatherOriY - offSetY - 3);
        CGFloat alphaValue = (kOrigionY - offSetY)/kOrigionY;
        
        [self controlWeatherViewWithCenter:weatherCenter alpha:alphaValue];
        
        if (![NSString isNullOrNilWithObject:self.weatherTemp]) {
            self.weatherScrollOffsetY = self.weatherAnimationView.center.y;
        }
        
    }else if (offSetY > kOrigionY) {
        self.tableHeaderView.center = CGPointMake(kScreenWidth/2, kOrigionY);
        
        if (![TIoTUIProxy shareUIProxy].iPhoneX) {
            self.slideTitleBackView.center = CGPointMake(self.tableHeaderView.center.x, self.tableHeaderView.center.y-24);
            self.tableHeaderView.center = self.slideTitleBackView.center;
        }else {
            self.slideTitleBackView.center = self.tableHeaderView.center;
        }
        [self.weatherBackImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.slideTitleBackView.mas_right);
        }];
        self.weatherBottomBtn.enabled = YES;
        self.weatherAnimationView.hidden = YES;
        
    }
}

- (void)controlWeatherViewWithCenter:(CGPoint)center alpha:(CGFloat)alphaValue {
    if (![NSString isNullOrNilWithObject:self.weatherTemp]) {
        self.weatherBottomBtn.enabled = NO;
        self.weatherAnimationView.hidden = NO;
        self.weatherAnimationView.center = center;
        self.weatherAnimationView.alpha = alphaValue;
    }else {
        self.weatherBottomBtn.enabled = YES;
        self.weatherAnimationView.hidden = YES;
    }
}

#pragma mark - PageTitle delegate

- (void)cm_pageTitleContentViewClickWithLastIndex:(NSUInteger)LastIndex Index:(NSUInteger)index Repeat:(BOOL)repeat
{
    self.tableHeaderView.cm_selectedIndex = index;
    
    if (index == 0) {
        self.currentRoomId = nil;
        [self loadNewData];
    }
    else
    {
        RoomModel *model = self.rooms[index - 1];
        self.currentRoomId = model.RoomId;
        [TIoTCoreUserManage shared].currentRoomId = model.RoomId;
        [self loadNewData];
    }
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - setter or getter

- (UITableView *)devicesTableView {
    if (!_devicesTableView) {
        _devicesTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _devicesTableView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
        _devicesTableView.rowHeight = 130;
        _devicesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _devicesTableView.delegate = self;
        _devicesTableView.dataSource = self;
    }
    return _devicesTableView;
}

- (UIView *)navView
{
    if (!_navView) {
        _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, [TIoTUIProxy shareUIProxy].navigationBarHeight + weatherHeight)];
        _navView.backgroundColor = [UIColor whiteColor];
        _navView.clipsToBounds = YES;
        UIImageView *backImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"banner_header"]];
        [_navView addSubview:backImage];
        [backImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(_navView);
            make.height.mas_equalTo([TIoTUIProxy shareUIProxy].navigationBarHeight + weatherHeight + 162);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setLabelFormateTitle:NSLocalizedString(@"lialian_name", @"腾讯连连") font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
        [_navView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
            make.centerX.equalTo(_navView);
            make.top.mas_equalTo([TIoTUIProxy shareUIProxy].statusHeight);
        }];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.text = NSLocalizedString(@"my_family", @"我的家");
        titleLab.textColor = [UIColor whiteColor];
        titleLab.font = [UIFont wcPfRegularFontOfSize:16];
        [_navView addSubview:titleLab];
        self.nick = titleLab;
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.height.mas_equalTo(44);
            make.width.lessThanOrEqualTo(@80);
            make.top.mas_equalTo([TIoTUIProxy shareUIProxy].statusHeight);
        }];
        
        UIImageView *imgv = [[UIImageView alloc] init];
        imgv.image = [[UIImage imageNamed:@"down_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imgv.tintColor = [UIColor whiteColor];
        [_navView addSubview:imgv];
        [imgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(titleLab.mas_trailing);
            make.centerY.equalTo(titleLab);
            make.trailing.lessThanOrEqualTo(titleLabel.mas_leading).offset(-20);
            make.width.height.mas_equalTo(18);
        }];
        
        UIButton *cover = [UIButton buttonWithType:UIButtonTypeCustom];
        [cover addTarget:self action:@selector(selectFamily:) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:cover];
        [cover mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(titleLab.mas_leading);
            make.trailing.equalTo(imgv.mas_leading);
            make.top.equalTo(titleLab.mas_top);
            make.bottom.equalTo(titleLab.mas_bottom);
        }];
        
        self.addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setImage:[UIImage imageNamed:@"homeAdd"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIView *weatherView = [[UIView alloc] init];
        [_navView addSubview:weatherView];
        [weatherView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLab.mas_bottom);
            make.leading.trailing.mas_equalTo(0);
            make.height.mas_equalTo(weatherHeight);
        }];
        
    }
    return _navView;
}

- (NSString *)weatherLocation {
    if (!_weatherLocation) {
        _weatherLocation = @"";
    }
    return _weatherLocation;
}

- (NSString *)weatherText {
    if (!_weatherText) {
        _weatherText = @"";
    }
    return _weatherText;
}

- (NSString *)weatherHumidity {
    if (!_weatherHumidity) {
        _weatherHumidity = @"";
    }
    return _weatherHumidity;
}

- (NSString *)weatherWindDir {
    if (!_weatherWindDir) {
        _weatherWindDir = @"";
    }
    return _weatherWindDir;
}

- (NSString *)weatherTemp {
    if (!_weatherTemp) {
        _weatherTemp = @"";
    }
    return _weatherTemp;
}

- (NSString *)weatherTypeText {
    if (!_weatherTypeText) {
        _weatherTypeText = @"";
    }
    return _weatherTypeText;
}

- (NSMutableArray *)devicesArray {
    if (!_devicesArray) {
        _devicesArray = [NSMutableArray array];
    }
    return _devicesArray;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSMutableArray *)shareDataArr
{
    if (!_shareDataArr) {
        _shareDataArr = [NSMutableArray array];
    }
    return _shareDataArr;
}

- (NSMutableDictionary *)allRoomDeviceInfo
{
    if (!_allRoomDeviceInfo) {
        _allRoomDeviceInfo = [NSMutableDictionary dictionary];
    }
    return _allRoomDeviceInfo;
}

- (dispatch_semaphore_t)sem
{
    if (!_sem) {
        _sem = dispatch_semaphore_create(0);
    }
    return _sem;
}


- (NSMutableArray *)deviceConfigArray {
    if (!_deviceConfigArray) {
        _deviceConfigArray = [NSMutableArray new];
    }
    return _deviceConfigArray;
}

- (NSMutableArray *)shareDevicesArray {
    if (!_shareDevicesArray) {
        _shareDevicesArray = [NSMutableArray new];
    }
    return _shareDevicesArray;
}

- (NSMutableArray *)shareDeviceConfigArray {
    if (!_shareDeviceConfigArray) {
        _shareDeviceConfigArray = [NSMutableArray new];
    }
    return _shareDeviceConfigArray;
}
@end
