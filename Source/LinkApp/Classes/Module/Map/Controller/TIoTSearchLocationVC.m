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

static CGFloat kSearchViewHeight = 64;   //searchView 高度

@interface TIoTSearchLocationVC ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation TIoTSearchLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    
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
    
}

#pragma mark - UITableViewDelegate And UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTChooseLocationCell  *cell = [TIoTChooseLocationCell cellWithTableView:tableView];
    return cell;
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
        
        //        UIView *line = [[UIView alloc]init];
        //        line.backgroundColor= [UIColor colorWithHexString:@"#D3D3D3"];
        //        [_searchBar addSubview:line];
        //        [line mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.centerY.equalTo(_searchBar);
        //            make.left.equalTo(_searchBar.mas_right).offset(-10);
        //            make.width.mas_equalTo(1);
        //            make.height.mas_equalTo(20);
        //        }];
        
        UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [searchBtn setBackgroundColor:[UIColor colorWithHexString:@"#F3F3F5"]];
        [searchBtn setTitle:NSLocalizedString(@"search_text", @"搜索") forState:UIControlStateNormal];
        [searchBtn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        [_searchView addSubview:searchBtn];
        [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.searchBar.mas_right).offset(-15);
            make.centerY.equalTo(_searchBar);
            make.width.mas_equalTo(65);
            make.height.mas_equalTo(36);
        }];
    }
    return _searchView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        CGFloat kWidthPadding = 16;
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(kWidthPadding, 0, kScreenWidth - kWidthPadding*6, kSearchViewHeight)];
        _searchBar.backgroundColor = [UIColor whiteColor];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.placeholder = NSLocalizedString(@"search_location", @"搜索地点");
        
        UITextField  *seachTextFild = [_searchBar valueForKey:@"searchField"];
        seachTextFild.font = [UIFont wcPfRegularFontOfSize:14];
        seachTextFild.textColor = [UIColor blackColor];
        seachTextFild.backgroundColor = [UIColor colorWithHexString:@"#F3F3F5"];
        [self.view changeViewRectConnerWithView:seachTextFild withRect:CGRectMake(0, 0, _searchBar.frame.size.width, 36) roundCorner:UIRectCornerTopLeft|UIRectCornerBottomLeft withRadius:CGSizeMake(20, 20)];
        
        
        CGFloat kSearchIconSize = 20;
        UIImageView *searchImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search_location"]];
        searchImg.frame = CGRectMake(0, 0,kSearchIconSize,kSearchIconSize);
        seachTextFild.leftView = searchImg;
        
        [_searchBar setPositionAdjustment:UIOffsetMake(10, 0) forSearchBarIcon:UISearchBarIconSearch];
        
        // 修改按钮标题文字属性( 颜色, 大小, 字体)
//        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont wcPfRegularFontOfSize:14]} forState:UIControlStateNormal];
        // 修改标题文字
//        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitle:NSLocalizedString(@"search_text", @"搜索")];
        
    }
    return _searchBar;
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
