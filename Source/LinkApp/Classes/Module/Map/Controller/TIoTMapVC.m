//
//  TIoTMapVC.m
//  LinkApp
//
//  Created by ccharlesren on 2021/3/1.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTMapVC.h"
#import <QMapKit/QMSSearchOption.h>
#import <QMapKit/QMSSearcher.h>
#import <QMapKit/QMSSearchServices.h>
#import "TIoTChooseLocationCell.h"
#import <QMapKit/QMapKit.h>
#import "TIoTMapLocationModel.h"
#import <MJRefresh.h>
#import "TIoTIntelligentBottomActionView.h"
#import "TIoTAddressParseModel.h"
#import "TIoTChooseLocationCell.h"
#import "UIView+XDPExtension.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTSearchLocationVC.h"


static CGFloat const kSearchTopMap = 20;     //searchview 距离map底部的高度
static CGFloat const kMapVisualMaxHeight = 350 + kSearchTopMap;    // 最大地图可视高度，（不包含searchview,searchview添加在map上）
static CGFloat const kSearchViewHeight = 64;    //searchview 高度
static CGFloat const KScrolledHeight = 175 + kSearchTopMap;   //向上滑动后，地图可视高度

static CGFloat const kLocationBtnWidthOrHeight = 60;  //定位按钮宽、高
static CGFloat const kIntervalHeight = 25;  //定位按钮距离tableview 距离
static CGFloat const kRightPadding = 0; //定位按钮右边距

@interface TIoTMapVC ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate,QMSSearchDelegate>
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomActionView;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL isFirstLocatePin;   //首次进入定位大头针判断
@property (nonatomic, strong) QMSSearcher *mapSearcher;

@property (nonatomic, strong) QPointAnnotation *annotation;
@property (nonatomic, strong) QPinAnnotationView *pinView;
@property (nonatomic, assign) CLLocationCoordinate2D lastLocation;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UILabel *searchTipLabel;
@property (nonatomic, strong) UITableView *searchResultTableView;
@property (nonatomic, strong) NSMutableArray *searchResultArray;
@property (nonatomic, strong) UIButton *locationBtn;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger pageNumber;
@end

@implementation TIoTMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kMapVisualMaxHeight);
    
    [self resetRequestPragma];
    
    self.mapView.zoomLevel = 15.0;
    [self setupPointAnnotation];
//        [self searchCurrentLocationWithKeyword:@""];
//        [self setupSearchView];
        [self setupKeyboardNotification];
    [self setupBottomView];
    
    [self setupRefreshView];
    
    self.mapView.delegate = self;
    [self.mapView setUserLocationHidden:NO];
    [self.mapView setShowsUserLocation:YES];
}

- (void)setupMapCenter {
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate];
    [self.searchResultArray removeAllObjects];
    [self resetRequestPragma];
    [self requestLocationList:self.mapView.userLocation.location.coordinate];
}

#pragma mark - overide
- (NSString *)testTitle {
    return @"";
}

- (void)handleTestAction {
    
}

#pragma mark - Custom method

- (void)setupPointAnnotation {
    _annotation = [[QPointAnnotation alloc] init];
    NSLog(@"location----%@",self.mapView.userLocation.location);
    NSLog(@"_annotation.coordinate.latitude----%f",_annotation.coordinate.latitude);
    [self.mapView addAnnotation:_annotation];
    
}

- (void)setupHavedLocation {
    
    NSDictionary *addJsonDic =  [NSString jsonToObject:self.addressString?:@""];
    if (addJsonDic != nil) {
        double lat = [addJsonDic[@"latitude"] doubleValue];
        double lng = [addJsonDic[@"longitude"] doubleValue];
        
        CLLocationCoordinate2D addressLocation = CLLocationCoordinate2DMake(lat,lng);
        
        //定位大头针
        [self.mapView setCenterCoordinate:addressLocation];
        
        //刷新地点列表
        [self resetRequestPragma];
        [self requestLocationList:addressLocation];
    }else {
        TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@&key=%@",MapSDKAddressParseURL,self.addressString?:@"",model.TencentMapSDKValue];
        
        NSString *urlEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        [[TIoTRequestObject shared] get:urlEncoded isNormalRequest:YES success:^(id responseObject) {
            TIoTAddressParseModel *addressModel = [TIoTAddressParseModel yy_modelWithJSON:responseObject[@"result"]];
            
            CLLocationCoordinate2D addressLocation = CLLocationCoordinate2DMake(addressModel.location.lat,addressModel.location.lng);
            
            //定位大头针
            [self.mapView setCenterCoordinate:addressLocation];
            
            //刷新地点列表
            [self resetRequestPragma];
            [self requestLocationList:addressLocation];
            
        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            
        }];
    }
    
    
}

- (void)setupBottomView {

    //定位按钮
    self.locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.locationBtn setImage:[UIImage imageNamed:@"location_choose"] forState:UIControlStateNormal];
    [self.locationBtn addTarget:self action:@selector(setupMapCenter) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.locationBtn];
    [self.locationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kLocationBtnWidthOrHeight);
        make.right.equalTo(self.view.mas_right).offset(-kRightPadding);
        make.bottom.equalTo(self.mapView.mas_bottom).offset(-kIntervalHeight);
    }];
    
    
    //
    CGFloat kBottomViewHeight = 90;
    
    _searchResultTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _searchResultTableView.backgroundColor = [UIColor whiteColor];
    _searchResultTableView.dataSource = self;
    _searchResultTableView.delegate = self;
    _searchResultTableView.rowHeight = 75;
    _searchResultTableView.contentInset = UIEdgeInsetsMake(kMapVisualMaxHeight + kSearchViewHeight - kSearchTopMap, 0, 0, 0);
    _searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _searchResultTableView.layer.cornerRadius = 12;
    
    [self.view addSubview:_searchResultTableView];
    [self.view insertSubview:_searchResultTableView atIndex:0];

    [_searchResultTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view).offset(64);
        }
    }];
    
    
    CGFloat kWidthPadding = 16;
    //searchview
    [self.view addSubview:self.searchView];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.mapView);
        make.height.mas_equalTo(kSearchViewHeight);
        make.top.equalTo(self.mapView.mas_bottom).offset(-kSearchTopMap);
    }];
    
    UIButton *searchLocationBtn = [[UIButton alloc]init];
    searchLocationBtn.backgroundColor = [UIColor colorWithHexString:@"#F3F3F5"];
    searchLocationBtn.layer.cornerRadius = 20;
    [searchLocationBtn addTarget:self action:@selector(searchLocaion) forControlEvents:UIControlEventTouchUpInside];
    [self.searchView addSubview:searchLocationBtn];
    [searchLocationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchView.mas_top).offset(16);
        make.left.equalTo(self.searchView.mas_left).offset(kWidthPadding);
        make.right.equalTo(self.searchView.mas_right).offset(-kWidthPadding);
        make.height.mas_equalTo(38);
    }];
    
    CGFloat kSearchIconSize = 20;
    UIImageView *searchIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search_location"]];
    [searchLocationBtn addSubview: searchIcon];
    [searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kSearchIconSize);
        make.centerY.equalTo(searchLocationBtn);
        make.left.equalTo(searchLocationBtn.mas_left).offset(18);
    }];
    
    self.searchTipLabel = [[UILabel alloc]init];
    [self.searchTipLabel setLabelFormateTitle:NSLocalizedString(@"search_location", @"搜索地点") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#A1A7B2" textAlignment:NSTextAlignmentLeft];
    [searchLocationBtn addSubview:self.searchTipLabel];
    [self.searchTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchIcon.mas_right).offset(10);
        make.centerY.equalTo(searchLocationBtn);
        make.right.equalTo(searchLocationBtn.mas_right);
    }];
    
    
    //底部确认按钮
    [self.view addSubview:self.bottomActionView];
    [self.bottomActionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(kBottomViewHeight);
    }];

    [self.view changeViewRectConnerWithView:self.searchView withRect:CGRectMake(0, 0, kScreenWidth, kSearchViewHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    
}

- (void)setupRefreshView
{
    // 下拉刷新
    WeakObj(self)
//    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{

//    }];
    
    self.searchResultTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [selfWeak loadMoreData];
    }];

}

- (void)resetRequestPragma {
    self.offset = 20;
    self.pageNumber = 1;
}

- (void)loadMoreData {
    
    [self requestLocationList:_annotation.coordinate];
}

- (void)searchLocaion {
    TIoTSearchLocationVC *searchVC = [[TIoTSearchLocationVC alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - QMapViewDelegate

- (void)mapView:(QMapView *)mapView didUpdateUserLocation:(QUserLocation *)userLocation fromHeading:(BOOL)fromHeading {
    if (_isLoaded == NO) {
        self.longitude = userLocation.location.coordinate.longitude;
        self.latitude = userLocation.location.coordinate.latitude;
        
        //每次进入页面 判断上页面中 设置位置 是否有值
        if (_isFirstLocatePin == NO) {
            if ([NSString isNullOrNilWithObject:self.addressString] || [NSString isFullSpaceEmpty:self.addressString] || [self.addressString isEqualToString:NSLocalizedString(@"setting_family_address", @"设置定位")]) {
                [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.latitude,self.longitude)];
                //首次请求定位周围地点列表
                [self resetRequestPragma];
                [self requestLocationList:CLLocationCoordinate2DMake(self.latitude,self.longitude)];
            }else {
                [self setupHavedLocation];
            }
            _isFirstLocatePin = YES;
        }else {
            NSLog(@"longitude---%f---latitude---%f",self.longitude,self.latitude);
            
            //首次请求定位周围地点列表
            [self resetRequestPragma];
            [self requestLocationList:mapView.centerCoordinate];
        }
        _isLoaded = YES;
    }
}

- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation {
    if ([annotation isKindOfClass:[QPointAnnotation class]]) {

        static NSString *pinIndentifier = @"PinIndentifier";
        if (annotation == _annotation) {
            _pinView = (QPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIndentifier];
            if (_pinView == nil) {
                _pinView = [[QPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIndentifier];
                _pinView.pinColor = QPinAnnotationColorGreen;
            }

            return _pinView;
        }
        
    }
    
    return nil;
}

- (void)mapView:(QMapView *)mapView regionWillChangeAnimated:(BOOL)animated gesture:(BOOL)bGesture {
    [self.view endEditing:YES];
}

- (void)mapViewRegionChange:(QMapView *)mapView {
    // 更新位置
    _annotation.coordinate = mapView.centerCoordinate;
}

// 请求当前位置的地标
- (void)mapView:(QMapView *)mapView regionDidChangeAnimated:(BOOL)animated gesture:(BOOL)bGesture {
    if (bGesture == YES) {
        _searchBar.text = @"";
        
        // 判断与上次坐标是否相同
        CLLocationCoordinate2D centerCoord = mapView.centerCoordinate;
        
        if (_lastLocation.latitude == centerCoord.latitude && _lastLocation.longitude == centerCoord.longitude) {
            return;
        }
        
        // 请求当前地点
//        [self searchCurrentLocationWithKeyword:@""];
        
        //请求当前经纬度周围地点列表
        [self resetRequestPragma];
        [self requestLocationList:centerCoord];
        
    }
    NSLog(@"----!!!___%f",mapView.centerCoordinate.longitude);
    _annotation.coordinate = mapView.centerCoordinate;
}

/*
- (void)searchCurrentLocationWithKeyword:(NSString *)keyword {
    CLLocationCoordinate2D centerCoord = self.mapView.centerCoordinate;
    
    QMSPoiSearchOption *option = [[QMSPoiSearchOption alloc] init];
    if (keyword.length > 0) {
        option.keyword = keyword;
    }
    option.boundary = [NSString stringWithFormat:@"nearby(%f,%f,2000,1)", centerCoord.latitude, centerCoord.longitude];
    
    [self.mapSearcher searchWithPoiSearchOption:option];
}

- (void)searchWithPoiSearchOption:(QMSPoiSearchOption *)poiSearchOption didReceiveResult:(QMSPoiSearchResult *)poiSearchResult {
    NSLog(@"%@", poiSearchResult);
    
    if (poiSearchResult.count == 0) {
        return;
    }
    
    QMSPoiData *firstData = poiSearchResult.dataArray[0];
    // 地图移动到搜索结果的第一个位置
    if (_searchBar.text.length > 0) {
        _selectedIndex = 0;
        
        _annotation.coordinate = firstData.location;
        [self.mapView setCenterCoordinate:firstData.location animated:YES];
    } else {
        _selectedIndex = -1;
    }
    
//    _searchResultArray = [poiSearchResult.dataArray mutableCopy];
//    [_searchResultTableView reloadData];
    
    [_searchResultArray removeAllObjects];
    [self resetRequestPragma];
    [self requestLocationList:firstData.location];
}
*/

#pragma mark - network request
- (void)requestLocationList:(CLLocationCoordinate2D )location {
    
    TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
    
    NSString *locationString = [NSString stringWithFormat:@"%f,%f",location.latitude,location.longitude];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@&get_poi=1&key=%@&poi_options=address_format=short;page_size=%ld;page_index=%ld",MapSDKLocationParseURL,locationString,model.TencentMapSDKValue,(long)self.offset,(long)self.pageNumber];
    [[TIoTRequestObject shared] get:urlString isNormalRequest:YES success:^(id responseObject) {
        TIoTMapLocationModel *locationModel = [TIoTMapLocationModel yy_modelWithJSON:responseObject[@"result"]];
        
        [self endRefresh:YES total:[locationModel.poi_count integerValue]];
        [self.searchResultArray addObjectsFromArray:locationModel.pois];
        if (self.searchResultArray.count == 0) {
            [MBProgressHUD dismissInView:self.view];
        }
        
        [self.searchResultTableView reloadData];
        
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        [self.searchResultTableView.mj_footer endRefreshing];
    }];
}

- (void)endRefresh:(BOOL)isFooter total:(NSInteger)total {
    
    self.pageNumber += 1;
    if (isFooter) {
        if (self.offset >= total) {
            [self.searchResultTableView.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [self.searchResultTableView.mj_footer endRefreshing];
        }
    }
    else{
        [self.searchResultTableView.mj_header endRefreshing];
        if (self.offset >= total) {
            [self.searchResultTableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.searchResultTableView.mj_footer endRefreshing];
        }
    }
}

#pragma mark - SearchBar
- (void)setupSearchView {
    
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - kMapVisualMaxHeight, [UIScreen mainScreen].bounds.size.width, kMapVisualMaxHeight)];
    _searchView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_searchView];

    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    _searchBar.showsCancelButton = YES;
    _searchBar.delegate = self;
    [_searchView addSubview:_searchBar];

    _searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, kMapVisualMaxHeight - 44) style:UITableViewStyleGrouped];
    _searchResultTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _searchResultTableView.dataSource = self;
    _searchResultTableView.delegate = self;
    _searchResultTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.01, 0.01)];
    [_searchView addSubview:_searchResultTableView];
}

#pragma mark - system searchbar delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [self searchCurrentLocationWithKeyword:searchBar.text];
}


#pragma mark - TableViewDelegate And TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TIoTChooseLocationCell *cell = [TIoTChooseLocationCell cellWithTableView:tableView];

//    QMSPoiData *data = _searchResultArray[indexPath.row];
    if (_searchResultArray.count != 0) {
        TIoTPoisModel *cellModel = _searchResultArray[indexPath.row];
        cell.locationModel = cellModel;
    }
    
    if (indexPath.row == _selectedIndex) {
        cell.isChoosed = YES;
    } else {
        cell.isChoosed = NO;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    _selectedIndex = indexPath.row;

//    QMSPoiData *data = _searchResultArray[indexPath.row];
    TIoTPoisModel *cellModel = _searchResultArray[indexPath.row];
    
    // 更新位置
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(cellModel.location.lat, cellModel.location.lng) animated:YES];

    [self.searchResultTableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollOffSetY = scrollView.contentOffset.y;
    NSLog(@"scrollOffset--->%f",scrollOffSetY);

    CGFloat kTableViewHeadrHeight = kMapVisualMaxHeight;

    CGFloat kHeaderViewOrigionY = (kMapVisualMaxHeight+kSearchViewHeight)/2;
    CGFloat kOrigionY = - (kSearchViewHeight + KScrolledHeight);
    
    if (scrollOffSetY <= -kTableViewHeadrHeight) {
        self.mapView.center = CGPointMake(kScreenWidth/2, kHeaderViewOrigionY);

        self.mapView.frame = CGRectMake(0, 0, self.mapView.frame.size.width, kTableViewHeadrHeight);
        
    }else if (scrollOffSetY >-kTableViewHeadrHeight && scrollOffSetY < kOrigionY) {

//        self.mapView.center = CGPointMake(kScreenWidth/2, kHeaderViewOrigionY - (kTableViewHeadrHeight+scrollOffSetY));
        
        self.mapView.frame = CGRectMake(0, 0, self.mapView.frame.size.width, kTableViewHeadrHeight - (kTableViewHeadrHeight+scrollOffSetY));
        
    }else if (scrollOffSetY >= kOrigionY) {

//        self.mapView.center = CGPointMake(kScreenWidth/2, kHeaderViewOrigionY - (kTableViewHeadrHeight+kOrigionY));
        
        self.mapView.frame = CGRectMake(0, 0, self.mapView.frame.size.width, kTableViewHeadrHeight - (kTableViewHeadrHeight+kOrigionY));
    }
    
}

#pragma mark - Keyboard
- (void)setupKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.searchView.frame = CGRectMake(0, 0, weakSelf.searchView.bounds.size.width, self.view.frame.size.height);
        weakSelf.searchResultTableView.frame = CGRectMake(0, weakSelf.searchBar.frame.size.height, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height - height - weakSelf.searchBar.frame.size.height);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.searchView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 344, weakSelf.searchView.bounds.size.width, 344);
        weakSelf.searchResultTableView.frame = CGRectMake(0, weakSelf.searchBar.frame.size.height, [UIScreen mainScreen].bounds.size.width, weakSelf.searchView.frame.size.height - weakSelf.searchBar.frame.size.height);
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - QMSSearchDelegate
- (void)searchWithReverseGeoCodeSearchOption:(QMSReverseGeoCodeSearchOption *)reverseGeoCodeSearchOption didReceiveResult:(QMSReverseGeoCodeSearchResult *)reverseGeoCodeSearchResult {
    NSLog(@"pois--->%@", reverseGeoCodeSearchResult);
}

- (void)searchWithSearchOption:(QMSSearchOption *)searchOption didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}


#pragma mark - Lazy Loading
//- (UITableView *)tableView {
//    if (!_tableView) {
//        _tableView = [[UITableView alloc]init];
//        _tableView.backgroundColor = [UIColor whiteColor];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.rowHeight = 145;
//        _tableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0);
//    }
//    return _tableView;
//}

- (QMSSearcher *)mapSearcher {
    if (_mapSearcher == nil) {
        _mapSearcher = [[QMSSearcher alloc] initWithDelegate:self];
    }
    
    return _mapSearcher;
}

- (NSMutableArray *)searchResultArray {
    if (!_searchResultArray) {
        _searchResultArray = [[NSMutableArray alloc]init];
    }
    return _searchResultArray;
}

- (UIView *)searchView {
    if (!_searchView) {
        _searchView = [[UIView alloc]init];
        _searchView.backgroundColor = [UIColor whiteColor];
    }
    return _searchView;
}

- (TIoTIntelligentBottomActionView *)bottomActionView  {
    if (!_bottomActionView) {
        _bottomActionView = [[TIoTIntelligentBottomActionView alloc]init];
        _bottomActionView.backgroundColor = [UIColor whiteColor];
        [_bottomActionView bottomViewType:IntelligentBottomViewTypeSingle withTitleArray:@[NSLocalizedString(@"save", @"保存")]];
        __weak typeof(self)weakSelf = self;
        _bottomActionView.confirmBlock = ^{
            if (weakSelf.addressBlcok) {
                if (weakSelf.selectedIndex>=0) {
                    TIoTPoisModel *cellModel = weakSelf.searchResultArray[weakSelf.selectedIndex];
                    NSString *addressString = cellModel.title?:@"";
                    NSString *addressDetail = [NSString stringWithFormat:@"%@%@%@%@",cellModel.ad_info.province?:@"",cellModel.ad_info.city?:@"",cellModel.ad_info.district?:@"",cellModel.address?:@""];
                    NSString *lat = [NSString stringWithFormat:@"%f",cellModel.location.lat];
                    NSString *lng = [NSString stringWithFormat:@"%f",cellModel.location.lng];
                    NSDictionary *addressDic = @{@"address":addressDetail,@"latitude":lat,@"longitude":lng,@"city":cellModel.ad_info.city?:@"",@"name":cellModel.ad_info.name?:@"",@"title":addressString};
                    
                    NSString *addressJson = [addressDic yy_modelToJSONString];
                    weakSelf.addressBlcok(addressString, addressJson);
                }
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _bottomActionView;
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
