//
//  WCRoomsVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTRoomsVC.h"
#import "TIoTRoomCell.h"
#import "TIoTAddRoomVC.h"
#import "TIoTNavigationController.h"
#import "TIoTRoomInfoVC.h"

static NSString *cellId = @"wd9765";
@interface TIoTRoomsVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *rooms;

@end

@implementation TIoTRoomsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [HXYNotice addUpdateRoomListListener:self reaction:@selector(getRoomList)];
    
    [self setupUI];
    [self getRoomList];
}

- (void)setupUI
{
    self.title = @"房间管理";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TIoTRoomCell" bundle:nil] forCellReuseIdentifier:cellId];
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    self.tableView.rowHeight = 60;
    
    
    if (_isOwner) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 60, kScreenWidth - 40, 48);
        [btn setTitle:@"添加房间" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:20];
        [btn setBackgroundColor:kMainColor];
        [btn addTarget:self action:@selector(toAddRoom) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4;
        [footer addSubview:btn];
        self.tableView.tableFooterView = footer;
    }
}

- (void)getRoomList
{
    NSDictionary *param = @{@"FamilyId":self.familyId,@"Offset":@(0),@"Limit":@(40)};
    [[TIoTRequestObject shared] post:AppGetRoomList Param:param success:^(id responseObject) {
        [self.rooms removeAllObjects];
        [self.rooms addObjectsFromArray:responseObject[@"RoomList"]];
        [self refreshUI:responseObject];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}


- (void)refreshUI:(NSDictionary *)data{
    
    if ([data[@"Total"] integerValue] == 0) {
        
        [MBProgressHUD dismissInView:self.view];
        [self.tableView showEmpty:@"添加房间" desc:@"当前暂无房间" image:[UIImage imageNamed:@"noDevice"] block:^{
            [self toAddRoom];
        }];
        
        [self.tableView reloadData];
    }
    else{
        [self.tableView hideStatus];
        [self.tableView reloadData];
    }
}

- (void)toAddRoom
{
    TIoTAddRoomVC *vc = [TIoTAddRoomVC new];
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
    TIoTRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    [cell setInfo:self.rooms[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isOwner) {
        TIoTRoomInfoVC *vc = [TIoTRoomInfoVC new];
        vc.familyId = self.familyId;
        vc.roomDic = self.rooms[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
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
