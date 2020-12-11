//
//  WCRoomInfoVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTRoomInfoVC.h"
#import "TIoTRoomCell.h"
#import "TIoTSingleCustomButton.h"
#import "TIoTModifyNameVC.h"
#import "TIoTAlertView.h"

static NSString *cellId = @"rc62368";
@interface TIoTRoomInfoVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *roomInfo;
@property (nonatomic, strong) UIView *backMaskView;

@end

@implementation TIoTRoomInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
}

- (void)setupUI
{
    self.title = NSLocalizedString(@"room_setting", @"房间设置");
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.tableView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TIoTRoomCell" bundle:nil] forCellReuseIdentifier:cellId];
    self.tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    self.tableView.rowHeight = 48;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
    
    __weak typeof(self)weakSelf = self;
    TIoTSingleCustomButton *deleteRoomButton = [[TIoTSingleCustomButton alloc]initWithFrame:CGRectMake(20, 24, kScreenWidth - 40, 40)];
    deleteRoomButton.kLeftRightPadding = 20;
    [deleteRoomButton singleCustomButtonStyle:SingleCustomButtonCenale withTitle:NSLocalizedString(@"delete_room", @"删除房间")];
    deleteRoomButton.singleAction = ^{
        
        TIoTAlertView *deleteRoomAlert = [[TIoTAlertView alloc]initWithFrame:[UIScreen mainScreen].bounds withTopImage:nil];
        
        [deleteRoomAlert alertWithTitle:NSLocalizedString(@"sure_delete_room", @"确定删除该房间?")  message:@"" cancleTitlt:NSLocalizedString(@"cancel", @"取消") doneTitle:NSLocalizedString(@"delete", @"删除")];
        deleteRoomAlert.doneAction = ^(NSString * _Nonnull text) {
            [weakSelf toDeleteRoom];
        };
        
        self.backMaskView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].delegate.window.frame];
        [[UIApplication sharedApplication].delegate.window addSubview:self.backMaskView];
        [deleteRoomAlert showInView:self.backMaskView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideAlertView)];
        [self.backMaskView addGestureRecognizer:tap];
        
    };
    
    [footer addSubview:deleteRoomButton];
    self.tableView.tableFooterView = footer;
    
}

- (void)hideAlertView {
    [self.backMaskView removeFromSuperview];
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
        
        self.roomInfo = @[@{@"title":NSLocalizedString(@"room_name_tip", @"房间名称"),@"name":name}];
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
        
        NSDictionary *nameDic = self.roomInfo[0];
        
        TIoTModifyNameVC *modifyNameVC = [[TIoTModifyNameVC alloc]init];
        modifyNameVC.titleText =NSLocalizedString(@"room_name_tip", @"房间名称");
        modifyNameVC.defaultText = nameDic[@"name"];
        modifyNameVC.modifyType = ModifyTypeRoomName;
        modifyNameVC.title = NSLocalizedString(@"family_setting", @"家庭设置");
        modifyNameVC.modifyNameBlock = ^(NSString * _Nonnull name) {
            if (name.length > 0) {
                [self modifyRoom:name];
            }
            
        };
        [self.navigationController pushViewController:modifyNameVC animated:YES];
    }
}

#pragma mark - getter

- (NSArray *)roomInfo
{
    if (!_roomInfo) {
        _roomInfo = @[@{@"title":NSLocalizedString(@"room_name_tip", @"房间名称"),@"name":self.roomDic[@"RoomName"]?:@""}];
    }
    return _roomInfo;
}
@end
