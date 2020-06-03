//
//  WCNewAddEquipmentViewController.m
//  TenextCloud
//
//  Created by Sun on 2020/5/27.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCNewAddEquipmentViewController.h"
#import "WCCategoryTableViewCell.h"
#import "WCProductCell.h"
#import "WCDiscoverProductView.h"

#import "WCHelpCenterViewController.h"
#import "WCScanlViewController.h"
#import "WCDistributionNetworkViewController.h"
#import "WCNavigationController.h"

@interface WCNewAddEquipmentViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) CGFloat itemWidth;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) WCDiscoverProductView *discoverView;
@property (nonatomic, strong) UITableView *categoryTableView;
@property (nonatomic, strong) UICollectionView *productCollectionView;
@property (nonatomic, strong) NSMutableArray *categoryArr;
@property (nonatomic, strong) NSMutableArray *productArr;
@property (nonatomic, strong) NSMutableArray *recommendArr;

@end

@implementation WCNewAddEquipmentViewController

static NSString *cellId = @"WCProductCell";
static NSString *headerId1 = @"WCProductSectionHeader1";
static NSString *headerId2 = @"WCProductSectionHeader2";

#pragma mark lifeCircle

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _itemWidth = (kScreenWidth - 95 - 19.5*2 - 9.5*2) / 3.0;
    _categoryArr = [NSMutableArray array];
    _productArr = [NSMutableArray array];
    _recommendArr = [NSMutableArray array];
    
    [self setupUI];
    [self getCategoryList];
    [self.discoverView performSelector:@selector(setStatus:) withObject:@(DiscoverDeviceStatusNotFound) afterDelay:5];
    
    [HXYNotice changeAddDeviceTypeListener:self reaction:@selector(receiveChangeAddDeviceType:)];
    [HXYNotice addUpdateDeviceListListener:self reaction:@selector(popHomeVC)];
}

#pragma mark - other

- (void)setupUI{
    self.title = @"添加设备";
    self.view.backgroundColor = kRGBColor(242, 242, 242);
    
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.discoverView = [[WCDiscoverProductView alloc] init];
    WeakObj(self)
    self.discoverView.helpAction = ^{
        WCHelpCenterViewController *vc = [[WCHelpCenterViewController alloc] init];
        [selfWeak.navigationController pushViewController:vc animated:YES];
    };
    self.discoverView.scanAction = ^{
        WCScanlViewController *vc = [[WCScanlViewController alloc] init];
        [selfWeak.navigationController pushViewController:vc animated:YES];
    };
    self.discoverView.retryAction = ^{
        selfWeak.discoverView.status = DiscoverDeviceStatusDiscovering;
        [selfWeak.discoverView performSelector:@selector(setStatus:) withObject:@(DiscoverDeviceStatusNotFound) afterDelay:5];
    };
    [self.scrollView addSubview:self.discoverView];
    [self.discoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView).offset(10);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(119.5);
    }];
    
    [self.scrollView addSubview:self.categoryTableView];
    [self.categoryTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self.view);
        make.width.mas_equalTo(95);
        make.top.equalTo(self.discoverView.mas_bottom).offset(10);
    }];
    
    [self.scrollView addSubview:self.productCollectionView];
    [self.productCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.categoryTableView.mas_right);
        make.top.equalTo(self.categoryTableView);
        make.bottom.right.equalTo(self.view);
    }];
}

- (void)refreshScrollContentSize {
    self.scrollView.bounces = YES;
    CGFloat productCollectionViewHeight = 0;
    CGFloat categoryTableViewHeight = self.categoryArr.count*50;
    if (self.recommendArr.count) {
        productCollectionViewHeight = ((self.recommendArr.count / 3 + (self.recommendArr.count % 3 == 0 ? 0 : 1) + self.productArr.count / 3 + (self.productArr.count % 3 == 0 ? 0 : 1)) * 104.5) + 43 + 20.5 + (self.recommendArr.count / 3 * 15) + (self.productArr.count / 3 * 15);
    } else {
        productCollectionViewHeight = ((self.productArr.count / 3 + (self.productArr.count % 3 == 0 ? 0 : 1)) * 104.5) + 20.5 + (self.productArr.count / 3 * 15);
    }
    CGFloat listHeight = productCollectionViewHeight > categoryTableViewHeight ? productCollectionViewHeight : categoryTableViewHeight;
    listHeight = 119.5 + 20 + listHeight > kScreenHeight - [WCUIProxy shareUIProxy].navigationBarHeight - 30 ? 119.5 + 20 + listHeight : kScreenHeight - [WCUIProxy shareUIProxy].navigationBarHeight - 30;
    self.scrollView.contentSize = CGSizeMake(kScreenWidth, listHeight);
}

- (void)jumpConfigVC:(NSString *)title{
    WCDistributionNetworkViewController *vc = [[WCDistributionNetworkViewController alloc] init];
    vc.title = title;

    WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)receiveChangeAddDeviceType:(NSNotification *)noti{
    NSInteger deviceType = [noti.object integerValue];
    if (deviceType == 0) {
        [self jumpConfigVC:@"智能配网"];
    } else if (deviceType == 1) {
        [self jumpConfigVC:@"自助配网"];
    }
}

- (void)popHomeVC {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - request
- (void)getCategoryList{
    [MBProgressHUD showLodingNoneEnabledInView:[UIApplication sharedApplication].keyWindow withMessage:@""];
    [[WCRequestObject shared] post:AppGetParentCategoryList Param:@{} success:^(id responseObject) {
        
        [self.categoryArr removeAllObjects];
        [self.categoryArr addObjectsFromArray:responseObject[@"List"]];
        
        WCLog(@"AppGetParentCategoryList responseObject%@", responseObject);
        [self.categoryTableView reloadData];
        if (self.categoryArr.count) {
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.categoryTableView selectRowAtIndexPath:firstIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            if ([self.categoryTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [self.categoryTableView.delegate tableView:self.categoryTableView didSelectRowAtIndexPath:firstIndexPath];
            }
        }
        
    } failure:^(NSString *reason, NSError *error) {
        [MBProgressHUD dismissInView:self.view];
    }];
}

- (void)getProductList:(NSString *)categoryKey {
    
    [[WCRequestObject shared] post:AppGetRecommList Param:@{@"CategoryKey":categoryKey} success:^(id responseObject) {
        [self.productArr removeAllObjects];
        [self.recommendArr removeAllObjects];
        [self.productArr addObjectsFromArray:responseObject[@"CategoryList"]];
        [self.recommendArr addObjectsFromArray:responseObject[@"ProductList"]];
        
        WCLog(@"AppGetRecommList responseObject%@", responseObject);
        [self.productCollectionView reloadData];
        [self refreshScrollContentSize];
        [MBProgressHUD dismissInView:self.view];
    } failure:^(NSString *reason, NSError *error) {
        [MBProgressHUD dismissInView:self.view];
    }];
}

- (void)getProductsConfig:(NSString *)productId{
    [[WCRequestObject shared] post:AppGetProductsConfig Param:@{@"ProductIds":@[productId]} success:^(id responseObject) {
        
        NSArray *data = responseObject[@"Data"];
        if (data.count > 0) {
            NSDictionary *config = [NSString jsonToObject:data[0][@"Config"]];
            WCLog(@"AppGetProductsConfig config%@", config);
            NSArray *wifiConfTypeList = config[@"WifiConfTypeList"];
            if (wifiConfTypeList.count > 0) {
                NSString *configType = wifiConfTypeList.firstObject;
                if ([configType isEqualToString:@"softap"]) {
                    [self jumpConfigVC:@"自助配网"];
                    return;
                }
            }
        }
        [self jumpConfigVC:@"智能配网"];
        WCLog(@"AppGetProductsConfig responseObject%@", responseObject);
        
    } failure:^(NSString *reason, NSError *error) {
        [self jumpConfigVC:@"智能配网"];
    }];
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.categoryArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WCCategoryTableViewCell *cell = [WCCategoryTableViewCell cellWithTableView:tableView];
    cell.dic = self.categoryArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MBProgressHUD showLodingNoneEnabledInView:[UIApplication sharedApplication].keyWindow withMessage:@""];
    NSString *categoryKey = self.categoryArr[indexPath.row][@"CategoryKey"]?:@"";
    [self getProductList:categoryKey];
}

#pragma mark UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.recommendArr.count) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.recommendArr.count) {
        if (section == 0) {
            return self.recommendArr.count;
        } else {
            return self.productArr.count;
        }
    } else {
        return self.productArr.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WCProductCell *cell = nil;
    if (self.recommendArr.count) {
        if (indexPath.section == 0) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
            cell.dic = self.recommendArr[indexPath.row];
        } else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
            cell.dic = self.productArr[indexPath.row];
        }
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
        cell.dic = self.productArr[indexPath.row];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *headerView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        if (self.recommendArr.count) {
            if (indexPath.section == 0) {
                headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId1 forIndexPath:indexPath];
                if (headerView == nil) {
                    headerView = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 95, 43)];
                }
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 38)];
                label.font = [UIFont wcPfRegularFontOfSize:14];
                label.textColor = kRGBColor(136, 136, 136);
                label.text = @"推荐";
                [headerView addSubview:label];
            } else {
                headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId2 forIndexPath:indexPath];
                if (headerView == nil) {
                    headerView = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 95, 20.5)];
                }
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth - 115, 0.5)];
                lineView.backgroundColor = kRGBColor(229, 229, 229);
                [headerView addSubview:lineView];
            }
        }
    }
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(_itemWidth, 104.5);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (self.recommendArr.count) {
        return UIEdgeInsetsMake(0, 10, 5, 10);
    } else {
        return UIEdgeInsetsMake(20.5, 10, 5, 10);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (self.recommendArr.count) {
        if (section == 0) {
            return CGSizeMake(kScreenWidth, 43);
        } else {
            return CGSizeMake(kScreenWidth, 20.5);
        }
    } else {
        return CGSizeZero;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.recommendArr.count && indexPath.section == 0) {//推荐的才去看是否需要跳转到soft ap，其他跳转smart config
        NSDictionary *dic = self.recommendArr[indexPath.row];
        NSString *productId = dic[@"ProductId"]?:@"";
        [self getProductsConfig:productId];
    } else {
        [self jumpConfigVC:@"智能配网"];
    }
}

#pragma mark setter or getter

- (UITableView *)categoryTableView{
    if (_categoryTableView == nil) {
        _categoryTableView = [[UITableView alloc] init];
        _categoryTableView.backgroundColor = [UIColor clearColor];
        _categoryTableView.rowHeight = 50;
        _categoryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _categoryTableView.delegate = self;
        _categoryTableView.dataSource = self;
        _categoryTableView.scrollEnabled = NO;
    }
    
    return _categoryTableView;
}

- (UICollectionView *)productCollectionView{
    if (!_productCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 0;
        
        _productCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _productCollectionView.backgroundColor = [UIColor whiteColor];
        _productCollectionView.delegate = self;
        _productCollectionView.dataSource = self;
        _productCollectionView.scrollEnabled = NO;
        [_productCollectionView registerClass:[WCProductCell class] forCellWithReuseIdentifier:cellId];
        [_productCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId1];
        [_productCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId2];
        
    }
    return _productCollectionView;
}

@end
