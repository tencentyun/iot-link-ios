//
//  TIoTMapViewController.m

#import "TIoTMapViewController.h"
#import <QMapKit/QMSSearchOption.h>
#import <QMapKit/QMSSearcher.h>
#import <QMapKit/QMSSearchServices.h>
#import "TIoTChooseLocationCell.h"
#import <QMapKit/QMapKit.h>

static CGFloat const kTableViewHeight = 400;
static CGFloat const kSearchBarHeight = 0;   //searchbar 高度 80
static CGFloat const KScrolledHeight = 200;   //向上滑动后，地图可视高度

@interface TIoTMapViewController () <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate,QMSSearchDelegate>
@property (nonatomic, strong) QMSSearcher *mapSearcher;

// 定位点标记
//@property (nonatomic, strong) QPointAnnotation *userLocationAnnotation;
//@property (nonatomic, strong) QPinAnnotationView *userLocationAnnotationView;

@property (nonatomic, strong) QPointAnnotation *annotation;
@property (nonatomic, strong) QPinAnnotationView *pinView;
@property (nonatomic, assign) CLLocationCoordinate2D lastLocation;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *searchResultTableView;
@property (nonatomic, strong) NSArray *searchResultArray;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@end

@implementation TIoTMapViewController

- (void)handleTestAction
{
//    self.mapView.mapType = self.mapView.mapType == QMapTypeStandard ? QMapTypeDark : QMapTypeStandard;

//    QMSReverseGeoCodeSearchOption *revGeoOption = [[QMSReverseGeoCodeSearchOption alloc] init];
//
//    [revGeoOption setLocationWithCenterCoordinate:CLLocationCoordinate2DMake(39.939791, 116.444579)];
//
//    [revGeoOption setGet_poi:YES];
//
//    revGeoOption.poi_options = @"radius=5000;page_size=20;page_index=1";
//
//    [self.mySearcher searchWithReverseGeoCodeSearchOption:revGeoOption];
    
    
//    CGFloat h = self.mapView.bounds.size.height - self.searchResultTableView.frame.origin.y;
//    UIEdgeInsets edge = UIEdgeInsetsMake(0, 0, h, 0);
//    CGPoint currentPos = [self.mapView convertCoordinate:_pinView.annotation.coordinate toPointToView:self.mapView];
//    CGPoint newPos = CGPointMake(self.mapView.bounds.size.width/2, (self.mapView.bounds.size.height-edge.bottom)/2);
//    CGPoint translation = CGPointMake(currentPos.x-newPos.x, currentPos.y-newPos.y);
//    CGPoint oldCenter = self.mapView.center;
//    CLLocationCoordinate2D newCenterCoordinate = [self.mapView convertPoint:CGPointMake(oldCenter.x+translation.x, oldCenter.y+translation.y) toCoordinateFromView:self.mapView];
//    [self.mapView setCenterCoordinate:newCenterCoordinate animated:YES];
}

- (NSString *)testTitle
{
    return @"";
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kTableViewHeight);

//    [self.mapView setZoomLevel:15.0];
    
    [self setupPointAnnotation];
//    [self searchCurrentLocationWithKeyword:@""];
//    [self setupSearchView];
//    [self setupKeyboardNotification];
    [self setupBottomView];
    
//    QUserLocationPresentation *presentation = [[QUserLocationPresentation alloc] init];
//    presentation.circleFillColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
//    presentation.icon = [UIImage imageNamed:@"c_color"];
//    [self.mapView configureUserLocationPresentation:presentation];
    
    //接受地图的delegate回调
//    self.mapView.showsCompass = YES;
    self.mapView.delegate = self;
    [self.mapView setUserLocationHidden:NO];
    [self.mapView setShowsUserLocation:YES];
    
//    [self setupView];
    
}

- (void)setupPointAnnotation {
    _annotation = [[QPointAnnotation alloc] init];
    NSLog(@"location----%@",self.mapView.userLocation.location);
    NSLog(@"_annotation.coordinate.latitude----%f",_annotation.coordinate.latitude);
//    _annotation.coordinate = CLLocationCoordinate2DMake(40.040219,116.273348);
    
    [self.mapView addAnnotation:_annotation];
    
}

- (void)setupBottomView {

    _searchResultTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _searchResultTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _searchResultTableView.dataSource = self;
    _searchResultTableView.delegate = self;
    _searchResultTableView.contentInset = UIEdgeInsetsMake(kTableViewHeight, 0, 0, 0);
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

}

#pragma mark - QMapViewDelegate
- (void)mapViewWillStartLocatingUser:(QMapView *)mapView
{
    NSLog(@"%s---start---->%@", __FUNCTION__,mapView.userLocation.location);
}

- (void)mapView:(QMapView *)mapView didUpdateUserLocation:(QUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    //刷新位置  如果这块不关闭的话，会一直调用这个代理函数
//    [self.mapView setShowsUserLocation:NO];
    _longitude = userLocation.location.coordinate.longitude;
    _latitude = userLocation.location.coordinate.latitude;
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(_latitude,_longitude)];
    
//    if (_userLocationAnnotation == nil) {
//        _userLocationAnnotation = [[QPointAnnotation alloc] init];
//
//        [self.mapView addAnnotation:_userLocationAnnotation];
//
//        [self.mapView setCenterCoordinate:userLocation.location.coordinate];
//    }
//
//    __weak typeof(self) weakSelf = self;
//    [UIView animateWithDuration:0.5 animations:^{
//        weakSelf.userLocationAnnotation.coordinate = userLocation.location.coordinate;
//    }];
//
//    // 更新转向
//    if (weakSelf.userLocationAnnotationView) {
//        [UIView animateWithDuration:0.1 animations:^{
//            weakSelf.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(M_PI * (userLocation.heading.trueHeading) / 180.0);
//        }];
//    }

}

- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id<QAnnotation>)annotation {
    if ([annotation isKindOfClass:[QPointAnnotation class]]) {
        
//        static NSString *userLocationAnnotationIdentifier = @"userLocationAnnotationIdentifier";
//        if (annotation == _userLocationAnnotation) {
//            _userLocationAnnotationView = (QPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:userLocationAnnotationIdentifier];
//            if (_userLocationAnnotationView == nil) {
//                _userLocationAnnotationView = [[QPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userLocationAnnotationIdentifier];
//                _userLocationAnnotationView.image = [UIImage imageNamed:@"custom_location"];
//            }
//
//            return _userLocationAnnotationView;
//        }

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
        
        // 请求当前地点.
        [self searchCurrentLocationWithKeyword:@""];
    }
    NSLog(@"----!!!___%f",mapView.centerCoordinate.longitude);
    _annotation.coordinate = mapView.centerCoordinate;
}

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
    
    // 地图移动到搜索结果的第一个位置
    if (_searchBar.text.length > 0) {
        _selectedIndex = 0;
        QMSPoiData *firstData = poiSearchResult.dataArray[0];
        _annotation.coordinate = firstData.location;
        [self.mapView setCenterCoordinate:firstData.location animated:YES];
    } else {
        _selectedIndex = -1;
    }
    
    _searchResultArray = poiSearchResult.dataArray;
    [_searchResultTableView reloadData];
}


#pragma mark - SearchBar
- (void)setupSearchView {
    
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - kTableViewHeight, [UIScreen mainScreen].bounds.size.width, kTableViewHeight)];
    _searchView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_searchView];

    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    _searchBar.showsCancelButton = YES;
    _searchBar.delegate = self;
    [_searchView addSubview:_searchBar];

    _searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, kTableViewHeight - 44) style:UITableViewStyleGrouped];
    _searchResultTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _searchResultTableView.dataSource = self;
    _searchResultTableView.delegate = self;
    _searchResultTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.01, 0.01)];
    [_searchView addSubview:_searchResultTableView];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchCurrentLocationWithKeyword:searchBar.text];
}


#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *searchCellIdentifier = @"SearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:searchCellIdentifier];
    }

    QMSPoiData *data = _searchResultArray[indexPath.row];
    cell.textLabel.text = data.title;
    cell.detailTextLabel.text = data.address;

    if (indexPath.row == _selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    _selectedIndex = indexPath.row;

    QMSPoiData *data = _searchResultArray[indexPath.row];

    // 更新位置
    [self.mapView setCenterCoordinate:data.location animated:YES];

    [self.searchResultTableView reloadData];
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

- (void)setupView {
    
    [self.headerView addSubview:self.searchView];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.headerView);
        make.height.mas_equalTo(kSearchBarHeight);
    }];
    
//    [self.view addSubview:self.tableView];
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        if (@available(iOS 11.0, *)) {
//            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
//        } else {
//            // Fallback on earlier versions
//            make.top.equalTo(self.view.mas_top).offset(64);
//        }
//        make.left.right.bottom.equalTo(self.view);
//    }];
//
//    [self.view addSubview:self.headerView];
//    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self.tableView);
//        make.height.mas_equalTo(300);
//    }];
}

#pragma mark - QMSSearchDelegate
- (void)searchWithReverseGeoCodeSearchOption:(QMSReverseGeoCodeSearchOption *)reverseGeoCodeSearchOption didReceiveResult:(QMSReverseGeoCodeSearchResult *)reverseGeoCodeSearchResult {
    NSLog(@"pois--->%@", reverseGeoCodeSearchResult);
}

- (void)searchWithSearchOption:(QMSSearchOption *)searchOption didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

//#pragma mark - TableViewDalegate and TableViewDataSource
//- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.dataArray.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    TIoTChooseLocationCell *cell = [TIoTChooseLocationCell cellWithTableView:tableView];
//    cell.cellString = self.dataArray[indexPath.row];
//    return cell;
//}

 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollOffSetY = scrollView.contentOffset.y;
    NSLog(@"scrollOffset--->%f",scrollOffSetY);

    CGFloat kTableViewHeadrHeight = kTableViewHeight;
    
    CGFloat kHeaderViewOrigionY = kTableViewHeight/2;
    CGFloat kOrigionY = - (kSearchBarHeight + KScrolledHeight);

    if (scrollOffSetY <= -kTableViewHeadrHeight) {
        self.mapView.center = CGPointMake(kScreenWidth/2, kHeaderViewOrigionY);
    }else if (scrollOffSetY >-kTableViewHeadrHeight && scrollOffSetY < kOrigionY) {

        self.mapView.center = CGPointMake(kScreenWidth/2, kHeaderViewOrigionY - (kTableViewHeadrHeight+scrollOffSetY));


    }else if (scrollOffSetY >= kOrigionY) {

        self.mapView.center = CGPointMake(kScreenWidth/2, kHeaderViewOrigionY - (kTableViewHeadrHeight+kOrigionY));


    }else if (scrollOffSetY > kOrigionY) {

        self.mapView.center = CGPointMake(kScreenWidth/2, kOrigionY);

    }
    
//    CGPoint offset = scrollView.contentOffset;
//
//    if (offset.y > 0 && self.searchResultTableView.frame.origin.y > self.mapView.bounds.size.height * 0.5) {
//        self.searchResultTableView.frame = CGRectMake(0, self.mapView.frame.size.height - kTableViewHeight - offset.y, self.mapView.bounds.size.width, self.mapView.bounds.size.height);
//    }
//    else if (offset.y < 0 && self.searchResultTableView.frame.origin.y <= self.mapView.frame.size.height - kTableViewHeight) {
//        self.searchResultTableView.frame = CGRectMake(0, self.searchResultTableView.frame.origin.y - offset.y, self.mapView.bounds.size.width, self.mapView.bounds.size.height);
//    }
//
//       [self handleTestAction];
    
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

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]initWithArray:@[@"111",@"111",@"111",@"111",@"111",@"111",@"111",@"111",@"111",@"111"]];
    }
    return _dataArray;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 300)];
        _headerView.backgroundColor = [UIColor redColor];
    }
    return _headerView;
}

//- (UIView *)searchView {
//    if (!_searchView) {
//        _searchView = [[UIView alloc]init];
//        _searchView.backgroundColor = [UIColor orangeColor];
//    }
//    return _searchView;
//}
@end
