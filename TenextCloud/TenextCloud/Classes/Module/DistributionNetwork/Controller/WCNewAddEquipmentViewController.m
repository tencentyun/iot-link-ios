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

@interface WCNewAddEquipmentViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) CGFloat itemWidth;

@property (nonatomic, strong) WCDiscoverProductView *discoverView;
@property (nonatomic, strong) UITableView *categoryTableView;
@property (nonatomic, strong) UICollectionView *productCollectionView;
@property (nonatomic, copy) NSArray *categoryArr;

@end

@implementation WCNewAddEquipmentViewController

static NSString *cellId = @"WCProductCell";
static NSString *headerId = @"WCProductSectionHeader";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _itemWidth = (kScreenWidth - 95 - 19.5*2 - 9.5*2) / 3.0;
    
    [self setupUI];
}

#pragma mark -

- (void)setupUI{
    self.title = @"添加设备";
    self.view.backgroundColor = kRGBColor(242, 242, 242);
    
    self.discoverView = [[WCDiscoverProductView alloc] init];
    [self.view addSubview:self.discoverView];
    [self.discoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset([WCUIProxy shareUIProxy].navigationBarHeight + 10);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(220);
    }];
    
    [self.view addSubview:self.categoryTableView];
    [self.categoryTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self.view);
        make.width.mas_equalTo(95);
        make.top.equalTo(self.discoverView.mas_bottom).offset(10);
    }];
    
    [self.view addSubview:self.productCollectionView];
    [self.productCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.categoryTableView.mas_right);
        make.top.equalTo(self.categoryTableView);
        make.bottom.right.equalTo(self.view);
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

#pragma mark UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    } else {
        return 10;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WCProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *headerView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 0) {
            headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId forIndexPath:indexPath];
            if (headerView == nil) {
                headerView = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 95, 43)];
            }
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 38)];
            label.font = [UIFont wcPfRegularFontOfSize:14];
            label.textColor = kRGBColor(136, 136, 136);
            label.text = @"推荐";
            [headerView addSubview:label];
        } else {
            headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId forIndexPath:indexPath];
            if (headerView == nil) {
                headerView = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 95, 20.5)];
            }
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth - 115, 0.5)];
            lineView.backgroundColor = kRGBColor(229, 229, 229);
            [headerView addSubview:lineView];
        }
    }
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(_itemWidth, 104.5);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 5, 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGSizeMake(kScreenWidth, 43);
    } else {
        return CGSizeMake(kScreenWidth, 20.5);
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
        [_productCollectionView registerClass:[WCProductCell class] forCellWithReuseIdentifier:cellId];
        [_productCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
        
    }
    return _productCollectionView;
}

- (NSArray *)categoryArr{
    if (_categoryArr == nil) {
        _categoryArr = @[
                        @{@"title":@"全部"},
                        @{@"title":@"客厅"},
                        @{@"title":@"卧室"},
                        @{@"title":@"厨房"},
                    
                        ];
    }
    return _categoryArr;
}

@end
