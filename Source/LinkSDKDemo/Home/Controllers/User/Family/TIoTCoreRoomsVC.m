//
//  WCRoomsVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTCoreRoomsVC.h"
#import "TIoTCoreAddRoomVC.h"
#import "TIoTCoreRoomInfoVC.h"

static NSString *cellId = @"wd9765";
@interface TIoTCoreRoomsVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *rooms;

@end

@implementation TIoTCoreRoomsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    [self getRoomList];
}

- (void)setupUI
{
    self.title = NSLocalizedString(@"room_manager", @"房间管理");
    
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    self.tableView.rowHeight = 60;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 60, kScreenWidth - 40, 48);
    [btn setTitle:NSLocalizedString(@"add_room", @"添加房间") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
    [btn addTarget:self action:@selector(toAddRoom) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4;
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
    
}

- (void)getRoomList
{
    [[TIoTCoreFamilySet shared] getRoomListWithFamilyId:self.familyId offset:0 limit:0 success:^(id  _Nonnull responseObject) {
        [self.rooms removeAllObjects];
        [self.rooms addObjectsFromArray:responseObject[@"RoomList"]];
        [self.tableView reloadData];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        
    }];
}


- (void)toAddRoom
{
    TIoTCoreAddRoomVC *vc = [TIoTCoreAddRoomVC new];
    vc.familyId = self.familyId;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = self.rooms[indexPath.row][@"RoomName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@个设备",self.rooms[indexPath.row][@"DeviceNum"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIoTCoreRoomInfoVC *vc = [TIoTCoreRoomInfoVC new];
    vc.familyId = self.familyId;
    vc.roomDic = self.rooms[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - getter

- (NSMutableArray *)rooms
{
    if (!_rooms) {
        _rooms = [NSMutableArray array];
    }
    return _rooms;
}

@end
