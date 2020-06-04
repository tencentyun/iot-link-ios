//
//  WCDeviceDetailVC.m
//  TenextCloud
//
//  Created by Wp on 2020/4/13.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCDeviceDetailVC.h"
#import "WCDeviceDetailTableViewCell.h"

@interface WCDeviceDetailVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation WCDeviceDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设备信息";
    self.view.backgroundColor = kBgColor;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - TableViewDelegate && TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self dataArr].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WCDeviceDetailTableViewCell *cell = [WCDeviceDetailTableViewCell cellWithTableView:tableView];
    cell.dic = [self dataArr][indexPath.row];
    return cell;
}

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":@"厂家名称",@"value":@"-",@"needArrow":@"0"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":@"产品型号",@"value":@"-",@"needArrow":@"0"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":@"MAC地址",@"value":@"-",@"needArrow":@"0"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":@"IP地址",@"value":@"-",@"needArrow":@"0"}]];
        [_dataArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"title":@"固件版本",@"value":@"-",@"needArrow":@"0"}]];
    }
    return _dataArr;
}

@end
