//
//  UsersOfDeviceVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/18.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "UsersOfDeviceVC.h"

@interface UsersOfDeviceVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *table;
@property (nonatomic,strong) NSArray *datas;

@end

@implementation UsersOfDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"用户列表";
    self.view.backgroundColor = kBgColor;
    [self.view addSubview:self.table];
    
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(add)];
    self.navigationItem.rightBarButtonItem = item;
    
    
    
    [[QCDeviceSet shared] getUserListForDeviceWithProductId:self.deviceInfo[@"ProductId"] deviceName:self.deviceInfo[@"DeviceName"] offset:0 limit:0 success:^(id  _Nonnull responseObject) {

        self.datas = responseObject[@"Users"];
        [self.table reloadData];

    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {

    }];
    
}

#pragma mark -

- (void)add
{
    UIViewController *vc = [NSClassFromString(@"InviteVC") new];
    [vc setValue:@"设备分享" forKey:@"title"];
    [vc setValue:self.deviceInfo[@"FamilyId"] forKey:@"familyId"];
    [vc setValue:self.deviceInfo[@"ProductId"] forKey:@"productId"];
    [vc setValue:self.deviceInfo[@"DeviceName"] forKey:@"deviceName"];
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.datas) return self.datas.count;
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lula"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"lula"];
    }
    
    cell.textLabel.text = self.datas[indexPath.row][@"NickName"];
    
    return cell;
}



#pragma mark -

- (UITableView *)table
{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-60) style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        
    }
    return _table;
}

@end
