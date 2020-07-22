//
//  WCModifyRoomVC.m
//  TenextCloud
//
//  Created by Wp on 2020/3/11.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTModifyRoomVC.h"
#import "TIoTChoseValueTableViewCell.h"

@interface TIoTModifyRoomVC ()
@property (nonatomic,strong) NSArray *rooms;
@property (nonatomic,copy) NSString *currentRoomId;
@end

@implementation TIoTModifyRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"更换房间";
    self.currentRoomId = self.deviceInfo[@"RoomId"];
    self.tableView.rowHeight = 60;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addTableFooterView];
    [self getRoomList];
}


- (void)addTableFooterView
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 60, kScreenWidth - 40, 48);
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setBackgroundColor:kMainColor];
    [btn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4;
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
}

- (void)getRoomList
{
    [[TIoTRequestObject shared] post:AppGetRoomList Param:@{@"FamilyId":self.deviceInfo[@"FamilyId"]} success:^(id responseObject) {
        self.rooms = responseObject[@"RoomList"];
        [self refreshUI:self.rooms.count];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)refreshUI:(NSInteger)count{
    
    if (count == 0) {
        
        [MBProgressHUD dismissInView:self.view];
        
        [self.tableView showEmpty:@"" desc:@"没有可选的房间" image:[UIImage imageNamed:@"noDevice"] block:^{
            
        }];
        
        [self.tableView reloadData];
    }
    else{
        [self.tableView hideStatus];
        [self.tableView reloadData];
    }
}

- (void)save
{
    
    [[TIoTRequestObject shared] post:AppModifyFamilyDeviceRoom Param:@{@"ProductId":self.deviceInfo[@"ProductId"],@"DeviceName":self.deviceInfo[@"DeviceName"],@"FamilyId": self.deviceInfo[@"FamilyId"],@"RoomId":self.currentRoomId} success:^(id responseObject) {
        [MBProgressHUD showSuccess:@"保存成功"];
        [HXYNotice addUpdateDeviceListPost];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}


#pragma mark - Tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rooms.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TIoTChoseValueTableViewCell *cell = [TIoTChoseValueTableViewCell cellWithTableView:tableView];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    BOOL select = [self.currentRoomId isEqualToString:self.rooms[indexPath.row][@"RoomId"]];
    [cell setTitle:self.rooms[indexPath.row][@"RoomName"] andSelect:select];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentRoomId = self.rooms[indexPath.row][@"RoomId"];
    [tableView reloadData];
}

@end
