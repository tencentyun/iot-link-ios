//
//  XWCountryCodeController.m
//  XWCountryCodeDemo
//
//  Created by 邱学伟 on 16/4/19.
//  Copyright © 2016年 邱学伟. All rights reserved.
//

#import "XWCountryCodeController.h"
#import "UIBarButtonItem+CustomUI.h"

//判断系统语言
#define CURR_LANG ([[NSLocale preferredLanguages] objectAtIndex:0])
#define LanguageIsEnglish ([CURR_LANG isEqualToString:@"en-US"] || [CURR_LANG isEqualToString:@"en-CA"] || [CURR_LANG isEqualToString:@"en-GB"] || [CURR_LANG isEqualToString:@"en-CN"] || [CURR_LANG isEqualToString:@"en"])

@interface XWCountryCodeController () <UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating> {
    UITableView *_tableView;
    UISearchController *_searchController;
    NSDictionary *_sortedNameDict;
    NSMutableArray *_indexArray;
    NSMutableArray *_results;
}
@end

@implementation XWCountryCodeController

#pragma mark - system
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"country_code", @"选择国家和地区");
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"backNac" selectImage:@"backNac"];
    [self creatSubviews];
}

#pragma mark - private
 //创建子视图
- (void)creatSubviews{
    _results = [NSMutableArray arrayWithCapacity:1];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - kXDPNavigationBarHeight) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 64.0;
    _tableView.backgroundColor = UIColor.clearColor;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //修改索引条颜色
    _tableView.sectionIndexColor = kFontColor;//修改右边索引字体的颜色
    _tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];//修改右边索引点击时候的背景色
    
//    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
//    _searchController.searchResultsUpdater = self;
//    _searchController.dimsBackgroundDuringPresentation = NO;
//    self.definesPresentationContext = YES;
//    self.automaticallyAdjustsScrollViewInsets = false;
//
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, _searchController.searchBar.bounds.size.height)];
//    [headerView addSubview:_searchController.searchBar];
//    _tableView.tableHeaderView = headerView;
    
    //判断当前系统语言
    if (LanguageIsEnglish) {
        NSString *plistPathEN = [[NSBundle mainBundle] pathForResource:@"sortedNameEN" ofType:@"plist"];
        _sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathEN];
    } else {
        NSString *plistPathCH = [[NSBundle mainBundle] pathForResource:@"sortedNameCH" ofType:@"plist"];
        _sortedNameDict = [[NSDictionary alloc] initWithContentsOfFile:plistPathCH];
    }
    
    _indexArray = [[NSMutableArray alloc] initWithArray:[[_sortedNameDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }]];
    
//    _indexArray[0] = @"热门国家和地区";
}

- (NSString *)showCodeStringIndex:(NSIndexPath *)indexPath {
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
    
    NSString * originText = [self showCodeStringIndex:indexPath];
    NSArray  * array = [originText componentsSeparatedByString:@"+"];
    NSString * countryName = [array.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * code = array.lastObject;
    
    if (self.deleagete && [self.deleagete respondsToSelector:@selector(returnCountryName:code:)]) {
        [self.deleagete returnCountryName:countryName code:code];
    }
    
    if (self.returnCountryCodeBlock != nil) {
        self.returnCountryCodeBlock(countryName,code);
    }
    
    _searchController.active = NO;
    [_searchController.searchBar resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    WCLog(@"选择国家: %@   代码: %@",countryName,code);
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
    NSString *area = [self showCodeStringIndex:indexPath];
    cell.textLabel.text = [area componentsSeparatedByString:@" "].firstObject;
    cell.textLabel.textColor = kFontColor;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.text = [area componentsSeparatedByString:@" "].lastObject;
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (_indexArray.count && _indexArray.count > section) {
//        NSString *g = [_indexArray objectAtIndex:section];
//        if (g.length > 0) {
//            return g;
//        }
//        return @"热门国家和地区";
//    }
//    return nil;
//}

#pragma mark - 选择国际获取代码
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectCodeIndex:indexPath];
}

@end
