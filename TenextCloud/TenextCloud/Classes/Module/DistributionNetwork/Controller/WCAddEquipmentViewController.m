//
//  WCAddEquipmentViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/17.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCAddEquipmentViewController.h"
#import "WCScanlViewController.h"
#import "WCDistributionNetworkViewController.h"
#import "WCMineTableViewCell.h"
#import "WCNavigationController.h"

@interface WCAddEquipmentViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArr;

@end

@implementation WCAddEquipmentViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [HXYNotice addUpdateDeviceListListener:self reaction:@selector(backHome:)];
    
    [self setupUI];
}

- (void)dealloc{
    [HXYNotice removeListener:self];
}

#pragma mark -

- (void)setupUI{
    self.title = @"添加设备";
    self.view.backgroundColor = kBgColor;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(10);
    }];
 
//    UIButton *bleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [bleBtn setTitle:@"蓝牙" forState:UIControlStateNormal];
//    [bleBtn addTarget:self action:@selector(bleClick:) forControlEvents:UIControlEventTouchUpInside];
//    bleBtn.backgroundColor = [UIColor blueColor];
//    [self.view addSubview:bleBtn];
//    [bleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(15);
//        make.top.equalTo(softapBtn.mas_bottom).offset(15);
//        make.right.equalTo(self.view).offset(-15);
//        make.height.mas_equalTo(50);
//    }];
}


#pragma mark - event

- (void)backHome:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark TableViewDelegate && TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WCMineTableViewCell *cell = [WCMineTableViewCell cellWithTableView:tableView];
    cell.isShowLine = YES;
    cell.dic = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UIViewController *vc = [[NSClassFromString(self.dataArr[indexPath.row][@"vc"]) alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        UIViewController *vc = [[NSClassFromString(self.dataArr[indexPath.row][@"vc"]) alloc] init];
        vc.title = self.dataArr[indexPath.row][@"title"];

        WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
    
}

#pragma mark setter or getter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 80;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

- (NSArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = @[
                     @{@"title":@"扫码添加",@"image":@"sweepIcon",@"vc":@"WCScanlViewController"},
                     @{@"title":@"智能配网",@"image":@"smartIcon",@"vc":@"WCDistributionNetworkViewController"},
                     @{@"title":@"自助配网",@"image":@"softAp",@"vc":@"WCDistributionNetworkViewController"},
                    
                     ];
    }
    return _dataArr;
}

@end
