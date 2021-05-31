//
//  TIoTDemoHomeViewController.m
//  LinkApp
//
//  Created by ccharlesren on 2021/5/25.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoHomeViewController.h"
#import "UIImage+TIoTDemoExtension.h"
#import "TIoTDemoVideoDeviceCell.h"
#import "TIoTDemoDeviceHeaderView.h"
#import "TIoTDemoCustomSheetView.h"
#import "TIoTCoreAppEnvironment.h"
#import "TIoTCoreDeviceSet.h"
#import "TIoTCoreXP2PBridge.h"
#import "TIoTDemoSameScreenVC.h"

#import "TIoTExploreDeviceListModel.h"
#import "TIoTVideoDeviceListModel.h"
#import "TIoTExploreOrVideoDeviceModel.h"
#import <YYModel.h>

static NSString *const kVideoDeviceListCellID = @"kVideoDeviceListCellID";
static NSString *const kVIdeoDeviceListHeaderID = @"kVIdeoDeviceListHeaderID";

@interface TIoTDemoHomeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isShowSameScreenChoiceIcon;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@end

@implementation TIoTDemoHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavBarStyle];
    [self setupUIViews];
    [self addRefreshControl];
    [self requestDeviceList];
}

- (void)setupNavBarStyle {
    self.title = @"IoT Video Demo";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#FFFFFF"],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:17]}];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage getGradientImageWithColors:@[[UIColor colorWithHexString:@"#3D8BFF"],[UIColor colorWithHexString:@"#1242FF"]] imgSize:CGSizeMake(kScreenWidth, 44)] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage getGradientImageWithColors:@[[UIColor colorWithHexString:@"#3D8BFF"],[UIColor colorWithHexString:@"#1242FF"]] imgSize:CGSizeMake(kScreenWidth, 44)] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage getGradientImageWithColors:@[[UIColor colorWithHexString:@"#ffffff"],[UIColor colorWithHexString:@"#ffffff"]] imgSize:CGSizeMake(kScreenWidth, 44)] forBarMetrics:UIBarMetricsDefault];
}


- (void)setupUIViews {
    
    self.isShowSameScreenChoiceIcon = NO;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    
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
        [refreshControl addTarget:self action:@selector(refreshDeviceList:) forControlEvents:UIControlEventValueChanged];
        self.collectionView.refreshControl = refreshControl;
    }
}

- (void)refreshDeviceList:(UIRefreshControl *)sender {
    [self requestDeviceList];
}

#pragma mark - 请求设备列表
- (void)requestDeviceList {
    [[TIoTCoreDeviceSet shared] getVideoDeviceListLimit:99 offset:0 productId:[TIoTCoreAppEnvironment shareEnvironment].cloudProductId returnModel:YES success:^(id  _Nonnull responseObject) {
        TIoTVideoDeviceListModel *model = [TIoTVideoDeviceListModel yy_modelWithJSON:responseObject];

        [self.dataArray removeAllObjects];
        self.dataArray = [NSMutableArray arrayWithArray:model.Data];
        [self.collectionView reloadData];
        [self.collectionView.refreshControl endRefreshing];
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {

    }];
    
}

#pragma mark - UICollectionViewDataSource And UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TIoTDemoVideoDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoDeviceListCellID forIndexPath:indexPath];
    
    TIoTExploreOrVideoDeviceModel *model = self.dataArray[indexPath.row];
    
    cell.isShowChoiceDeviceIcon = self.isShowSameScreenChoiceIcon;
    
    cell.chooseDeviceBlock = ^NSMutableArray *(BOOL isSelected) {
        if (isSelected) {
            model.isSelected = @"1";
            [self.selectedArray addObject:model];
        }else {
            model.isSelected = @"0";
            [self.selectedArray removeObject:model];
        }
        return self.selectedArray;
    };
    cell.model = model;
    
    TIoTDemoCustomSheetView *customActionSheet = [[TIoTDemoCustomSheetView alloc]init];
    cell.moreActionBlock = ^{
        NSArray *actionTitleArray = @[@"预览",@"回放",@"取消"];
        
        ChooseFunctionBlock previewVideoBlock = ^(TIoTDemoCustomSheetView *view){
            NSLog(@"预览");
            [customActionSheet removeFromSuperview];
        };
        
        ChooseFunctionBlock playbackVideoBlock = ^(TIoTDemoCustomSheetView *view){
            NSLog(@"回放");
            [customActionSheet removeFromSuperview];
        };
        
        ChooseFunctionBlock cancelBlock = ^(TIoTDemoCustomSheetView *view) {
            NSLog(@"取消");
            [view removeFromSuperview];
        };
        NSArray *actionBlockArray = @[previewVideoBlock,playbackVideoBlock,cancelBlock];
        
        
        [customActionSheet sheetViewTopTitleArray:actionTitleArray withMatchBlocks:actionBlockArray];
        [[UIApplication sharedApplication].delegate.window addSubview:customActionSheet];
        [customActionSheet mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.right.bottom.equalTo([UIApplication sharedApplication].delegate.window);
        }];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat kHeight = 44;
    if (self.dataArray.count == 0) {
        kHeight = 0;
    }
    return CGSizeMake(kScreenWidth, kHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    TIoTDemoDeviceHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kVIdeoDeviceListHeaderID forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    
    //编辑操作
    headerView.editBlock = ^(TIoTDemoDeviceHeaderView *headerView,BOOL isEditPartten){
        
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
            [weakSelf resetDeviceListStatus];
            TIoTDemoSameScreenVC *sameScreenVC = [[TIoTDemoSameScreenVC alloc]init];
            [weakSelf.navigationController pushViewController:sameScreenVC animated:YES];
        }
        
    };
    
    //取消操作
    headerView.cancelEditBlock = ^{
        [weakSelf resetDeviceListStatus];
    };
    
    return headerView;
    
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
        CGFloat itemWidth = 165;
        CGFloat itemHeight = 138;
//        flowLayout.sectionHeadersPinToVisibleBounds = YES;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(4, 16, 4, 16);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
        [_collectionView registerClass:[TIoTDemoVideoDeviceCell class] forCellWithReuseIdentifier:kVideoDeviceListCellID];
        [_collectionView registerClass:[TIoTDemoDeviceHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kVIdeoDeviceListHeaderID];
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
