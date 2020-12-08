//
//  WCRoomsVC.m
//  TenextCloud
//
//  Created by Wp on 2019/12/30.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTRoomsVC.h"
#import "TIoTRoomCell.h"
#import "TIoTNavigationController.h"
#import "TIoTRoomInfoVC.h"
#import "UIButton+LQRelayout.h"
<<<<<<< Updated upstream
=======
#import "TIoTModifyNameVC.h"
>>>>>>> Stashed changes

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
    self.title = NSLocalizedString(@"room_manager", @"房间管理");
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TIoTRoomCell" bundle:nil] forCellReuseIdentifier:cellId];
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    self.tableView.rowHeight = 48;
    
    
    if (_isOwner) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 24, kScreenWidth - 40, 48);
        [btn setTitle:NSLocalizedString(@"add_room", @"添加房间") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
        [btn setImage:[UIImage imageNamed:@"share_device"] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor whiteColor]];
        [btn relayoutButton:XDPButtonLayoutStyleLeft];
        [btn addTarget:self action:@selector(toAddRoom) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 20;
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
        if (self.rooms.count == 0) {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            self.tableView.scrollEnabled = NO;
        }else {
            self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
            self.tableView.scrollEnabled = YES;
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}


- (void)refreshUI:(NSDictionary *)data{
    
    if ([data[@"Total"] integerValue] == 0) {
        
        [MBProgressHUD dismissInView:self.view];
        [self.tableView showEmpty:NSLocalizedString(@"add_room", @"添加房间") desc:NSLocalizedString(@"now_noRoom", @"当前暂无房间") image:[UIImage imageNamed:@"noDevice"] block:^{
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
   
    TIoTModifyNameVC *modifyNameVC = [[TIoTModifyNameVC alloc]init];
    modifyNameVC.titleText = NSLocalizedString(@"room_name_tip", @"房间名称");
    modifyNameVC.defaultText = @"";
    modifyNameVC.modifyType = ModifyTypeAddRoom;
    modifyNameVC.familyId = self.familyId;
    modifyNameVC.title = NSLocalizedString(@"add_room", @"添加房间");
    modifyNameVC.addRoomBlock = ^(NSDictionary * _Nonnull roomDic) {
        [self.rooms addObject:roomDic];
    };
    [self.navigationController pushViewController:modifyNameVC animated:YES];
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
