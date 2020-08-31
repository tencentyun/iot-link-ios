//
//  WCRoomInfoVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTRoomInfoVC.h"
#import "TIoTRoomCell.h"

static NSString *cellId = @"rc62368";
@interface TIoTRoomInfoVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *roomInfo;
@end

@implementation TIoTRoomInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
}

- (void)setupUI
{
    self.title = @"房间设置";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TIoTRoomCell" bundle:nil] forCellReuseIdentifier:cellId];
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    self.tableView.rowHeight = 60;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 60, kScreenWidth - 40, 48);
    [btn setTitle:@"删除房间" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setBackgroundColor:kWarnColor];
    [btn addTarget:self action:@selector(toDeleteRoom) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 4;
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
    
}

#pragma mark - request

- (void)toDeleteRoom
{
    NSDictionary *param = @{@"FamilyId":self.familyId,@"RoomId":self.roomDic[@"RoomId"]};
    [[TIoTRequestObject shared] post:AppDeleteRoom Param:param success:^(id responseObject) {
        [HXYNotice addUpdateRoomListPost];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

- (void)modifyRoom:(NSString *)name
{
    NSDictionary *param = @{@"FamilyId":self.familyId,@"RoomId":self.roomDic[@"RoomId"],@"Name":name};
    [[TIoTRequestObject shared] post:AppModifyRoom Param:param success:^(id responseObject) {
        
        [HXYNotice addUpdateRoomListPost];
        
        self.roomInfo = @[@{@"title":@"房间名称",@"name":name}];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.roomInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIoTRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    [cell setInfo2:self.roomInfo[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        TIoTAlertView *av = [[TIoTAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleTextField];
        [av alertWithTitle:@"房间名称" message:@"20字以内" cancleTitlt:@"取消" doneTitle:@"确认"];
        av.maxLength = 20;
        av.doneAction = ^(NSString * _Nonnull text) {
            if (text.length > 0) {
                [self modifyRoom:text];
            }
        };
        [av showInView:[UIApplication sharedApplication].keyWindow];
    }
}

#pragma mark - getter

- (NSArray *)roomInfo
{
    if (!_roomInfo) {
        _roomInfo = @[@{@"title":@"房间名称",@"name":self.roomDic[@"RoomName"]}];
    }
    return _roomInfo;
}
@end
