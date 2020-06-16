//
//  WCRoomInfoVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCRoomInfoVC.h"
#import "WCAlertView.h"

static NSString *cellId = @"rc62368";
@interface WCRoomInfoVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *roomInfo;
@end

@implementation WCRoomInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
}

- (void)setupUI
{
    self.title = @"房间设置";
    
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    self.tableView.rowHeight = 60;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 60, kScreenWidth - 40, 48);
    [btn setTitle:@"删除房间" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setBackgroundColor:kMainColor];
    [btn addTarget:self action:@selector(toDeleteRoom) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
    
}

#pragma mark - request

- (void)toDeleteRoom
{
    [[QCFamilySet shared] deleteRoomWithFamilyId:self.familyId roomId:self.roomDic[@"RoomId"] success:^(id  _Nonnull responseObject) {
        [MBProgressHUD showSuccess:@"删除成功"];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}

- (void)modifyRoom:(NSString *)name
{
    [[QCFamilySet shared] modifyRoomWithFamilyId:self.familyId roomId:self.roomDic[@"RoomId"] name:name success:^(id  _Nonnull responseObject) {
        self.roomInfo = @[@{@"title":@"房间名称",@"name":name}];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.roomInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = @"房间名称";
    cell.detailTextLabel.text = self.roomInfo[indexPath.row][@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        WCAlertView *av = [[WCAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds andStyle:WCAlertViewStyleTextField];
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
