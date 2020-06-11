//
//  WCDeviceShareVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTDeviceShareVC.h"
#import "TIoTUserCell.h"
#import "TIoTInvitationVC.h"

static NSString *cellId = @"sd0679";
@interface TIoTDeviceShareVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *userList;

@end

@implementation TIoTDeviceShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    [self queryDeviceUserList];
}

- (void)setupUI
{
    self.title = @"设备分享";
    [self.tableView registerNib:[UINib nibWithNibName:@"TIoTUserCell" bundle:nil] forCellReuseIdentifier:cellId];
    
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth - 40, 60)];
    lab.textColor = kFontColor;
    lab.font = [UIFont systemFontOfSize:14];
    lab.text = @"设备已经单独分享给以下用户";
    [header addSubview:lab];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 59, kScreenWidth - 40, 1)];
    line.backgroundColor = kLineColor;
    [header addSubview:line];
    self.tableView.tableHeaderView = header;
    
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(20, 0, kScreenWidth - 40, 1)];
    line2.backgroundColor = kLineColor;
    [footer addSubview:line2];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 40, kScreenWidth - 40, 48);
    [btn setTitle:@"添加分享" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setBackgroundColor:kMainColor];
    [btn addTarget:self action:@selector(toShare) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4;
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
}


#pragma mark - event

- (void)toShare
{
    TIoTInvitationVC *vc = [TIoTInvitationVC new];
    vc.title = @"分享用户";
    vc.familyId = self.deviceDic[@"FamilyId"];
    vc.productId = self.deviceDic[@"ProductId"];
    vc.deviceName = self.deviceDic[@"DeviceName"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIoTUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    [cell setInfo:self.userList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self removeShareDeviceUser:indexPath.row];
    }
}

// 修改编辑按钮文字

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}


#pragma mark - request

- (void)queryDeviceUserList
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:self.deviceDic[@"ProductId"] forKey:@"ProductId"];
    [param setValue:self.deviceDic[@"DeviceName"] forKey:@"DeviceName"];
//    [param setValue:@"" forKey:@"Offset"];
//    [param setValue:@"" forKey:@"Limit"];
    [[TIoTRequestObject shared] post:AppListShareDeviceUsers Param:param success:^(id responseObject) {
        [self.userList removeAllObjects];
        [self.userList addObjectsFromArray:responseObject[@"Users"]];
        [self refreshUI:responseObject];
    } failure:^(NSString *reason, NSError *error) {
        
    }];
}



- (void)removeShareDeviceUser:(NSUInteger)index
{
    NSString *userId = self.userList[index][@"UserID"];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:userId forKey:@"RemoveUserID"];
    [param setValue:self.deviceDic[@"ProductId"] forKey:@"ProductId"];
    [param setValue:self.deviceDic[@"DeviceName"] forKey:@"DeviceName"];
    [[TIoTRequestObject shared] post:AppRemoveShareDeviceUser Param:param success:^(id responseObject) {
        [MBProgressHUD showSuccess:@"删除成功"];
        [self.userList removeObjectAtIndex:index];
        [self.tableView reloadData];
    } failure:^(NSString *reason, NSError *error) {
        
    }];
}

#pragma mark - other

- (void)refreshUI:(NSDictionary *)data{
    
    if ([data[@"Users"] count] == 0) {
        
        [MBProgressHUD dismissInView:self.view];
        
        [self.tableView showEmpty:@"添加分享" desc:@"暂未分享设备,点击任意处进行分享" image:[UIImage imageNamed:@"noShare"] block:^{
            [self toShare];
        }];
        
        [self.tableView reloadData];
    }
    else{
        [self.tableView hideStatus];
        [self.tableView reloadData];
    }
}

#pragma mark - getter

- (NSMutableArray *)userList
{
    if (!_userList) {
        _userList = [NSMutableArray array];
    }
    return _userList;
}

@end
