//
//  WCHomeViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/16.
//  Copyright © 2019 Winext. All rights reserved.
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

static CGFloat weatherHeight = 60;

@interface TIoTHomeViewController ()<UITableViewDelegate,UITableViewDataSource,CMPageTitleContentViewDelegate,UIPopoverPresentationControllerDelegate>


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CMPageTitleContentView *tableHeaderView;
@property (nonatomic, strong) CMPageTitleContentView *tableHeaderView2;


@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UILabel *nick;
@property (nonatomic, strong) UILabel *weatherLab;
@property (nonatomic, strong) UIButton *addBtn;

@property (nonatomic, strong) UIView *navView2;
@property (nonatomic, strong) UILabel *nick2;
@property (nonatomic, strong) UILabel *weatherLab2;
@property (nonatomic, strong) UIButton *addBtn2;

@property (nonatomic, strong) UIView *navView3;


@property (nonatomic,strong) NSArray *families;
@property (nonatomic,strong) NSArray *rooms;
@property (nonatomic,copy)  NSString *currentFamilyId;
@property (nonatomic,copy)  NSNumber *currentFamilyRole;
@property (nonatomic,copy)  NSString *currentRoomId;


@property (nonatomic, strong) NSMutableDictionary *allRoomDeviceInfo;
@property (nonatomic, assign) NSInteger offset;//设备数据偏移量
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, copy) NSArray *deviceIds;

@property (nonatomic) dispatch_semaphore_t sem;

@end

@implementation TIoTHomeViewController
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark lifeCircle

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
    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{
        [selfWeak getFamilyList];
    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [selfWeak loadMoreData];
    }];
    
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)endRefresh:(BOOL)isFooter total:(NSInteger)total {
    self.offset += 10;
    if (isFooter) {
        if (self.offset >= total) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [self.tableView.mj_footer endRefreshing];
        }
    }
    else{
        [self.tableView.mj_header endRefreshing];
        if (self.offset >= total) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
    }
}

- (void)refreshUI{
    
    if (self.dataArr.count == 0) {//[data[@"Total"] integerValue] == 0) {
        
        [MBProgressHUD dismissInView:self.view];
        WeakObj(self)
        if (!self.currentRoomId || self.currentRoomId.length == 0) {
            [self.tableView showEmpty2:@"" desc:@"还没有设备，点击添加" image:[UIImage imageNamed:@"home_no_device"] block:^{
                [selfWeak addEquipmentViewController];
            }];
            
            self.addBtn.hidden = YES;
            self.addBtn2.hidden = YES;
            
            
            //房间列表隐藏
            self.tableHeaderView.alpha = 0;
            self.tableHeaderView2.alpha = 0;
        } else {
            [self.tableView showEmpty2:@"" desc:@"还没有设备，点击添加" image:[UIImage imageNamed:@"home_no_device"] block:^{
                [selfWeak addEquipmentViewController];
            }];
        }
        
        [self.tableView reloadData];
    }
    else{
        
        self.addBtn.hidden = NO;
        self.addBtn2.hidden = NO;
        
        
        //房间列表显示
        [self addTableHeaderView];
        self.tableHeaderView.alpha = 1;
        self.tableHeaderView2.alpha = 1;
        
        [self.tableView hideStatus];
        [self.tableView reloadData];
    }
}

- (void)setupUI{
    self.fd_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = self.view.bounds;
    gl.startPoint = CGPointMake(0.5, 0);
    gl.endPoint = CGPointMake(0.5, 1);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0),@(1.0f)];
    [self.view.layer addSublayer:gl];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.right.bottom.mas_equalTo(0);
    }];
    
    [self setNav];
    
}

- (void)addTableHeaderView {
    
    NSMutableArray *roomNames = [NSMutableArray array];
    [roomNames addObject:@"全部设备"];
    [roomNames addObjectsFromArray:[self.rooms valueForKey:@"RoomName"]];
    
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
    config.cm_switchMode = CMPageTitleSwitchMode_Scale;
    config.cm_titles = roomNames;
    config.cm_font = [UIFont systemFontOfSize:16];
    config.cm_selectedFont = [UIFont boldSystemFontOfSize:17];
    config.cm_normalColor = kFontColor;
    config.cm_selectedColor = kRGBColor(0, 82, 217);
    
    
    self.tableHeaderView = [[CMPageTitleContentView alloc] initWithConfig:config];
    _tableHeaderView.backgroundColor = [UIColor clearColor];
    _tableHeaderView.frame = CGRectMake(0, 0, kScreenWidth, 44);
    _tableHeaderView.cm_delegate = self;
    _tableHeaderView.cm_selectedIndex = index;
    self.tableView.tableHeaderView = _tableHeaderView;
    
    [self.view addSubview:self.navView3];
    CMPageTitleConfig *config2 = [CMPageTitleConfig defaultConfig];
    config2.cm_switchMode = CMPageTitleSwitchMode_Scale;
    config2.cm_titles = roomNames;
    config2.cm_font = [UIFont systemFontOfSize:16];
    config2.cm_selectedFont = [UIFont boldSystemFontOfSize:17];
    config2.cm_normalColor = kFontColor;
    config2.cm_selectedColor = kRGBColor(0, 82, 217);
    
    self.tableHeaderView2 = [[CMPageTitleContentView alloc] initWithConfig:config2];
    _tableHeaderView2.frame = CGRectMake(0, [TIoTUIProxy shareUIProxy].statusHeight, kScreenWidth, 44);
    _tableHeaderView2.cm_selectedIndex = index;
    _tableHeaderView2.cm_delegate = self;
    [_navView3 addSubview:_tableHeaderView2];
    
}

- (void)setNav{
    //最下层固定
    [self.view addSubview:self.navView];
    
    //滑动层显示的导航栏
    [self.tableView addSubview:self.navView2];
}

- (NSAttributedString *)handleWeather{
    
    NSAttributedString *valueStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",@"28"] attributes:@{NSFontAttributeName : [UIFont wcPfRegularFontOfSize:16],NSForegroundColorAttributeName : kRGBColor(51, 51, 51)}];
    
    NSAttributedString *unitStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",@" ℃"] attributes:@{NSFontAttributeName : [UIFont wcPfRegularFontOfSize:16],NSForegroundColorAttributeName : kRGBColor(51, 51, 51)}];
    
    NSAttributedString *weatherStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",@"   深圳 | 多云转小雨"] attributes:@{NSFontAttributeName : [UIFont wcPfRegularFontOfSize:16],NSForegroundColorAttributeName : kRGBColor(51, 51, 51)}];
        
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:valueStr];
    [str appendAttributedString:unitStr];
    [str appendAttributedString:weatherStr];
    return str;
}

- (void)socketConnected
{
//    dispatch_semaphore_signal(self.sem);
}


/// 通过MGJRouter 注册帮助反馈控制器，以便点击通知后跳转
- (void)registFeedBackRouterController {
        
    [MGJRouter registerURLPattern:@"TIoT://TPNSPushManage/feedback" toHandler:^(NSDictionary *routerParameters) {
        //传入推送的全部信息，在控制器内部取出URL，进行展示
        NSString *url = routerParameters[MGJRouterParameterUserInfo][@"customMessageContent"][@"url"]?:@"";
        if (url.length) {
            TIoTWebVC *vc = [[TIoTWebVC alloc] init];
            vc.title = @"反馈详情";
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
        [mString insertString:[NSString stringWithFormat:@"appID=%@", bundleId] atIndex:range.location+1];
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
            
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)getRoomList:(NSString *)familyId
{
    [[TIoTRequestObject shared] post:AppGetRoomList Param:@{@"FamilyId":familyId} success:^(id responseObject) {
        self.rooms = [NSArray yy_modelArrayWithClass:[RoomModel class] json:responseObject[@"RoomList"]];
        
        [self loadNewData];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)loadNewData{
    self.offset = 0;
    NSString *roomId = self.currentRoomId ?: @"";
    [[TIoTRequestObject shared] post:AppGetFamilyDeviceList Param:@{@"FamilyId":self.currentFamilyId,@"RoomId":roomId,@"Offset":@(self.offset),@"Limit":@(10)} success:^(id responseObject) {
        [self endRefresh:NO total:[responseObject[@"Total"] integerValue]];
        [self.dataArr removeAllObjects];
        [self.dataArr addObjectsFromArray:responseObject[@"DeviceList"]];
        if (self.dataArr.count == 0) {
            [self refreshUI];
        }
        
        [self updateDeviceStatus];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)loadMoreData{
    
    NSString *roomId = self.currentRoomId ?: @"";
    [[TIoTRequestObject shared] post:AppGetFamilyDeviceList Param:@{@"FamilyId":self.currentFamilyId,@"RoomId":roomId,@"Offset":@(self.offset),@"Limit":@(10)} success:^(id responseObject) {
        [self endRefresh:YES total:[responseObject[@"Total"] integerValue]];
        [self.dataArr addObjectsFromArray:responseObject[@"DeviceList"]];
        if (self.dataArr.count == 0) {
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
                        
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic addEntriesFromDictionary:tmpDic];
                        [dic setValue:statusDic[@"Online"] forKey:@"Online"];
                        
                        [tmpArr addObject:dic];
                    }
                }
                
                
            }
            
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:tmpArr];
            [self refreshUI];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    }
}

- (void)createFamily
{
    NSDictionary *param = @{@"Name":@"我的家",@"Address":@""};
    [[TIoTRequestObject shared] post:AppCreateFamily Param:param success:^(id responseObject) {
        [self getFamilyList];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

#pragma mark - event

///切换家庭
- (void)chooseFamilyByIndex:(NSInteger)index
{
    
    FamilyModel *model = self.families[index];
    [TIoTCoreUserManage shared].familyId = model.FamilyId;
    self.nick.text = model.FamilyName;
    self.nick2.text = model.FamilyName;
    self.currentFamilyId = model.FamilyId;
    self.currentFamilyRole = model.Role;
    
    [self getRoomList:model.FamilyId];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TIoTEquipmentTableViewCell *cell = [TIoTEquipmentTableViewCell cellWithTableView:tableView];
    cell.dataDic = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *devIds = @[self.dataArr[indexPath.row][@"DeviceId"]];
//    if ([WCWebSocketManage shared].socketReadyState == SR_OPEN) {
        [HXYNotice postHeartBeat:devIds];
        [HXYNotice addActivePushPost:devIds];
        
        TIoTPanelVC *vc = [[TIoTPanelVC alloc] init];
        vc.title = [NSString stringWithFormat:@"%@",self.dataArr[indexPath.row][@"AliasName"]];
        vc.productId = self.dataArr[indexPath.row][@"ProductId"];
        vc.deviceName = [NSString stringWithFormat:@"%@",self.dataArr[indexPath.row][@"DeviceName"]];
        vc.deviceDic = [self.dataArr[indexPath.row] mutableCopy];
        vc.isOwner = [self.currentFamilyRole integerValue] == 1;
        [self.navigationController pushViewController:vc animated:YES];
        
//    }
//    else
//    {
//        [MBProgressHUD showError:@"请检查网络"];
//    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offSetY = scrollView.contentOffset.y;
    NSLog(@"天地的==%f",offSetY);
    CGFloat limit = 44 + weatherHeight;
    if (offSetY <= -(limit + [TIoTUIProxy shareUIProxy].statusHeight)) {
        self.navView2.hidden = YES;
        self.navView.hidden = NO;
    }
    else if (offSetY > -(limit + [TIoTUIProxy shareUIProxy].statusHeight))
    {
        self.navView2.hidden = NO;
        self.navView.hidden = YES;
        if (offSetY > -[TIoTUIProxy shareUIProxy].statusHeight) {
            self.tableHeaderView.hidden = YES;
            self.navView3.hidden = NO;
        }
        else
        {
            self.tableHeaderView.hidden = NO;
            self.navView3.hidden = YES;
        }
    }
}

#pragma mark - delegate

- (void)cm_pageTitleContentViewClickWithLastIndex:(NSUInteger)LastIndex Index:(NSUInteger)index Repeat:(BOOL)repeat
{
    self.tableHeaderView.cm_selectedIndex = index;
    self.tableHeaderView2.cm_selectedIndex = index;
    
    if (index == 0) {
        self.currentRoomId = nil;
        [self loadNewData];
    }
    else
    {
        RoomModel *model = self.rooms[index - 1];
        self.currentRoomId = model.RoomId;
        [self loadNewData];
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 100;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        self.tableView.contentInset = UIEdgeInsetsMake(44 + weatherHeight, 0, 0, 0);
    }
    
    return _tableView;
}

- (UIView *)navView
{
    if (!_navView) {
        _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, [TIoTUIProxy shareUIProxy].navigationBarHeight + weatherHeight)];
//        _navView.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.text = @"我的家";
        titleLab.textColor = [UIColor blackColor];
        titleLab.font = [UIFont boldSystemFontOfSize:24];
        [_navView addSubview:titleLab];
        self.nick = titleLab;
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.height.mas_equalTo(44);
            make.top.mas_equalTo([TIoTUIProxy shareUIProxy].statusHeight);
        }];
        
        UIImageView *imgv = [[UIImageView alloc] init];
        imgv.image = [UIImage imageNamed:@"downArrow"];
        [_navView addSubview:imgv];
        [imgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(titleLab.mas_trailing).offset(10);
            make.centerY.equalTo(titleLab);
            make.trailing.lessThanOrEqualTo(_navView.mas_trailing).offset(-60);
            make.width.mas_equalTo(18);
        }];
        
        UIButton *cover = [UIButton buttonWithType:UIButtonTypeCustom];
        [cover addTarget:self action:@selector(selectFamily:) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:cover];
        [cover mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(titleLab.mas_leading);
            make.trailing.equalTo(imgv.mas_trailing);
            make.top.equalTo(titleLab.mas_top);
            make.bottom.equalTo(titleLab.mas_bottom);
        }];
        
        self.addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setImage:[UIImage imageNamed:@"homeAdd"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:_addBtn];
        [_addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-15);
            make.centerY.equalTo(titleLab);
            make.width.height.mas_equalTo(24);
        }];
        
        
        UIView *weatherView = [[UIView alloc] init];
        [_navView addSubview:weatherView];
        [weatherView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLab.mas_bottom);
            make.leading.trailing.mas_equalTo(0);
            make.height.mas_equalTo(weatherHeight);
        }];
        
        
        self.weatherLab = [[UILabel alloc] init];
        self.weatherLab.attributedText = [self handleWeather];
        [weatherView addSubview:self.weatherLab];
        [self.weatherLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.top.mas_equalTo(8);
        }];
    }
    return _navView;
}

- (UIView *)navView2
{
    if (!_navView2) {
        _navView2 = [[UIView alloc] initWithFrame:CGRectMake(0, -44 - weatherHeight, kScreenWidth, 44 + weatherHeight)];
        _navView2.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLab2 = [[UILabel alloc] init];
        titleLab2.text = @"tao的家";
        titleLab2.textColor = [UIColor blackColor];
        titleLab2.font = [UIFont boldSystemFontOfSize:24];
        [_navView2 addSubview:titleLab2];
        self.nick2 = titleLab2;
        [titleLab2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.height.mas_equalTo(44);
            make.top.mas_equalTo(0);
        }];
        
        UIImageView *imgv = [[UIImageView alloc] init];
        imgv.image = [UIImage imageNamed:@"downArrow"];
        [_navView2 addSubview:imgv];
        [imgv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(titleLab2.mas_trailing).offset(10);
            make.centerY.equalTo(titleLab2);
            make.trailing.lessThanOrEqualTo(_navView2.mas_trailing).offset(-60);
            make.width.mas_equalTo(18);
        }];
        
        self.addBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn2 setImage:[UIImage imageNamed:@"homeAdd"] forState:UIControlStateNormal];
        [_addBtn2 addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
        [_navView2 addSubview:_addBtn2];
        [_addBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.centerY.equalTo(titleLab2);
            make.width.height.mas_equalTo(24);
        }];
        
        
        UIView *weatherView2 = [[UIView alloc] init];
        [_navView2 addSubview:weatherView2];
        [weatherView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLab2.mas_bottom);
            make.leading.trailing.mas_equalTo(0);
            make.height.mas_equalTo(weatherHeight);
        }];
        
        
        UILabel *wea = [[UILabel alloc] init];
        wea.attributedText = [self handleWeather];
        [weatherView2 addSubview:wea];
        self.weatherLab2 = wea;
        [wea mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(16);
            make.top.mas_equalTo(8);
        }];
    }
    return _navView2;
}

- (UIView *)navView3
{
    if (!_navView3) {
        _navView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, [TIoTUIProxy shareUIProxy].navigationBarHeight)];
        _navView3.backgroundColor = [UIColor whiteColor];
        _navView3.hidden = YES;
        
    }
    return _navView3;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
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

@end
