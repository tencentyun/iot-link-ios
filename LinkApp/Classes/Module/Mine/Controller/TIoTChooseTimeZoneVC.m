//
//  TIoTChooseTimeZoneVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/8/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTChooseTimeZoneVC.h"
#import "TIoTUserRegionModel.h"
#import "YYModel.h"
#import "UIBarButtonItem+CustomUI.h"

@interface TIoTChooseTimeZoneVC ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating> {
    
    UISearchController *_searchController;
    
    NSMutableArray *_results;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *sortedNameDict;
@property (nonatomic, strong) NSMutableArray *indexArray;
@end

@implementation TIoTChooseTimeZoneVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"选择时区";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"backNac" selectImage:@"backNac"];
    [self creatSubviews];
    [self requestTimeZoneList];
}

#pragma mark - private method

- (void)creatSubviews {
    _results = [NSMutableArray arrayWithCapacity:1];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.leading.equalTo(self.view);
        if (@available (iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        }else {
            make.top.equalTo(self.view);
        }
    }];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    self.automaticallyAdjustsScrollViewInsets = false;

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, _searchController.searchBar.bounds.size.height)];
    [headerView addSubview:_searchController.searchBar];
    _tableView.tableHeaderView = headerView;
}

- (void)requestTimeZoneList {
    
    /*时区列表接口 和 地区列表接口为同一个
    * RegionListCN 中文区域列表， RegionListEN 英文区域列表;
    * RegisterRegionListEN 英文注册区域列表，RegisterRegionListCN 中文注册区域列表
    */
    
    if (LanguageIsEnglish) {
        [[TIoTRequestObject shared] postWithoutToken:AppGetGlobalConfig Param:@{@"Keys":@"RegionListEN"} success:^(id responseObject) {
            TIoTUserRegionModel *userRegionModel = [TIoTUserRegionModel yy_modelWithJSON:responseObject];
            TIoTConfigModel *configModel = userRegionModel.Configs[0];
            
            [self recombinationDataWithConfigModel:configModel];
            
            [self.tableView reloadData];
            
        
        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            
        }];
    }else {
        [[TIoTRequestObject shared] postWithoutToken:AppGetGlobalConfig Param:@{@"Keys":@"RegionListCN"} success:^(id responseObject) {
            TIoTUserRegionModel *userRegionModel = [TIoTUserRegionModel yy_modelWithJSON:responseObject];
            TIoTConfigModel *configModel = userRegionModel.Configs[0];
        
            [self recombinationDataWithConfigModel:configModel];
            
            [self.tableView reloadData];

        } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
            
        }];
    }
}

//重组接口返回数据接口
- (void)recombinationDataWithConfigModel:(TIoTConfigModel *)configModel {
    
    /*
     *  创建所需原始数据    如: @["Asia/Shanghai + Beijing","Asia/Hong_Kong + Hong Kong",];
     *  timeListArray    接口请求后的json数据
     */
    
    NSMutableArray *originalArray = [[NSMutableArray alloc]init];
    NSString *separateString = @" + ";

    NSArray *timeListArray = [NSJSONSerialization JSONObjectWithData:[configModel.Value dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    [timeListArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *itemDic = [obj copy];
        [originalArray addObject:[NSString stringWithFormat:@"%@%@%@",itemDic[@"TZ"],separateString,itemDic[@"Title"]]];
    }];

    TIoTLog(@"timeListArray====%@",timeListArray);
    TIoTLog(@"originalArray===%@",originalArray);

    /*
     根据时区名称排序
     */
    NSArray *TZSortedArray = [self charactersOrder:(NSArray *)originalArray];
    TIoTLog(@"TZSortedArray==%@",TZSortedArray);

    /*
     获取第一个字母 组成目标数据格式 如:A =     (
         "Anchorage + America/Anchorage",
         "Askt + America/Anchorage",
         "EST + America/Atikokan",
         "Chicago + America/Chicago",
         "MST + America/Creston",
         "Denver + America/Denver",
         "Detroit + America/Detroit",
         "Los Angeles + America/Los_Angeles",
         "PST + America/Los_Angeles",
         "New York + America/New_York",
         "CST + America/Regina",
         "Hong Kong + Asia/Hong_Kong",
         "Macao + Asia/Macao",
         "Beijing + Asia/Shanghai",
         "Taiwan + Asia/Taipei"
     );
     P =     (
         "Hawaii + Pacific/Honolulu",
         "Honolulu + Pacific/Honolulu"
     );
     */
    
    NSMutableDictionary *TZDic = [[NSMutableDictionary alloc]init];
    
    [TZSortedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *zoneString = obj;
        NSString *firstString = [zoneString substringToIndex:1];
        NSMutableArray *TZNameArray = [TZDic objectForKey:firstString];

        NSString *TZString = [TZSortedArray[idx] componentsSeparatedByString:separateString].firstObject;
        NSString *regionString = [TZSortedArray[idx] componentsSeparatedByString:separateString].lastObject;

        if (TZNameArray) {
            [TZNameArray addObject:[NSString stringWithFormat:@"%@%@%@",regionString,separateString,TZString]];
        }else {
            [TZDic setValue:[@[[NSString stringWithFormat:@"%@%@%@",regionString,separateString,TZString]] mutableCopy] forKey:firstString];
        }
    }];

    TIoTLog(@"TZDic===%@",TZDic);

    self.sortedNameDict = [[NSDictionary alloc]initWithDictionary:TZDic];
    self.indexArray = [[NSMutableArray alloc] initWithArray:[[self.sortedNameDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }]];
}

//数组排序
- (NSArray *)charactersOrder:(NSArray*)array
{
    NSArray *stringArr = array;
    NSArray *result  = [stringArr sortedArrayUsingSelector:@selector(localizedCompare:)];
    return result;
}

- (NSString *)showTimeZoneStringIndex:(NSIndexPath *)indexPath {
    NSString *showCodeSting;
    if (_searchController.isActive) {
        if (_results.count > indexPath.row) {
            showCodeSting = [_results objectAtIndex:indexPath.row];
        }
    } else {
        if (_indexArray.count > indexPath.section) {
            NSArray *sectionArray = [_sortedNameDict valueForKey:[_indexArray objectAtIndex:indexPath.section]];
            if (sectionArray.count > indexPath.row) {
                showCodeSting = [sectionArray objectAtIndex:indexPath.row];
            }
        }
    }
    return showCodeSting;
}

- (void)selectCodeIndex:(NSIndexPath *)indexPath {
    
    NSString * originText = [self showTimeZoneStringIndex:indexPath];
    NSArray  * array = [originText componentsSeparatedByString:@" + "];
    NSString * cityName = [array.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * timeZone = array.lastObject;
    
    if (self.returnTimeZoneBlock != nil) {
        self.returnTimeZoneBlock(timeZone,cityName);
    }
    
    _searchController.active = NO;
    [_searchController.searchBar resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    WCLog(@"城市名称: %@   城市时区: %@",cityName,timeZone);
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (_results.count > 0) {
        [_results removeAllObjects];
    }
    NSString *inputText = searchController.searchBar.text;
    __weak __typeof(self)weakSelf = self;
    [_sortedNameDict.allValues enumerateObjectsUsingBlock:^(NSArray * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj containsString:inputText]) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf->_results addObject:obj];
            }
        }];
    }];
    [_tableView reloadData];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_searchController.isActive) {
        return 1;
    } else {
        return [_sortedNameDict allKeys].count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchController.isActive) {
         return [_results count];
    } else {
        if (_indexArray.count > section) {
            NSArray *array = [_sortedNameDict objectForKey:[_indexArray objectAtIndex:section]];
            return array.count;
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"identifier5555";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString *area = [self showTimeZoneStringIndex:indexPath];
    cell.textLabel.text = [area componentsSeparatedByString:@" + "].firstObject;
    cell.textLabel.textColor = kFontColor;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.text = [area componentsSeparatedByString:@" + "].lastObject;
    cell.detailTextLabel.textColor = kMainColor;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == _tableView) {
        return _indexArray;
    }else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == _tableView) {
        return index;
    } else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView) {
        return 40;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    bgview.backgroundColor = kRGBColor(247, 249, 250);
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth, 40)];
    title.textColor = kFontColor;
    title.font = [UIFont boldSystemFontOfSize:18];
    [bgview addSubview:title];
    
    if (_indexArray.count && _indexArray.count > section) {
        NSString *g = [_indexArray objectAtIndex:section];
        if (g.length > 0) {
            title.text = g;
        }
        else
        {
            title.text = @"热门国家和地区";
        }
        
    }
    
    return bgview;
}

#pragma mark - 选择国际获取代码

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectCodeIndex:indexPath];
}

#pragma mark - setter and getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 64.0;
        _tableView.backgroundColor = UIColor.clearColor;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        //修改索引条颜色
        _tableView.sectionIndexColor = [UIColor colorWithHexString:kIndexFontHexColor];//修改右边索引字体的颜色
//        _tableView.sectionIndexTrackingBackgroundColor = kMainColor;//修改右边索引点击时候的背景色
    }
    return _tableView;
}


@end
