//
//  TIoTDemoNVRSubDeviceVC.m
//  LinkSDKDemo
//

#import "TIoTDemoNVRSubDeviceVC.h"
#import "UIImage+TIoTDemoExtension.h"
#import "TIoTDemoVideoDeviceCell.h"
#import "TIoTDemoDeviceHeaderView.h"
#import "TIoTDemoCustomSheetView.h"
#import <YYModel.h>
#import "TIoTCoreXP2PBridge.h"
#import "TIoTDemoSameScreenVC.h"
#import "TIoTDemoPreviewDeviceVC.h"
#import "TIoTCoreAppEnvironment.h"
#import "UIImage+TIoTDemoExtension.h"
#import "TIoTCoreUtil.h"
#import "NSString+Extension.h"
#import "TIoTXp2pInfoModel.h"

static NSInteger const maxLimitDeviceNumber = 4;
static NSString *const kNVRSubdeviceListCellID = @"kNVRSubdeviceListCellID";
static NSString *const kNVRSubdeviceListHeaderID = @"kNVRSubdeviceListHeaderID";
static NSString *const action_NVRSubdeviceList = @"action=inner_define&cmd=get_nvr_list";

@interface TIoTDemoNVRSubDeviceVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TIoTDemoDeviceHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isShowSameScreenChoiceIcon;
@property (nonatomic, strong) NSMutableArray *selectedArray;

@property (nonatomic, assign) CFTimeInterval startP2P;
@property (nonatomic, assign) CFTimeInterval endP2P;
@end

@implementation TIoTDemoNVRSubDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavBarStyleWithNormal:NO];
    [self setupUIViews];
    [self addRefreshControl];
    [self requestNVRSubdeviceList];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavBarStyleWithNormal:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setupNavBarStyleWithNormal:YES];
}

- (void)setupNavBarStyleWithNormal:(BOOL)isNormal {
    
    if (isNormal) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage getGradientImageWithColors:@[[UIColor colorWithHexString:@"#ffffff"],[UIColor colorWithHexString:@"#ffffff"]] imgSize:CGSizeMake(kScreenWidth, 44)] forBarMetrics:UIBarMetricsDefault];
    }else {
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#FFFFFF"],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:17]}];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage getGradientImageWithColors:@[[UIColor colorWithHexString:@"#3D8BFF"],[UIColor colorWithHexString:@"#1242FF"]] imgSize:CGSizeMake(kScreenWidth, 44)] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
}

- (void)dealloc {
    [self stopSrviceRemoveObserver];
}

- (void)nav_customBack {
    [self stopSrviceRemoveObserver];
    [self.navigationController popViewControllerAnimated:YES];
}

///MARK: 结束连接
- (void)stopSrviceRemoveObserver {
    [[TIoTCoreXP2PBridge sharedInstance] stopService:self.selectedModel.DeviceName?:@""];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"xp2preconnect" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"xp2disconnect" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

///MARK: 开启连接
- (void)startP2PConnect {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseP2PConnect:)
                                                 name:@"xp2preconnect"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseP2PdisConnect:)
                                                 name:@"xp2disconnect"
                                               object:nil];
    

//    TIoTCoreAppEnvironment *env = [TIoTCoreAppEnvironment shareEnvironment];
//    [[TIoTCoreXP2PBridge sharedInstance] startAppWith:env.cloudProductId dev_name:self.selectedModel.DeviceName?:@""];
//    [[TIoTCoreXP2PBridge sharedInstance] setXp2pInfo:self.selectedModel.DeviceName?:@"" sec_id:env.cloudSecretId sec_key:env.cloudSecretKey xp2pinfo:@""];
    [self requestXp2pInfoWithDeviceName:self.selectedModel.DeviceName?:@"" isReconnection:NO];
    
    CFTimeInterval startP2PTime = CACurrentMediaTime();
    self.startP2P = startP2PTime;
    
}

- (void)responseP2PdisConnect:(NSNotification *)notify {
    NSString *DeviceName = [notify.userInfo objectForKey:@"id"];
    if (![DeviceName isEqualToString:self.selectedModel.DeviceName?:@""]) {
        return;
    }
    
    [[TIoTCoreXP2PBridge sharedInstance] stopService: DeviceName];
    
//    TIoTCoreAppEnvironment *env = [TIoTCoreAppEnvironment shareEnvironment];
//    [[TIoTCoreXP2PBridge sharedInstance] startAppWith:env.cloudProductId dev_name:DeviceName?:@""];
//    [[TIoTCoreXP2PBridge sharedInstance] setXp2pInfo:DeviceName?:@"" sec_id:env.cloudSecretId sec_key:env.cloudSecretKey xp2pinfo:@""];
    
    [self requestXp2pInfoWithDeviceName:DeviceName?:@"" isReconnection:YES];
}

- (void)responseP2PConnect:(NSNotification *)notify {
    NSString *DeviceName = [notify.userInfo objectForKey:@"id"];
    if (![DeviceName isEqualToString:self.selectedModel.DeviceName?:@""]) {
        return;
    }
    
    [MBProgressHUD show:[NSString stringWithFormat:@"%@ 通道建立成功",DeviceName] icon:@"" view:self.view];
    
    //计算打洞时间
    CFTimeInterval endP2PTime = CACurrentMediaTime();
    self.endP2P = endP2PTime;
    [self saveDeviceInfo:self.selectedModel.DeviceName?:@"" time:(self.endP2P - self.startP2P)*1000];
    
    DDLogInfo(@"%@", [NSString stringWithFormat:@"****** %@ ended: %f millisecond start: %f interval: %ld ******\n",NSStringFromSelector(_cmd),self.endP2P,self.startP2P,(long)((self.endP2P - self.startP2P)*1000)]);
    
        [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:self.selectedModel.DeviceName?:@"" cmd:action_NVRSubdeviceList timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
            
            NSArray<TIoTExploreOrVideoDeviceModel *> *subdeviceList = [NSArray yy_modelArrayWithClass:TIoTExploreOrVideoDeviceModel.class json:jsonList];
            [self.dataArray removeAllObjects];
            self.dataArray = [NSMutableArray arrayWithArray:subdeviceList];
            [self.collectionView reloadData];
            [self.collectionView.refreshControl endRefreshing];
            
        }];
}

///MARK: NVR设备保存打洞时间
- (void)saveDeviceInfo:(NSString *)deviceName time:(NSInteger)time {
    if (![NSString isNullOrNilWithObject:deviceName]) {
        [[NSUserDefaults standardUserDefaults] setValue:@{@"p2pConnectTime":@(time)} forKey:deviceName];
    }
}

- (void)requestXp2pInfoWithDeviceName:(NSString *)deviceName isReconnection:(BOOL)isReconnection {
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]init];
    paramDic[@"ProductId"] = [TIoTCoreAppEnvironment shareEnvironment].cloudProductId?:@"";
    paramDic[@"Version"] = @"2021-11-25";//@"2020-12-15";
    paramDic[@"DeviceName"] = deviceName?:@"";
    
    [[TIoTCoreDeviceSet shared] requestVideoOrExploreDataWithParam:paramDic action:DescribeDeviceData vidowOrExploreHost:TIotApiHostVideo success:^(id  _Nonnull responseObject) {
        TIoTXp2pInfoModel *model = [TIoTXp2pInfoModel yy_modelWithJSON:responseObject];
        NSDictionary *p2pInfo = [NSString jsonToObject:model.Data?:@""];
        TIoTXp2pModel *infoModel = [TIoTXp2pModel yy_modelWithJSON:p2pInfo];
        NSString *xp2pInfoString = infoModel._sys_xp2p_info.Value?:@"";
        
        [self resconnectXp2pWithDevicename:deviceName xp2pInfo:xp2pInfoString];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        [self resconnectXp2pWithDevicename:deviceName xp2pInfo:@""];
        if (isReconnection) {
            [MBProgressHUD showError:@"p2p重连 xp2pInfo api请求失败"];
        }else {
            [MBProgressHUD showError:@"xp2pInfo api请求失败"];
        }
        
    }];
}

- (void)resconnectXp2pWithDevicename:(NSString *)deviceName xp2pInfo:(NSString *)xp2pInfoString {
    TIoTCoreAppEnvironment *env = [TIoTCoreAppEnvironment shareEnvironment];
    
    TIoTP2PAPPConfig *config = [TIoTP2PAPPConfig new];
    config.appkey = env.appKey;         //为explorer平台注册的应用信息(https://console.cloud.tencent.com/iotexplorer/v2/instance/app/detai) explorer控制台- 应用开发 - 选对应的应用下的 appkey/appsecret
    config.appsecret = env.appSecret;   //为explorer平台注册的应用信息(https://console.cloud.tencent.com/iotexplorer/v2/instance/app/detai) explorer控制台- 应用开发 - 选对应的应用下的 appkey/appsecret
    config.userid = [[TIoTCoreXP2PBridge sharedInstance] getAppUUID];
    
    config.autoConfigFromDevice = NO;
    config.type = XP2P_PROTOCOL_AUTO;
    config.crossStunTurn = NO;
    
    int errorcode = [[TIoTCoreXP2PBridge sharedInstance] startAppWith:env.cloudProductId dev_name:deviceName?:@"" appconfig:config];
    [[TIoTCoreXP2PBridge sharedInstance] setXp2pInfo:deviceName?:@"" xp2pinfo:xp2pInfoString?:@""];
}

- (void)setupUIViews {
    
    self.isShowSameScreenChoiceIcon = NO;
    
    self.view.backgroundColor = [UIColor colorWithHexString:KActionSheetBackgroundColor];
    
    self.title = self.selectedModel.DeviceName;
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view).offset(64);
        }
        make.left.right.bottom.equalTo(self.view);
    }];
    
}

- (void)addRefreshControl {
    if (@available(iOS 10.0,*)) {
        
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor colorWithHexString:kVideoDemoTextContentColor];
        refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新" attributes:@{NSFontAttributeName:[UIFont wcPfRegularFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithHexString:kVideoDemoMainThemeColor]}];
        [refreshControl addTarget:self action:@selector(refreshNVRSubdeviceList:) forControlEvents:UIControlEventValueChanged];
        self.collectionView.refreshControl = refreshControl;
    }
}

- (void)refreshNVRSubdeviceList:(UIRefreshControl *)sender {
    [self requestNVRSubdeviceList];
}

#pragma mark - 请求设备列表
- (void)requestNVRSubdeviceList {
    [self stopSrviceRemoveObserver];
    [self startP2PConnect];
    
    [self.headerView exitEditPattern];
    [self resetDeviceListStatus];
    
}

#pragma mark - UICollectionViewDataSource And UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TIoTDemoVideoDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNVRSubdeviceListCellID forIndexPath:indexPath];
    
    TIoTExploreOrVideoDeviceModel *model = self.dataArray[indexPath.row];
    
    cell.isShowChoiceDeviceIcon = self.isShowSameScreenChoiceIcon;
    __weak typeof(self) weakSelf = self;
    
    cell.chooseDeviceBlock = ^(UIButton * _Nonnull itemBtn) {
        
        if (weakSelf.selectedArray.count <= maxLimitDeviceNumber - 1) {
            if ([itemBtn.currentImage isEqual:[UIImage imageNamed:@"device_unselect"]]) {
                model.isSelected = @"1";
                [weakSelf.selectedArray addObject:model];
                [itemBtn setImage:[UIImage imageNamed:@"device_select"] forState:UIControlStateNormal];
            }else if ([itemBtn.currentImage isEqual:[UIImage imageNamed:@"device_select"]]) {
                model.isSelected = @"0";
                [weakSelf.selectedArray removeObject:model];
                [itemBtn setImage:[UIImage imageNamed:@"device_unselect"] forState:UIControlStateNormal];
            }
            [weakSelf.headerView setChoosedDeviceNumber:weakSelf.selectedArray];
            itemBtn.selected = !itemBtn.selected;
        }else {
            if ([itemBtn.currentImage isEqual:[UIImage imageNamed:@"device_unselect"]]) {
                [MBProgressHUD showMessage:[NSString stringWithFormat:@"最多选择%ld台摄像机",(long)maxLimitDeviceNumber] icon:@"overstep_device"];
            }else if ([itemBtn.currentImage isEqual:[UIImage imageNamed:@"device_select"]]) {
                model.isSelected = @"0";
                [weakSelf.selectedArray removeObject:model];
                [itemBtn setImage:[UIImage imageNamed:@"device_unselect"] forState:UIControlStateNormal];
                itemBtn.selected = !itemBtn.selected;
                [weakSelf.headerView setChoosedDeviceNumber:weakSelf.selectedArray];
            }
        }
    };
    cell.model = model;
    
    TIoTDemoCustomSheetView *customActionSheet = [[TIoTDemoCustomSheetView alloc]init];
    cell.moreActionBlock = ^{
        NSArray *actionTitleArray = @[@"预览",@"取消"];
        
        ChooseFunctionBlock previewVideoBlock = ^(TIoTDemoCustomSheetView *view){
            DDLogVerbose(@"预览");
            
            TIoTExploreOrVideoDeviceModel *model = self.dataArray[indexPath.row];
            TIoTDemoPreviewDeviceVC *previewDeviceVC = [[TIoTDemoPreviewDeviceVC alloc]init];
            previewDeviceVC.selectedModel = model;
            previewDeviceVC.isNVR = YES;
            previewDeviceVC.deviceNameNVR = self.selectedModel.DeviceName;
            [weakSelf.navigationController pushViewController:previewDeviceVC animated:YES];
            [weakSelf resetDeviceListStatus];
            [customActionSheet removeFromSuperview];
        };
        
        ChooseFunctionBlock cancelBlock = ^(TIoTDemoCustomSheetView *view) {
            DDLogVerbose(@"取消");
            [view removeFromSuperview];
        };
        NSArray *actionBlockArray = @[previewVideoBlock,cancelBlock];
        
        
        [customActionSheet sheetViewTopTitleArray:actionTitleArray withMatchBlocks:actionBlockArray];
        [[UIApplication sharedApplication].delegate.window addSubview:customActionSheet];
        [customActionSheet mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
        }];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //预览页
    TIoTExploreOrVideoDeviceModel *model = self.dataArray[indexPath.row];
    TIoTDemoPreviewDeviceVC *previewDeviceVC = [[TIoTDemoPreviewDeviceVC alloc]init];
    previewDeviceVC.selectedModel = model;
    previewDeviceVC.isNVR = YES;
    previewDeviceVC.deviceNameNVR = self.selectedModel.DeviceName;
    [self.navigationController pushViewController:previewDeviceVC animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat kHeight = 44;
    if (self.dataArray.count == 0) {
        kHeight = 0;
    }
    return CGSizeMake(kScreenWidth, kHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kNVRSubdeviceListHeaderID forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;

    //编辑操作
    weakSelf.headerView.editBlock = ^(TIoTDemoDeviceHeaderView *headerView,BOOL isEditPartten){

        if (isEditPartten) {
            TIoTDemoCustomSheetView *editSheet = [[TIoTDemoCustomSheetView alloc]init];

            NSArray *actionTitleArray = @[@"编辑同屏摄像机",@"取消"];
            //选择同频摄像机
            ChooseFunctionBlock editSameScreen = ^(TIoTDemoCustomSheetView *view) {

                weakSelf.isShowSameScreenChoiceIcon = YES;

                [collectionView reloadData];

                [headerView enterEditPattern];
                [editSheet removeFromSuperview];
            };
            //取消
            ChooseFunctionBlock cancelBlock = ^(TIoTDemoCustomSheetView *view) {
                [headerView exitEditPattern];
                [view removeFromSuperview];
            };

            NSArray *actionBlockArray = @[editSameScreen,cancelBlock];

            [editSheet sheetViewTopTitleArray:actionTitleArray withMatchBlocks:actionBlockArray];
            [[UIApplication sharedApplication].delegate.window addSubview:editSheet];
            [editSheet mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
            }];
        }else {
            if (self.selectedArray.count != 0) {
                TIoTDemoSameScreenVC *sameScreenVC = [[TIoTDemoSameScreenVC alloc]init];
                sameScreenVC.isNVRType = YES;
                sameScreenVC.NVRDeviceName = self.selectedModel.DeviceName;
                [sameScreenVC setupSameScreenArray:self.selectedArray];
                [weakSelf.navigationController pushViewController:sameScreenVC animated:YES];
                [weakSelf resetDeviceListStatus];
            }else {
                [weakSelf resetDeviceListStatus];
            }
        }

    };

    //取消操作
    weakSelf.headerView.cancelEditBlock = ^{
        [weakSelf resetDeviceListStatus];
    };
    
    return weakSelf.headerView;
    
}

#pragma mark - event

- (void)resetDeviceListStatus {
    self.isShowSameScreenChoiceIcon = NO;
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TIoTExploreOrVideoDeviceModel *model = obj;
        model.isSelected = @"0";
    }];
    if (self.selectedArray.count != 0) {
        [self.selectedArray removeAllObjects];
    }
    [self.collectionView reloadData];
}

#pragma mark - Lazy loading
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat scale = 138.0/165.0;
        CGFloat itemWidth = (kScreenWidth - 16*2 - 13)/2;
        CGFloat itemHeight = itemWidth*scale;
        CGFloat padding = 16;
//        flowLayout.sectionHeadersPinToVisibleBounds = YES;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(4, padding, 4, padding);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
        [_collectionView registerClass:[TIoTDemoVideoDeviceCell class] forCellWithReuseIdentifier:kNVRSubdeviceListCellID];
        [_collectionView registerClass:[TIoTDemoDeviceHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kNVRSubdeviceListHeaderID];
    }
    return _collectionView;
}

- (NSMutableArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = [[NSMutableArray alloc]init];
    }
    return _selectedArray;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
