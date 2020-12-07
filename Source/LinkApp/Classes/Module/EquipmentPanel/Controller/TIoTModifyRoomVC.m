//
//  WCModifyRoomVC.m
//  TenextCloud
//
//  Created by Wp on 2020/3/11.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTModifyRoomVC.h"
#import "TIoTChoseValueTableViewCell.h"
#import "TIoTSingleCustomButton.h"

@interface TIoTModifyRoomVC ()
@property (nonatomic,strong) NSArray *rooms;
@property (nonatomic,copy) NSString *currentRoomId;
@end

@implementation TIoTModifyRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"select_room", @"选择房间");
    self.currentRoomId = self.deviceInfo[@"RoomId"];
    self.tableView.rowHeight = 60;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addTableFooterView];
    [self getRoomList];
}


- (void)addTableFooterView
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    
    CGFloat kLeftPadding = 20;
    
    __weak typeof(self)weakSelf = self;
    TIoTSingleCustomButton *saveButton = [[TIoTSingleCustomButton alloc]initWithFrame:CGRectMake(kLeftPadding, 60, kScreenWidth - kLeftPadding*2, 40)];
    saveButton.kLeftRightPadding = kLeftPadding;
    [saveButton singleCustomButtonStyle:SingleCustomButtonConfirm withTitle:NSLocalizedString(@"save", @"保存")];
    saveButton.singleAction = ^{
        
        [[TIoTRequestObject shared] post:AppModifyFamilyDeviceRoom Param:@{@"ProductId":weakSelf.deviceInfo[@"ProductId"],@"DeviceName":weakSelf.deviceInfo[@"DeviceName"],@"FamilyId": weakSelf.deviceInfo[@"FamilyId"],@"RoomId":weakSelf.currentRoomId} success:^(id responseObject) {
            [MBProgressHUD showSuccess:NSLocalizedString(@"save_success", @"保存成功")];
            [TIoTCoreUserManage shared].currentRoomId = weakSelf.currentRoomId;
            [HXYNotice addUpdateDeviceListPost];
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
        }];
    };
    [footer addSubview:saveButton];
    
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
        
        [self.tableView showEmpty:@"" desc:NSLocalizedString(@"no_room", @"没有可选的房间") image:[UIImage imageNamed:@"noDevice"] block:^{
            
        }];
        
        [self.tableView reloadData];
    }
    else{
        [self.tableView hideStatus];
        [self.tableView reloadData];
    }
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
