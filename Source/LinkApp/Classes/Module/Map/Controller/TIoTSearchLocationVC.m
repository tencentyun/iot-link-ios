//
//  TIoTSearchLocationVC.m
//  LinkApp
//
//  Created by ccharlesren on 2021/3/6.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTSearchLocationVC.h"
#import "TIoTChooseLocationCell.h"
#import "UIView+XDPExtension.h"
#import "UIImage+Ex.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTMapLocationModel.h"
#import "TIoTAddressParseModel.h"
#import <MJRefresh.h>
#import <QMapKit/QMapKit.h>
#import "UIButton+LQRelayout.h"

static CGFloat kSearchViewHeight = 64;   //searchView 高度

@interface TIoTSearchLocationVC ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UITextField  *seachTextFild;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *histroyDataArray;
@property (nonatomic, strong) UIView *footerView;


@property (nonatomic, strong) UILabel *historyEmptyLabel;
@property (nonatomic, strong) UILabel *searchEmptyLable;

@property (nonatomic, strong) NSString *inputAddress;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, assign) CLLocationCoordinate2D addressLocation;
@end

@implementation TIoTSearchLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.inputAddress = @"";
    
    [self resetRequestPragma];
    
    [self setupUI];
    
    [self setupRefreshView];
}

- (void)setupUI {
    
    [self setDataTableViewSrouce];
    
    self.title = NSLocalizedString(@"choose_location", @"地图选点");
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view).offset(64);
        }
    }];
    
    self.historyEmptyLabel = [[UILabel alloc]init];
    [self.historyEmptyLabel setLabelFormateTitle:NSLocalizedString(@"no_search_history", @"还没有历史记录哦~") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#A1A7B2" textAlignment:NSTextAlignmentCenter];
    [self.tableView addSubview:self.historyEmptyLabel];
    [self.historyEmptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tableView);
        make.top.equalTo(self.tableView.tableHeaderView.mas_bottom).offset(50);
    }];
    self.historyEmptyLabel.hidden = YES;
    
    self.searchEmptyLable = [[UILabel alloc]init];
    [self.searchEmptyLable setLabelFormateTitle:NSLocalizedString(@"search_no_result", @"没有找到匹配结果") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#A1A7B2" textAlignment:NSTextAlignmentCenter];
    [self.tableView addSubview:self.searchEmptyLable];
    [self.searchEmptyLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tableView);
        make.top.equalTo(self.tableView.tableHeaderView.mas_bottom).offset(50);
    }];
    self.searchEmptyLable.hidden = YES;
    
    if (self.histroyDataArray.count != 0) {
        self.historyEmptyLabel.hidden = YES;
        self.tableView.tableFooterView = self.footerView;

    }else {
        self.tableView.tableFooterView = nil;
        self.historyEmptyLabel.hidden = NO;
    }
}

#pragma mark - UITableViewDelegate And UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TIoTChooseLocationCell *cell = [TIoTChooseLocationCell cellWithTableView:tableView];

//    QMSPoiData *data = _searchResultArray[indexPath.row];
    if (self.dataArray.count != 0) {
        TIoTPoisModel *cellModel = self.dataArray[indexPath.row];
        cell.locationModel = cellModel;
    }

    cell.isChoosed = NO;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTPoisModel *cellModel = self.dataArray[indexPath.row];
    if (self.chooseLocBlcok) {
        self.chooseLocBlcok(cellModel);
        NSDictionary *model = [cellModel yy_modelToJSONObject];
        [self.histroyDataArray insertObject:model atIndex:0];
        [TIoTCoreUserManage shared].searchHistoryArray = self.histroyDataArray;
        
        self.tableView.tableFooterView = self.footerView;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 获取搜索输入内容
    NSString *text = searchBar.text;
    self.inputAddress = text;
    if ([NSString isNullOrNilWithObject:text]) {
        [MBProgressHUD showError:NSLocalizedString(@"please_input_search_conent", @"请输入搜索内容")];
    }else {
        [self resetRequestPragma];
        [self getInputAddressCoordinateWithString:text];
        
        // 隐藏键盘，退出编辑
        [self hiddenKeyboard];
    }
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
//    self.clearButton.hidden = NO;
    self.historyEmptyLabel.hidden = YES;
    self.searchEmptyLable.hidden = YES;
    
    if (self.dataArray.count == 0) {
        self.historyEmptyLabel.hidden = NO;
    }
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if (searchBar.text.length == 0) {
        self.clearButton.hidden = YES;
    }else {
        self.clearButton.hidden = NO;
    }
    return YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *inputString = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    self.inputAddress = inputString;
    
    if (inputString.length == 0) {
        self.clearButton.hidden = YES;
    }else {
        self.clearButton.hidden = NO;
    }
    
    self.historyEmptyLabel.hidden = YES;
    
    if (inputString.length != 0) {
        self.tableView.tableFooterView = nil;
        NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
        if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
            if ([text isEqualToString:inputString]) {
                [self.dataArray removeAllObjects];
                [self getInputAddressCoordinateWithString:inputString];
            }
        }
    }else {
        [self setDataTableViewSrouce];
        [self.tableView reloadData];
        
        if (self.dataArray.count != 0) {
            self.tableView.tableFooterView = self.footerView;
            self.searchEmptyLable.hidden = YES;
        }else {
            self.tableView.tableFooterView = nil;
            self.searchEmptyLable.hidden = YES;
            self.historyEmptyLabel.hidden = NO;
        }
    }
    
    return YES;
}

#pragma mark - Network Request
- (void)getInputAddressCoordinateWithString:(NSString *)addressString
{
    
    TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];

    NSString *urlString = [NSString stringWithFormat:@"%@%@&key=%@",MapSDKAddressParseURL,addressString?:@"",model.TencentMapSDKValue];

    NSString *urlEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    [[TIoTRequestObject shared] get:urlEncoded isNormalRequest:YES success:^(id responseObject) {
        TIoTAddressParseModel *addressModel = [TIoTAddressParseModel yy_modelWithJSON:responseObject[@"result"]];
        
        self.addressLocation = CLLocationCoordinate2DMake(addressModel.location.lat,addressModel.location.lng);

        //刷新地点列表
        [self resetRequestPragma];
        [self requestLocationList:self.addressLocation];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
    }];
}

- (void)loadMoreData {
    
    [self requestLocationList:self.addressLocation];
}

- (void)requestLocationList:(CLLocationCoordinate2D )location {
    
    
    TIoTAppConfigModel *model = [TIoTAppConfig loadLocalConfigList];
    
    NSString *locationString = [NSString stringWithFormat:@"%f,%f",location.latitude,location.longitude];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@&get_poi=1&key=%@&poi_options=address_format=short;page_size=%ld;page_index=%ld",MapSDKLocationParseURL,locationString,model.TencentMapSDKValue,(long)self.offset,(long)self.pageNumber];
    [[TIoTRequestObject shared] get:urlString isNormalRequest:YES success:^(id responseObject) {
        TIoTMapLocationModel *locationModel = [TIoTMapLocationModel yy_modelWithJSON:responseObject[@"result"]];
        
        [self endRefresh:YES total:[locationModel.poi_count integerValue]];
        [self.dataArray addObjectsFromArray:locationModel.pois];
        
        if (self.inputAddress.length == 0) {
            self.historyEmptyLabel.hidden = NO;
            self.searchEmptyLable.hidden = YES;
            
        }else {
            if (self.dataArray.count == 0) {
                self.searchEmptyLable.hidden = NO;
            }else {
                self.searchEmptyLable.hidden = YES;
            }
            self.historyEmptyLabel.hidden = YES;
        }
        
        [self.tableView reloadData];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - custom method
- (void)resetRequestPragma {
    self.offset = 20;
    self.pageNumber = 1;
    if (self.dataArray.count != 0) {
        [self.dataArray removeAllObjects];
    }
}

- (void)setDataTableViewSrouce {
    
    if (self.dataArray.count != 0) {
        [self.dataArray removeAllObjects];
    }
    
    if (self.histroyDataArray.count != 0 && self.histroyDataArray != nil) {
        for (NSDictionary *dic in self.histroyDataArray) {
            TIoTPoisModel *model = [TIoTPoisModel yy_modelWithJSON:dic];
            [self.dataArray addObject:model];
        }
    }
}

- (void)setupRefreshView
{
    // 下拉刷新
    WeakObj(self)
//    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{

//    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [selfWeak loadMoreData];
    }];

}

- (void)endRefresh:(BOOL)isFooter total:(NSInteger)total {
    
    self.pageNumber += 1;
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

- (void)hiddenKeyboard {
    [self.view endEditing:YES];
}

- (void)searchLocationList {
    [self searchBarSearchButtonClicked:self.searchBar];
}

- (void)clearInputContent {
    
    self.seachTextFild.text = @"";
    
    [self hiddenKeyboard];
    
    [self setDataTableViewSrouce];
    [self.tableView reloadData];
    
    if (self.dataArray.count == 0) {
        self.historyEmptyLabel.hidden = NO;
        self.tableView.tableFooterView = nil;
        self.searchEmptyLable.hidden = YES;
    }else {
        self.historyEmptyLabel.hidden = YES;
        self.tableView.tableFooterView = self.footerView;
        self.searchEmptyLable.hidden = YES;
    }
}

- (void)clearHistoryData {
    
    [self.dataArray removeAllObjects];
    [self.histroyDataArray removeAllObjects];
    [self.tableView reloadData];
    self.tableView.tableFooterView = nil;
    [TIoTCoreUserManage shared].searchHistoryArray = [NSMutableArray new];
    
    self.historyEmptyLabel.hidden = NO;
}

#pragma mark - lazy loading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 75;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.searchView;
    }
    return _tableView;
}

- (UIView *)searchView {
    if (!_searchView) {
        _searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kSearchViewHeight)];
        _searchView.backgroundColor = [UIColor whiteColor];
        [_searchView addSubview:self.searchBar];
        
        CGFloat kClearImageSize = 18;
        CGFloat kSearchBarHeight = 36;
        
        NSString *kBackColorString = @"#f2f2f3";
        if (@available (iOS 13.0,*)) {
            kBackColorString = @"#eeeeef";
        }
        
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchButton setBackgroundColor:[UIColor colorWithHexString:kBackColorString]];
        [searchButton setTitle:NSLocalizedString(@"search_text", @"搜索") forState:UIControlStateNormal];
        [searchButton setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(searchLocationList) forControlEvents:UIControlEventTouchUpInside];
        searchButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_searchView addSubview:searchButton];
        [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.searchBar.mas_right).offset(3);
            make.centerY.equalTo(self.searchBar);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(kSearchBarHeight);
        }];

        [_searchView changeViewRectConnerWithView:searchButton withRect:CGRectMake(0, 0, 60, kSearchBarHeight) roundCorner:UIRectCornerTopRight|UIRectCornerBottomRight withRadius:CGSizeMake(12, 12)];
        
        
        UIView *clearView = [[UIView alloc]init];
        clearView.backgroundColor = [UIColor colorWithHexString:kBackColorString];
        [self.searchBar addSubview:clearView];
        [clearView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.searchBar);
            make.width.mas_equalTo(kClearImageSize+5);
            make.height.mas_equalTo(kSearchBarHeight);
            make.right.equalTo(self.searchBar.mas_right);
        }];
        
        self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.clearButton setImage:[UIImage imageNamed:@"search_clearBtn"] forState:UIControlStateNormal];
        [self.clearButton addTarget:self action:@selector(clearInputContent) forControlEvents:UIControlEventTouchUpInside];
        [clearView addSubview:self.clearButton];
        [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(clearView);
            make.left.equalTo(clearView);
            make.width.height.mas_equalTo(kClearImageSize);
        }];
        
        self.clearButton.hidden = YES;
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor colorWithHexString:kBackColorString];
        [_searchView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(clearView.mas_right);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(kSearchBarHeight);
            make.centerY.equalTo(self.searchBar);
        }];
        
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [UIColor colorWithHexString:@"#D3D3D3"];
        [lineView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lineView.mas_left).offset(6);
            make.width.mas_equalTo(1);
            make.height.mas_equalTo(20);
            make.centerY.equalTo(lineView);
        }];
        
    }
    return _searchView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        
        CGFloat kWidthPadding = 16;
        CGFloat kTextFieldOffsetValue = 40;

        if (@available (iOS 13.0,*)) {
            kTextFieldOffsetValue = 20;
            
            _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(kWidthPadding, 0, kScreenWidth - kWidthPadding*6, kSearchViewHeight)];
        }else {
            _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(-25, 0, kScreenWidth- kWidthPadding*3-10, kSearchViewHeight)];
        }
        
        _searchBar.backgroundColor = [UIColor whiteColor];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search_location", @"搜索地点");
        
        self.seachTextFild = [_searchBar valueForKey:@"searchField"];
        self.seachTextFild.font = [UIFont wcPfRegularFontOfSize:14];
        self.seachTextFild.textColor = [UIColor blackColor];
        self.seachTextFild.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        [_searchBar changeViewRectConnerWithView:self.seachTextFild withRect:CGRectMake(0, 0, _searchBar.frame.size.width, 36) roundCorner:UIRectCornerTopLeft|UIRectCornerBottomLeft withRadius:CGSizeMake(20, 20)];
        
        
        _searchBar.searchTextPositionAdjustment = UIOffsetMake(kTextFieldOffsetValue, 0);
        _searchBar.searchFieldBackgroundPositionAdjustment = UIOffsetMake(kTextFieldOffsetValue, 0);

        UIImageView *searchIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search_location"]];
        [self.seachTextFild addSubview:searchIcon];
        [searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.seachTextFild.mas_left).offset(18);
            make.centerY.equalTo(self.seachTextFild);
            make.width.height.mas_equalTo(20);
        }];
    
        self.seachTextFild.leftViewMode = UITextFieldViewModeNever;
        self.seachTextFild.clearButtonMode = UITextFieldViewModeNever;
        
    }
    return _searchBar;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (NSMutableArray *)histroyDataArray {
    if (!_histroyDataArray) {
        
        if (!([TIoTCoreUserManage shared].searchHistoryArray == nil || [TIoTCoreUserManage shared].searchHistoryArray.count == 0)) {
            _histroyDataArray = [NSMutableArray arrayWithArray:[TIoTCoreUserManage shared].searchHistoryArray];
        }else {
            _histroyDataArray = [NSMutableArray new];
        }
    }
    return _histroyDataArray;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
        _footerView.backgroundColor = [UIColor whiteColor];
        
        UIButton *clearHistoryBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [clearHistoryBtn addTarget:self action:@selector(clearHistoryData) forControlEvents:UIControlEventTouchUpInside];
        [clearHistoryBtn setButtonFormateWithTitlt:NSLocalizedString(@"clear_history", @"清空历史记录") titleColorHexString:@"#6C7078" font:[UIFont wcPfRegularFontOfSize:14]];
        clearHistoryBtn.layer.borderColor = [UIColor colorWithHexString:@"#E7E8EB"].CGColor;
        clearHistoryBtn.layer.borderWidth = 1;
        clearHistoryBtn.layer.cornerRadius = 18;
        [_footerView addSubview:clearHistoryBtn];
        [clearHistoryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_footerView);
            make.width.mas_equalTo(140);
            make.height.mas_equalTo(36);
        }];
    }
    return _footerView;
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
