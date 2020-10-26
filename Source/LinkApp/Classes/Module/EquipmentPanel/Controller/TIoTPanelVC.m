//
//  WCPanelVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/2.
//  Copyright © 2020 Winext. All rights reserved.
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

static CGFloat itemSpace = 9;
static CGFloat lineSpace = 9;
#define kSectionInset UIEdgeInsetsMake(10, 16, 10, 16)

static NSString *itemId2 = @"i_ooo223";
static NSString *itemId3 = @"i_ooo454";


@implementation TIoTCollectionView

//- (BOOL)touchesShouldCancelInContentView:(UIView *)view
//{
//    return YES;
//}

@end


@interface TIoTPanelVC ()<UICollectionViewDelegate,UICollectionViewDataSource,WCWaterFlowLayoutDelegate>
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

@end

@implementation TIoTPanelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [HXYNotice addReportDeviceListener:self reaction:@selector(deviceReport:)];
    self.deviceInfo.deviceId = self.deviceDic[@"DeviceId"];
    
    
    [self setupUI];
    
    [self getProductsConfig];
    
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

#pragma mark - UI

- (void)showOfflineTip
{
    if (![self.deviceDic[@"Online"] boolValue]) {
        TIoTTipView *vc = [[TIoTTipView alloc] init];
        vc.feedback = ^{
            UIViewController *vc = [NSClassFromString(@"TIoTFeedBackViewController") new];
            [self.navigationController pushViewController:vc animated:YES];
        };
        vc.navback = ^{
            [self.navigationController popViewControllerAnimated:YES];
        };
        [vc showInView:self.view];
    }
}


- (void)setupUI
{
    
    if (_isOwner) {
        UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreIcon"] style:UIBarButtonItemStyleDone target:self action:@selector(moreClick:)];
        self.navigationItem.rightBarButtonItem  = moreItem;
    }
    
    [self wr_setNavBarBackgroundAlpha:0];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.bgView];
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
    
    [self showOfflineTip];
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
                [source addObject:map[[NSString stringWithFormat:@"%i",i]]];
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
        self.bottomLayer.colors = @[(id)kRGBColor(106, 255, 255).CGColor,(id)kMainColor.CGColor];
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
        
        [[TIoTRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":@[self.productId]} success:^(id responseObject) {
            NSArray *data = responseObject[@"Data"];
            if (data.count > 0) {
                NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
                [self loadData:config];
            }
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {

    }];
    
    
}

- (void)loadData:(NSDictionary *)dic {
    [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
    
    [[TIoTRequestObject shared] post:AppGetProducts Param:@{@"ProductIds":@[self.productId]} success:^(id responseObject) {
        NSArray *tmpArr = responseObject[@"Products"];
        if (tmpArr.count > 0) {
            NSString *DataTemplate = tmpArr.firstObject[@"DataTemplate"];
            NSDictionary *DataTemplateDic = [NSString jsonToObject:DataTemplate];
            
//            TIoTDataTemplateModel *product = [TIoTDataTemplateModel yy_modelWithJSON:DataTemplate];
//            TIoTProductConfigModel *config = [TIoTProductConfigModel yy_modelWithJSON:dic];
            [self getDeviceData:dic andBaseInfo:DataTemplateDic];
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)getDeviceData:(NSDictionary *)uiInfo andBaseInfo:(NSDictionary *)baseInfo {

    [[TIoTRequestObject shared] post:AppGetDeviceData Param:@{@"ProductId":self.productId,@"DeviceName":self.deviceName} success:^(id responseObject) {
        NSString *tmpStr = (NSString *)responseObject[@"Data"];
        NSDictionary *tmpDic = [NSString jsonToObject:tmpStr];
        
//        TIoTDeviceDataModel *product = [TIoTDeviceDataModel yy_modelWithJSON:tmpStr];
        
        [self.deviceInfo zipData:uiInfo baseInfo:baseInfo deviceData:tmpDic];
        [self layoutHeader];
        [self.coll reloadData];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {

    }];
}

//下发数据
- (void)reportDeviceData:(NSDictionary *)deviceReport{
    NSDictionary *tmpDic = @{
                                @"ProductId":self.productId,
                                @"DeviceName":self.deviceName,
                                @"Data":[NSString objectToJson:deviceReport],
                            };
    
    [[TIoTRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

//收到上报
- (void)deviceReport:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    [self.deviceInfo handleReportDevice:dic];
    
    [self reloadForBig];
    [self.coll reloadData];
}


#pragma mark - event

- (void)moreClick:(UIButton *)sender{
    
    TIoTPanelMoreViewController *vc = [[TIoTPanelMoreViewController alloc] init];
    vc.title = @"设备详情";
    vc.deviceDic = self.deviceDic;
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
    
    if (indexPath.row < self.deviceInfo.properties.count) {
        NSDictionary *dic = self.deviceInfo.properties[indexPath.row];
        if ([dic[@"define"][@"type"] isEqualToString:@"bool"]) {
            
        }
        else if ([dic[@"define"][@"type"] isEqualToString:@"enum"]){
            
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

@end
