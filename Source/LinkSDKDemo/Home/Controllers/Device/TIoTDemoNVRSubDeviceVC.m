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

static NSString *const kNVRSubdeviceListCellID = @"kNVRSubdeviceListCellID";
static NSString *const kNVRSubdeviceListHeaderID = @"kNVRSubdeviceListHeaderID";
static NSString *const action_NVRSubdeviceList = @"action=inner_define&cmd=get_nvr_list";

@interface TIoTDemoNVRSubDeviceVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isShowSameScreenChoiceIcon;
@property (nonatomic, strong) NSMutableArray *selectedArray;

@end

@implementation TIoTDemoNVRSubDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUIViews];
    [self addRefreshControl];
    [self requestNVRSubdeviceList];
}

- (void)setupUIViews {
    
    self.isShowSameScreenChoiceIcon = NO;
    
    self.view.backgroundColor = [UIColor colorWithHexString:KActionSheetBackgroundColor];
    
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
    NSMutableArray * modelArray= [NSMutableArray new];
    for (int i = 0; i< 5; i++) {
        
        TIoTExploreOrVideoDeviceModel *subdeviceModel = [[TIoTExploreOrVideoDeviceModel alloc]init];
        subdeviceModel.DeviceName = @"name1";
        subdeviceModel.channel = @"1";
        subdeviceModel.Online = @"1";
        [modelArray addObject:subdeviceModel];
        
    }
    [self.dataArray removeAllObjects];
    self.dataArray = [NSMutableArray arrayWithArray:modelArray];
    [self.collectionView reloadData];
    [self.collectionView.refreshControl endRefreshing];
//    [[TIoTCoreXP2PBridge sharedInstance] getCommandRequestWithAsync:self.selectedModel.DeviceName?:@"" cmd:action_NVRSubdeviceList timeout:2*1000*1000 completion:^(NSString * _Nonnull jsonList) {
//
//        TIoTDemoNVRSubdeviceListModel *subdeviceList = [TIoTDemoNVRSubdeviceListModel yy_modelWithJSON:jsonList];
//        [self.dataArray removeAllObjects];
//        self.dataArray = [NSMutableArray arrayWithArray:subdeviceList.Data];
//        [self.collectionView reloadData];
//        [self.collectionView.refreshControl endRefreshing];
//
//    }];
    
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
    cell.chooseDeviceBlock = ^NSMutableArray *(BOOL isSelected) {
        if (isSelected) {
            model.isSelected = @"1";
            [weakSelf.selectedArray addObject:model];
        }else {
            model.isSelected = @"0";
            [weakSelf.selectedArray removeObject:model];
        }
        return weakSelf.selectedArray;
    };
    cell.model = model;
    
    TIoTDemoCustomSheetView *customActionSheet = [[TIoTDemoCustomSheetView alloc]init];
    cell.moreActionBlock = ^{
        NSArray *actionTitleArray = @[@"预览",@"取消"];
        
        ChooseFunctionBlock previewVideoBlock = ^(TIoTDemoCustomSheetView *view){
            NSLog(@"预览");
            TIoTExploreOrVideoDeviceModel *model = self.dataArray[indexPath.row];
            TIoTDemoSameScreenVC *sameScreenVC = [[TIoTDemoSameScreenVC alloc]init];
            [sameScreenVC setupSameScreenArray:@[model]];
            [weakSelf.navigationController pushViewController:sameScreenVC animated:YES];
            [weakSelf resetDeviceListStatus];
            [customActionSheet removeFromSuperview];
        };
        
        ChooseFunctionBlock cancelBlock = ^(TIoTDemoCustomSheetView *view) {
            NSLog(@"取消");
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
    TIoTDemoDeviceHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kNVRSubdeviceListHeaderID forIndexPath:indexPath];
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
            if (self.selectedArray.count != 0) {
                TIoTDemoSameScreenVC *sameScreenVC = [[TIoTDemoSameScreenVC alloc]init];
                [sameScreenVC setupSameScreenArray:self.selectedArray];
                [weakSelf.navigationController pushViewController:sameScreenVC animated:YES];
                [weakSelf resetDeviceListStatus];
            }else {
                [weakSelf resetDeviceListStatus];
            }
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
